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
#---------------------------------------------------------------
mkdir ~/recondata/automatd/$1
mkdir ~/recondata/automatd/$1/findings
mkdir ~/recondata/automatd/$1/final
cd ~/recondata/automatd/$1/findings
amass enum -passive -d $1 -o ~/recondata/automatd/$1/findings/amass.txt
findomain -t $1 -u ~/recondata/automatd/$1/findings/findomain.txt 
assetfinder --subs-only $1 > ~/recondata/automatd/$1/findings/asset.txt
subfinder -d $1 > ~/recondata/automatd/$1/findings/subfinder.txt
python ~/tools/Sublist3r/sublist3r.py -d $1 -o ~/recondata/automatd/$1/findings/sublist3r.txt
curl https://crt.sh/?q=%.$1 | grep "$1" | cut -d '>' -f2 | cut -d '<' -f1 | grep -v " " | sort -u > ~/recondata/automatd/$1/findings/crt.txt
cd ../~/recondata/automatd/$1/final
cat ~/recondata/automatd/$1/findings/*.txt | sort -u >> ~/recondata/automatd/$1/findings/all.txt
massdns -r /usr/share/wordlists/resolvers.txt -t A -o S ~/recondata/automatd/$1/findings/all.txt -w ~/recondata/automatd/$1/findings/massdns.txt
sed 's/A.*//' ~/recondata/automatd/$1/massdns.txt | sed 's/CN.*//' | sed 's/\..$//' > ~/recondata/automatd/$1/findings/Subdomain_mass.txt
rm ~/recondata/automatd/$1/findings/massdns.txt
massdns -r /usr/share/wordlists/resolvers.txt -w ~/recondata/automatd/$1/final/massdns-op.txt ~/recondata/automatd/$1/findings/all.txt
cat ~/recondata/automatd/$1/findings/all.txt | sort | filter-resolved | httprobe -c 40 > ~/recondata/automatd/$1/final/alive.txt
cat ~/recondata/automatd/$1/final/alive.txt | fprobe -c 40 -v | grep ":200," > ~/recondata/automatd/$1/final/fprobe200.txt
cat ~/recondata/automatd/$1/final/alive.txt | aquatone -scan-timeout 500 -screenshot-timeout 40000 -out ~/recondata/automatd/$1/final/$1
