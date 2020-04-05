#-------------------------------------------------------------
#
#Remove "#" if need to install any of this tools
#
#--------------------------------------------------------------
#git clone https://github.com/Edu4rdSHL/findomain.git
#go get -u github.com/tomnomnom/assetfinder
#go get -v github.com/projectdiscovery/subfinder/cmd/subfinder
#apt-get install amass
#git clone https://github.com/blechschmidt/massdns.git
#git clone https://github.com/aboul3la/Sublist3r.git
#go get -u github.com/tomnomnom/httprobe
#go get github.com/tomnomnom/hacks/filter-resolved
#go get -u github.com/theblackturtle/fprobe
#git clone https://github.com/michenriksen/aquatone.git
#cd && curl --url https://raw.githubusercontent.com/tomnomnom/dotfiles/master/scripts/acao > cors.sh && mv cors.sh /usr/bin && cd /usr/bin && chmod +x cors.sh (for install script of CORS)
#NOTE:even after installing every tools listed above if the script didn't seems working it's probably becoz of amass try using it on the different terminal
#----------------------------------------------------------------------------------------------------------------------------------------------------------
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
	cat allrootsubdomains.txt | xargs -n 1 -I{} curl -s https://crt.sh/\?q\=\%.{}\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee > subsubdomains.txt
echo "Moving into folder _Final_"	
	cd ~/recondata/automatd/$1/final
echo "Plain massdns Scanning"
	massdns -r /usr/share/wordlists/resolvers.txt -w massdns-op.txt ~/recondata/automatd/$1/findings/allrootsubdomains.txt
echo "Checking for alive domains"
	cat ~/recondata/automatd/$1/findings/allrootsubdomains.txt | sort -u | filter-resolved | httprobe -c 40 > alive.txt
echo "Creating Header and Response body"	
	response.sh alive.txt 
echo "Extracting JS files from Header and Response body"	
	cp /usr/bin/jsfiles.sh ~/recondata/automatd/$1/final
	jsfiles.sh 
#------------------------------------------------------------------------------------------------------------------------------------------
echo "Extracting endpoints from JS files"
#------------------------------------------------------------------------------------------------------------------------------------------
	rm jsfiles.sh
	endpoints.sh
	cd endpoints
for domain in $(ls ~/recondata/automatd/$1/final/endpoints)
		do
        		for file in $(ls ~/recondata/automatd/$1/final/endpoints/$domain)
        	do 
                	find . -name '*.js' -exec cat {} \; >> ~/recondata/automatd/$1/final/endpoints/$domain/allendpoints.txt
        	done
		done
		cd ../
#--------------------------------------------------------------------------------------------------------------------------------------------		
echo "fprobe Scanning started"
	cat alive.txt | fprobe -c 40 -v | grep ":200," > fprobe200.txt
echo "Aquatone Started"
	cat alive.txt | aquatone -scan-timeout 500 -screenshot-timeout 40000 -out $1
echo "Finding CNAME"
	cat  ~/recondata/automatd/$1/findings/allrootsubdomains.txt | xargs -n 1 -I{} host -t CNAME {} > CNAME.txt
echo "Scanning for CORS"
       cors.sh alive.txt > CORS.txt
