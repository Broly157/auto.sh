YELLOW='\033[0;34m'
CYAN='\033[0;36m'
END='\033[0m'


QUOTES=("Grab a cup of COFFEE!" )

printf "${YELLOW}[i]${END} ${QUOTES[$rand]}\\n"
echo

pwords=~/Broly/pwords.txt
resolver=~/Broly/massdns*/lists/resolvers.txt

mkdir ~/recondata/automatd/$1
mkdir ~/recondata/automatd/$1/findings
mkdir ~/recondata/automatd/$1/final
cd ~/recondata/automatd/$1/findings
echo "Amass Scanning started"
        amass enum --passive -d $1 -o amass.txt
echo "Findomain Scanning started"
        findomain -t $1 -u findomain.txt
echo "Assetfinder Scanning started"
        assetfinder --subs-only $1 | tee -a asset.txt
echo "Subfinder Scanning started"
        subfinder -d $1 | tee -a subfinder.txt
echo "Sublist3r Scanning started"
        python ~/Broly/Sublist3r/sublist3r.py -v -t 15 -d $1 -o sublist3r.txt
echo "Crt.sh Scanning started"
        curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a crt.txt
        cat crt.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a crtsh.txt
echo "Removing crt.txt "
        rm crt.txt
echo "Certspotter Scanning started"
        curl -s https://certspotter.com/api/v0/certs?domain=$1 | jq -c '.[].dns_names' | grep -o '"[^"]\+"' | tr -d '"' | sort -fu | grep "$1" | tee  >>certspotter.txt
echo "Threatcrowd Scanning started"
        curl https://www.threatcrowd.org/searchApi/v2/domain/report/\?domain=$1 | jq '.subdomains' | sed 's/[][\/$*^|@#{}~&()_:;%+"='\'',`><?!]/ /g' | awk '{print $1}' | tee >>threatcrowd.txt
echo "Hackertarget Scanning started"
        curl https://api.hackertarget.com/hostsearch/\?q\=$1 | cut -d "," -f 1 | tee >>hackertarget.txt
echo "Creating Allrootdomains.txt"
        cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a allrootsubdomains.txt
echo "Massdns Scanning started"
        massdns -r $resolver -t A -o S allrootsubdomains.txt -w massdns.txt
echo "Extracting subdomains from massdns.txt"
        sed 's/A.*//' massdns.txt | sed 's/CN.*//' | sed 's/\..$//' | tee -a Subdomain_mass.txt
echo "Removing massdns.txt"
        rm massdns.txt && rm allrootsubdomains.txt
echo "Making all.txt"
        cat *.txt | sort -u | tee -a all.txt
#echo "altdns Scanning started"
#       altdns -i all.txt -o altdns_output.txt -w $pwords
echo "Creating Allrootdomains.txt"
        cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a allrootsubdomains.txt
echo "Removing all.txt"
        rm all.txt
echo "Making Fresh final (all.txt)"
        cat *.txt | sort -u | grep -v "*" | tee -a all.txt
echo "Moving into folder _Final_"
        cd ~/recondata/automatd/$1/final
echo "Plain massdns Scanning"
        massdns -r $resolver -w massdns-op.txt ~/recondata/automatd/$1/findings/all.txt
echo "Checking for alive domains"
        cat ~/recondata/automatd/$1/findings/all.txt | sort -u | filter-resolved | httprobe -c 40 | tee -a  alive.txt
echo "fprobe Scanning started"
        mkdir fprobe && cd fprobe
	cat ../alive.txt | fprobe -c 40 -v >>fprobe.txt && cat fprobe.txt | grep ":20" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe200.txt && cat fprobe.txt | grep ":30" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe300.txt && cat fprobe.txt | grep ":40" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe400.txt && cat fprobe.txt | grep ":50" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | sort -u | tee -a fprobe500.txt
	rm fprobe.txt && cd ../
echo "JScanning started"
        bash JSfileScanner.sh
echo "finding Subdomains using CSP"
        cat ~/recondata/automatd/$1/final/alive.txt | csp -c 20 | tee -a  temp.txt
        cat temp.txt | grep "$1" | tee -a csp_sub.txt
        rm temp.txt
echo "Aquatone Started"
        cat alive.txt | aquatone -out $1
echo "Finding CNAME"
        cat  ~/recondata/automatd/$1/final/alive.txt | xargs -n 1 -I{} host -t CNAME {} | tee -a CNAME.txt
echo "Scanning for CORS"
        cors.sh alive.txt | tee -a CORS.txt
