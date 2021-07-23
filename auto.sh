################################
# ///    Script By BROLY   \\\#
## ---------->157<---------- ##
################################

##COLORS

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
RESET=`tput sgr0`

#########
SECONDS=0
#########
QUOTES="Grab a cup of COFFEE!"


printf "${GREEN}

██████╗ ██████╗  ██████╗ ██╗  ██╗   ██╗
██╔══██╗██╔══██╗██╔═══██╗██║  ╚██╗ ██╔╝
██████╔╝██████╔╝██║   ██║██║   ╚████╔╝
██╔══██╗██╔══██╗██║   ██║██║    ╚██╔╝
██████╔╝██║  ██║╚██████╔╝███████╗██║
╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝

                        ${MAGENTA}--by Broly157
${RESET}"

printf "${BLUE}[i]${RESET}${RED}$QUOTES${RESET}\\n"
echo

##API KEYS##
securitytrails_key='YOUR_API_KEY'
virustotal_key='YOUR_API_KEY'
chaos_key='YOUR_API_KEY'
gitoken='YOUR_API_KEY'
##TEXT FILES##
pwords=/usr/share/wordlists/pwords.txt
resolver=/usr/share/wordlists/resolvers.txt

#-------------------------------------------------------------------------------------------------------#
#Alias for Folder's

target=~/recondata/automatd/$1
findings=$target/findings
final=$target/final


#-------------------------------------------------------------------------------------------------------#

