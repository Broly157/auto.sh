RED='\033[0;34m'
CYAN='\033[0;36m'
END='\033[0m'


QUOTES=("Grab a cup of COFFEE!"	)

printf "${RED}[i]${END} ${QUOTES[$rand]}\\n"
echo

mkdir ~/recondata/automatd/$1
mkdir ~/recondata/automatd/$1/findings
mkdir ~/recondata/automatd/$1/final
cd ~/recondata/automatd/$1/findings
echo "Amass Scanning started"
	amass enum --passive -d $1 -o amass.txt
echo "Findomain Scanning started"
	findomain -t $1 -u findomain.txt
echo "Assetfinder Scanning started"
	assetfinder --subs-only $1 > asset.txt
echo "Subfinder Scanning started"
	subfinder -d $1 > subfinder.txt
echo "Sublist3r Scanning started"
	python ~/tools/Sublist3r/sublist3r.py -v -t 15 -d $1 -o sublist3r.txt
echo "Crt.sh Scanning started"
	curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a crt.txt
	cat crt.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a crtsh.txt
echo "Removing crt.txt "
	rm crt.txt
echo "Certspotter Scanning started"
	curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep -w $1\$ | tee certspotter.txt
echo "Creating Allrootdomains.txt"
	cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a allrootsubdomains.txt
echo "Massdns Scanning started"
	massdns -r /usr/share/wordlists/resolvers.txt -t A -o S allrootsubdomains.txt -w massdns.txt
echo "Extracting subdomains from massdns.txt"
	sed 's/A.*//' massdns.txt | sed 's/CN.*//' | sed 's/\..$//' > Subdomain_mass.txt
echo "Removing massdns.txt" 
	rm massdns.txt && rm allrootsubdomains.txt
echo "Creating Allrootdomains.txt"
	cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a allrootsubdomains.txt
echo "Finding 3/4th Tier of Subdomains"
	cat allrootsubdomains.txt | xargs -n 1 -I{} curl -s https://crt.sh/\?q\=\%.{}\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a subsubdomains.txt
echo "Moving into folder _Final_"	
	cd ~/recondata/automatd/$1/final
echo "Plain massdns Scanning"
	massdns -r /usr/share/wordlists/resolvers.txt -w massdns-op.txt ~/recondata/automatd/$1/findings/allrootsubdomains.txt
echo "Checking for alive domains"
	cat ~/recondata/automatd/$1/findings/allrootsubdomains.txt | sort -u | filter-resolved | httprobe -c 40 > alive.txt
echo "JScanning started"
	bash JSfileScanner.sh
echo "fprobe Scanning started"
	cat alive.txt | fprobe -c 40 -v | grep ":200," > fprobe200.txt
echo "Aquatone Started"
	cat alive.txt | aquatone -out $1
echo "Finding CNAME"
	cat  ~/recondata/automatd/$1/findings/allrootsubdomains.txt | xargs -n 1 -I{} host -t CNAME {} > CNAME.txt
echo "Scanning for CORS"
       cors.sh alive.txt > CORS.txt
