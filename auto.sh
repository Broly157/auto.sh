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

QUOTES=("Grab a cup of COFFEE!"	)


printf "${GREEN}

██████╗ ██████╗  ██████╗ ██╗  ██╗   ██╗
██╔══██╗██╔══██╗██╔═══██╗██║  ╚██╗ ██╔╝
██████╔╝██████╔╝██║   ██║██║   ╚████╔╝
██╔══██╗██╔══██╗██║   ██║██║    ╚██╔╝
██████╔╝██║  ██║╚██████╔╝███████╗██║
╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝

                        ${MAGENTA}--by Broly157
${RESET}"

printf "${BLUE}[i]${RESET}${RED}${QUOTES[$rand]}${RESET}\\n"
echo

##API KEYS##
securitytrails_key='YOUR_API_KEY'

##TEXT FILES##
pwords=~/Broly/pwords.txt
resolver=~/Broly/massdns*/lists/resolvers.txt

mkdir ~/recondata/automatd/$1
mkdir ~/recondata/automatd/$1/findings
mkdir ~/recondata/automatd/$1/final
cd ~/recondata/automatd/$1/findings
echo "${BLUE}[+] ${YELLOW}Amass Scanning started${RESET}"
	amass enum --passive -d $1 -o amass.txt
echo "${BLUE}[+] ${YELLOW}Findomain Scanning started${RESET}"
	findomain -t $1 -u findomain.txt
echo "${BLUE}[+] ${YELLOW}Assetfinder Scanning started${RESET}"
	assetfinder --subs-only $1 | tee -a asset.txt
echo "${BLUE}[+] ${YELLOW}Subfinder Scanning started${RESET}"
	subfinder -d $1 | tee -a subfinder.txt
echo "${BLUE}[+] ${YELLOW}Sublist3r Scanning started${RESET}"
	python ~/Broly/Sublist3r/sublist3r.py -v -t 15 -d $1 -o sublist3r.txt
echo "${BLUE}[*] ${YELLOW}Crt.sh Scanning started${RESET}"
	curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a crt.txt
	cat crt.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a crtsh.txt
echo "${BLUE}[+] ${YELLOW}Removing crt.txt${RESET}"
	rm crt.txt
echo "${BLUE}[*] ${YELLOW}BufferOverflow Scanning started${RESET}"
	curl -s --request GET --url "dns.bufferover.run/dns?q=.$1&rt=5" | jq --raw-output '.FDNS_A[]' | awk '{print $1}' | sed -e 's/^.*,//g' | sort -u | tee -a bufferover.txt
echo "${BLUE}[*] ${YELLOW}Searching in the SecurityTrails API...${RESET}"
        curl -s --request GET --url "https://api.securitytrails.com/v1/domain/$1/subdomains?apikey=$securitytrails_key" | jq --raw-output -r '.subdomains[]' >> garbage.txt
        for i in $(cat garbage.txt); do echo $i'.'$1; done | tee -a securitytrails.txt
        rm -rf garbage.txt
echo "${BLUE}[*] ${YELLOW}Certspotter Scanning started${RESET}"
	curl -s https://certspotter.com/api/v0/certs?domain=$1 | jq -c '.[].dns_names' | grep -o '"[^"]\+"' | tr -d '"' | sort -fu | grep "$1" | tee  >>certspotter.txt
echo "${BLUE}[*] ${YELLOW}Threatcrowd Scanning started${RESET}"
	curl https://www.threatcrowd.org/searchApi/v2/domain/report/\?domain=$1 | jq '.subdomains' | sed 's/[][\/$*^|@#{}~&()_:;%+"='\'',`><?!]/ /g' | awk '{print $1}' | tee >>threatcrowd.txt
echo "${BLUE}[*] ${YELLOW}Hackertarget Scanning started${RESET}"
	curl https://api.hackertarget.com/hostsearch/\?q\=$1 | cut -d "," -f 1 | tee >>hackertarget.txt
echo "${BLUE}[+] ${YELLOW}Creating Allrootdomains.txt${RESET}"
	cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a allrootsubdomains.txt
echo "${BLUE}[+] ${YELLOW}Massdns Scanning started${RESET}"
	massdns -r $resolver -t A -o S allrootsubdomains.txt -w massdns.txt
