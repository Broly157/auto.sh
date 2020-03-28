#-------------------------------------------------------------
#
#Remove "#" if need to install any of this tools
#
#--------------------------------------------------------------
#git clone https://github.com/Edu4rdSHL/findomain.git
#go get -u github.com/tomnomnom/assetfinder
#go get -v github.com/projectdiscovery/subfinder/cmd/subfinder
#apt-get install amass
#git clone https://github.com/aboul3la/Sublist3r.git
#go get -u github.com/tomnomnom/httprobe
#go get github.com/tomnomnom/hacks/filter-resolved
#go get -u github.com/theblackturtle/fprobe
#git clone https://github.com/michenriksen/aquatone.git
#mv every tool in your /usr/bin (except Sublist3r,aquatone {you have to give their location to use them perfectly})
#Note: in case of massdns after downloading it for git 
#1. do make , then cp the massdns to /usr/bin and copy /lists/resolvers.txt to /usr/share/wordlists/resolvers.txt
#Note: here mass dns will only work for subdomain Enumeration
#curl https://certspotter.com/api/v0/certs?domain=$1 | grep  -o '\[\".*\"\]' > ~/recondata/automatd/$1/certspotter{ManualCheck}.txt
#use the above cmd if you have not configure certspotter in amass config.ini
#------------------------------------------------------------------------------------------------------------------

mkdir ~/recondata/automatd/$1
cd ~/recondata/automatd/$1
amass enum -passive -d $1 -o ~/recondata/automatd/$1/amass.txt
findomain -t $1 -u ~/recondata/automatd/$1/findomain.txt 
assetfinder --subs-only $1 > ~/recondata/automatd/$1/asset.txt
subfinder -d $1 > ~/recondata/automatd/$1/subfinder.txt
python ~/tools/Sublist3r/sublist3r.py -d $1 -o ~/recondata/automatd/$1/sublist3r.txt
curl https://crt.sh/?q=%.$1 | grep "rms.com" | cut -d '>' -f2 | cut -d '<' -f1 | grep -v " " | sort -u > ~/recondata/automatd/$1/crt.txt
massdns -r /usr/share/wordlists/resolvers.txt -t A -o S ~/recondata/automatd/$1/all.txt -w ~/recondata/automatd/$1/massdns.txt
sed 's/A.*//' ~/recondata/automatd/$1/massdns.txt | sed 's/CN.*//' | sed 's/\..$//' > ~/recondata/automatd/$1/Subdomain_mass.txt
rm ~/recondata/automatd/$1/massdns.txt
cat ~/recondata/automatd/$1/*.txt | sort -u >> ~/recondata/automatd/$1/all.txt
massdns -r /usr/share/wordlists/resolvers.txt -w massdns-op.txt ~/recondata/automatd/$1/all.txt
cat ~/recondata/automatd/$1/all.txt | sort | filter-resolved | httprobe -c 40 > ~/recondata/automatd/$1/alive.txt
cat ~/recondata/automatd/$1/alive.txt | fprobe -c 40 -v | grep ":200," > ~/recondata/automatd/$1/fprobe200.txt
cat ~/recondata/automatd/$1/alive.txt | aquatone -scan-timeout 500 -screenshot-timeout 40000 -out ~/recondata/automatd/$1/$1