mkdir $target
mkdir $target/findings
mkdir $target/final
cd $findings
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mAmass Scanning started\e[0m"
	amass enum --passive -norecursive -noalts -d $1 -o amass.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mFindomain Scanning started\e[0m"
	findomain -t $1 -u findomain.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mAssetfinder Scanning started\e[0m"
	assetfinder --subs-only $1 | tee -a asset.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSubfinder Scanning started\e[0m"
	subfinder -d $1 -recursive -silent -all -t 500 | tee -a subfinder.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mChaos Scanning started\e[0m"
    	chaos -key $chaos_key -d $1 -silent | tee -a chaos.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mGithub-Scanning started$\e[0m"
	python3 ~/Tools/github-search/github-subdomains.py -e -t $gitoken -d $1 | egrep '$1' | tee -a gitsub.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSublist3r Scanning started$\e[0m"
	python3 ~/Tools/Sublist3r/sublist3r.py -v -n -t 500  -d $1 -o sublist3r.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCrt.sh Scanning started\e[0m"
	curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a crt.txt
	cat crt.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a crtsh.txt ; rm crt.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mRapiddns.io Scanning started\e[0m"
        curl -s "https://rapiddns.io/subdomain/$1?full=1#result" | grep "<td><a" | cut -d '"' -f 2 | grep http | cut -d '/' -f3 | sed 's/#results//g' | sort -u | tee -a rapidns.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mBufferOverflow Scanning started\e[0m"
	curl -s --request GET --url "dns.bufferover.run/dns?q=.$1&rt=5" | jq --raw-output '.FDNS_A[]' | awk '{print $1}' | sed -e 's/^.*,//g' | sort -u | tee -a bufferover.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSearching in the SecurityTrails API...\e[0m"
        curl -s --request GET --url "https://api.securitytrails.com/v1/domain/$1/subdomains?apikey=$securitytrails_key" | jq --raw-output -r '.subdomains[]' | tee garbage.txt
        for i in $(cat garbage.txt); do echo $i'.'$1; done | tee -a securitytrails.txt
        rm -rf garbage.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mThreatcrowd Scanning started\e[0m"
	curl https://www.threatcrowd.org/searchApi/v2/domain/report/\?domain=$1 | jq '.subdomains' | sed 's/[][\/$*^|@#{}~&()_:;%+"='\'',`><?!]/ /g' | awk '{print $1}' | tee threatcrowd.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mHackertarget Scanning started\e[0m"
	curl https://api.hackertarget.com/hostsearch/\?q\=$1 | cut -d "," -f 1 | tee hackertarget.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mVirustotal Scanning started\e[0m"
        curl --silent --request GET --url "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$virustotal_key&domain=$1" | jq --raw-output -r '.subdomains[]?' | sort -u  | tee virustotal.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCreating Allrootdomains.txt\e[0m"
	cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee allrootsubdomains.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMassdns Scanning started\e[0m"
	massdns -r $resolver -t A -o S allrootsubdomains.txt -w massdns.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mExtracting subdomains from massdns.txt\e[0m"
	sed 's/A.*//' massdns.txt | sed 's/CN.*//' | sed 's/\..$//' | tee Subdomain_massdns.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mRemoving massdns.txt\e[0m"
	rm massdns.txt && rm allrootsubdomains.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMaking all.txt\e[0m"
	cat *.txt | sort -u | tee -a all.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mStarting ShuffleDns$\e[0m"
        shuffledns -d $1 -list $findings/all.txt -r $resolver -o shuffledns.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMaking all.txt\e[0m"
	cat *.txt | sort -u | tee all.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96m${YELLOW}Wanna do atldns Scan? just click {Y/y} or wait for 10 sec, i'll wait for 10sec's ${BLUE}{y${BLUE}}:$\e[0m"
for i in {10..1}
do
    read -t .1 -n 1 input
    if [  "$input" = "y"  ]; then
    printf "\n${RED}Altdns started \n${RESET}" && altdns -i all.txt -t 30 -o alt.txt -w $pwords
        exit
    elif [  "$input" = "n" ]; then
  printf "\n Skipping Atldns scan \n"
    fi
    echo -ne "\n $i \r" && sleep 1;
done
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCreating Allrootdomains.txt\e[0m"
	cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee $final/3rd_Level_subdomains.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mRemoving all.txt\e[0m"
	rm all.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMaking Fresh final (all.txt)\e[0m"
	cat *.txt | sort -u | grep -v "*" | egrep '$1' | tee temp_all.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mStarting ShuffleDns\e[0m"
    	shuffledns -d $1 -list temp_all.txt -r $resolver | tee temp_all1.txt ; cat temp_all.txt temp_all1.txt | sort -u | tee all.txt ; rm temp_all.txt temp_all1.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMoving into _Final_ folder$\e[0m"
	cd $final
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mChecking for alive domains\e[0m"
	cat $findings/*.txt | sort -u | httprobe -p http:81 -p http:300- p http:591 -p http:593 -p http:832 -p http:981 -p http:1010 -p http:1311 -p http:2082 -p http:2087 -p http:2095 -p http:2096 -p http:2480 -p http:3000 -p http:3128 -p http:3333 -p http:4243 -p http:4567 -p http:4711 -p http:4712 -p http:4993 -p http:5000 -p http:5104 -p http:5108 -p http:5800 -p http:6543 -p http:7000 -p http:7396 -p http:7474 -p http:8000 -p http:8001 -p http:8008 -p http:8014 -p http:8042 -p http:8069 -p http:8080 -p http:8081 -p http:8088 -p http:8090 -p http:8091 -p http:8118 -p http:8123 -p http:8172 -p http:8222 -p http:8243 -p http:8280 -p http:8281 -p http:8333 -p http:8443 -p http:8500 -p http:8834 -p http:8880 -p http:8888 -p http:8983 -p http:9000 -p http:9043 -p http:9060 -p http:9080 -p http:9090 -p http:9091 -p http:9200 -p http:9443 -p http:9800 -p http:9981 -p http:12443 -p http:16080 -p http:18091 -p http:18092 -p http:20720 -p http:28017 -p http:8009 -p http:8180 -p https:81 -p https:300- p https:591 -p https:593 -p https:832 -p https:981 -p https:1010 -p https:1311 -p https:2082 -p https:2087 -p https:2095 -p https:2096 -p https:2480 -p https:3000 -p https:3128 -p https:3333 -p https:4243 -p https:4567 -p https:4711 -p https:4712 -p https:4993 -p https:5000 -p https:5104 -p https:5108 -p https:5800 -p https:6543 -p https:7000 -p https:7396 -p https:7474 -p https:8000 -p https:8001 -p https:8008 -p https:8014 -p https:8042 -p https:8069 -p https:8080 -p https:8081 -p https:8088 -p https:8090 -p https:8091 -p https:8118 -p https:8123 -p https:8172 -p https:8222 -p https:8243 -p https:8280 -p https:8281 -p https:8333 -p https:8443 -p https:8500 -p https:8834 -p https:8880 -p https:8888 -p https:8983 -p https:9000 -p https:9043 -p https:9060 -p https:9080 -p https:9090 -p https:9091 -p https:9200 -p https:9443 -p https:9800 -p https:9981 -p https:12443 -p https:16080 -p https:18091 -p https:18092 -p https:20720 -p https:28017 -p https:8009 -p https:8180 -c 50 | tee alive.txt
	cat $findings/*.txt | sort -u | httpx -timeout 3 -threads 100 -retries 1 -content-length -status-code -silent | egrep '400|401|402|403|404|405' | cut -d [ -f 1 | tee 400.txt
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mOKAY these are the final Alive domains\e[0m"
	cat alive.txt
	count=$(cat alive.txt | sort -u | wc -l)
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mFound: $count Alive Subdomain's\e[0m"
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mAquatone Started$\e[0m"
        cat alive.txt | aquatone -out $1
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCNAME Scanning Started\e[0m"
	dnsprobe -l alive.txt -r CNAME | tee -a Cname
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mGetting IP Addresses for Each ALive Host\e[0m"
	dnsprobe -l alive.txt | sort -u | tee -a ips
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mJScanning started\e[0m"
	JSfileScanner.sh
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mfinding Subdomains using CSP\e[0m"
	cat $final/alive.txt | csp -c 20 | tee -a  temp.txt
	cat temp.txt | grep "$1" | tee csp_sub.txt ; rm temp.txt
cd $target
prompt_confirm() {
  while true; do
    read -r -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) cat $findings/*.txt | sort -u | tee -a final/final_all.txt && rm -fr $findings/ ; return 0
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
    esac
  done
}
prompt_confirm "${BLUE}[+] ${YELLOW}Do you want to combine every file in findings folder? if {y/Y} then you will only have one folder i.e [final] with everything${RESET}"
echo -e ' '
cd $final

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mStarting Knockpy$\e[0m"
	knockpy $1 --no-http-code 400 404 403 500 530 -t 2 -o $final 

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSubjack Scanning started for Checking Subdomain-Takover's\e[0m"
	subjack -t 100 -timeout 30 -o subtake.txt -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -w final_all.txt

echo -e ' '

echo -e "\e[5m\e[1m${BLUE}[+]\e[96m${YELLOW}Plain massdns Scanning\e[0m"
	touch massdns-op.txt
	massdns -r $resolver -w massdns-op.txt $final/final_all.txt
echo -e ""
prompt_confirm() {
  while true; do
    read -r -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) printf "\nStarted 400 BYpass Scanning\n" && cat 400.txt |  while read i ; do byps4xx.sh -c -r $i | tee bypased400 ; cat bypased400 | egrep curl | sort -u | tee bypased400; done && if [ ! -s bypased400]; then echo "The tool worked but didn't Found Any Bypass" >> bypased400;else echo "You got some bypass in bypased400";fi ; return 0
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
    esac
  done
}

prompt_confirm "${BLUE}[+] ${YELLOW}Do you wanna Check for 400 Bypass ? This may take Time depending on the Length of 400.txt${RESET}"

echo -e ""
prompt_confirm() {
  while true; do
    read -r -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) printf "\nScanning For Broken-Links\n" && cat alive.txt | while read i ; do broken-link-checker -rofi --filter-level 3 $i | egrep BROKEN | sort -u | tee blc ; done; return 0
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
    esac
  done
}

prompt_confirm "${BLUE}[+] ${YELLOW}Do you wanna Check for Broken-Link-HighJacking?${RESET}"

echo -e ""
prompt_confirm() {
  while true; do
    read -r -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) printf "\nStarted Cor's Scanning\n" && cors.sh alive.txt | tee Cors.txt ; return 0
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
    esac
  done
}

prompt_confirm "${BLUE}[+] ${YELLOW}Do COR's Scanning? This may take Time depending on the Length of alive.txt${RESET}"

duration=$SECONDS
printf "${GREEN}[+]${CYAN} Scan is completed in : $(($duration / 60)) minutes and $(($duration % 60)) seconds.${RESET}\n"
exit