echo "${BLUE}[+] ${YELLOW}Extracting subdomains from massdns.txt${RESET}"
	sed 's/A.*//' massdns.txt | sed 's/CN.*//' | sed 's/\..$//' | tee -a Subdomain_mass.txt
echo "${BLUE}[+] ${YELLOW}Removing massdns.txt${RESET}"
	rm massdns.txt && rm allrootsubdomains.txt
echo "${BLUE}[+] ${YELLOW}Making all.txt${RESET}"
	cat *.txt | sort -u | tee -a all.txt
prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) printf "\n${RED}Started altdns Scanning\n${RESET}" && altdns -i all.txt -t 30 -o alt.txt -w $pwords; return 0
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
    esac
  done
}

prompt_confirm "${BLUE}[+] ${YELLOW}Do altdns Scanning? this is only for subdomains enumeration and takes Time depending on the target list${RESET}"
echo "${BLUE}[+] ${YELLOW}Creating Allrootdomains.txt${RESET}"
	cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a allrootsubdomains.txt
echo "${BLUE}[+] ${YELLOW}Removing all.txt${RESET}"
	rm all.txt
echo "${BLUE}[+] ${YELLOW}Making Fresh final (all.txt)${RESET}"
	cat *.txt | sort -u | grep -v "*" | tee -a all.txt
        count=$(cat all.txt | sort -u | wc -l)
echo "${BLUE}[+] ${MAGENTA}Found: $count Unique Subdomain's in all.txt${RESET}"
echo "${BLUE}[+] ${YELLOW}Moving into folder _Final_${RESET}"
	cd ~/recondata/automatd/$1/final
echo "${BLUE}[+] ${YELLOW}Plain massdns Scanning${RESET}"
	massdns -r $resolver -w massdns-op.txt ~/recondata/automatd/$1/findings/all.txt
echo "${BLUE}[+] ${YELLOW}Checking for alive domains${RESET}"
	cat ~/recondata/automatd/$1/findings/all.txt | sort -u | filter-resolved | httprobe -c 40 | tee -a  alive.txt
	count=$(cat alive.txt | sort -u | wc -l)
echo "${BLUE}[+] ${MAGENTA}Found: $count Alive Subdomain's found${RESET}"
echo "${BLUE}[+] ${YELLOW}fprobe Scanning started${RESET}"
	mkdir fprobe && cd fprobe
	cat ../alive.txt | fprobe -c 40 -v >>fprobe.txt && cat fprobe.txt | grep ":20" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe200.txt && cat fprobe.txt | grep ":30" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe300.txt && cat fprobe.txt | grep ":40" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe400.txt && cat fprobe.txt | grep ":50" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe500.txt
	rm fprobe.txt && cd ../
echo "${BLUE}[+] ${YELLOW}JScanning started${RESET}"
	bash JSfileScanner.sh
echo "${BLUE}[+] ${YELLOW}finding Subdomains using CSP${RESET}"
	cat ~/recondata/automatd/$1/final/alive.txt | csp -c 20 | tee -a  temp.txt
	cat temp.txt | grep "$1" | tee -a csp_sub.txt
	rm temp.txt
echo "${BLUE}[+] ${YELLOW}Aquatone Started${RESET}"
	cat alive.txt | aquatone -out $1
prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) printf "\nStarted Cor's Scanning\n" && cors.sh alive.txt | tee -a CORS.txt && printf "\n${RED}Starting CNAME Scanning\n${RESET}" && cat alive.txt | xargs -n 1 -I{} host -t CNAME {} | tee -a CNAME.txt ; return 0
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
    esac
  done
}

prompt_confirm "${BLUE}[+] ${YELLOW}Do CNAME and COR's Scanning? This may take Time depending on the Length of alive.txt${RESET}"
echo ""
echo ""
cd ~/recondata/automatd/$1
prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) cat findings/*.txt | sort -u | tee -a final/final_all.txt && rm -fr findings ; return 0
        ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
    esac
  done
}
prompt_confirm "${BLUE}[+] ${YELLOW}Do you want to combine every file in findings folder? if {y/Y} then you will only have one folder i.e [final] with everything${RESET}"
