#!/bin/bash

mkdir ~/tools
chmod +x auto.sh
cp auto.sh /usr/bin
echo "auto.sh Ready to use"
mkdir ~/Broly/findomain
cp pwords.txt ~/Broly
#-------------------------------------------------------------#
echo "Copying JSfileScanner.sh > /usr/bin" #(By dark_warlord14) https://twitter.com/dark_warlord14?s=20 You can find the article related to this script here https://securityjunky.com/scanning-js-files-for-endpoint-and-secrets/ 
chmod +x JSfileScanner.sh && cp JSfileScanner.sh /usr/bin
#----------------------------------------------------------#
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt install snapd
sudo apt install nodejs


sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y jq
sudo apt-get install -y ruby-full
sudo apt-get install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
sudo apt-get install -y build-essential libssl-dev libffi-dev python-dev
sudo apt-get install -y python-setuptools
sudo apt-get install -y libldns-dev
sudo apt-get install -y python3-pip
sudo apt-get install -y python-pip
sudo apt-get install -y python-dnspython
sudo apt-get install -y git
sudo apt-get install -y rename
sudo apt-get install -y xargs

echo "installing bash_profile aliases from recon_profile"
git clone https://github.com/nahamsec/recon_profile.git
cd recon_profile
cat bash_profile >> ~/.bash_profile
source ~/.bash_profile
cd ~/tools/
echo "done"



install go
if [[ -z "$GOPATH" ]];then
echo "It looks like go is not installed, would you like to install it now"
PS3="Please select an option : "
choices=("yes" "no")
select choice in "${choices[@]}"; do
        case $choice in
                yes)

					echo "Installing Golang"
					wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
					sudo tar -xvf go1.13.4.linux-amd64.tar.gz
					sudo mv go /usr/local
					export GOROOT=/usr/local/go
					export GOPATH=$HOME/go
					export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
					echo 'export GOROOT=/usr/local/go' >> ~/.bash_profile
					echo 'export GOPATH=$HOME/go'	>> ~/.bash_profile			
					echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bash_profile	
					source ~/.bash_profile
					sleep 1
					break
					;;
				no)
					echo "Please install go and rerun this script"
					echo "Aborting installation..."
					exit 1
					;;
	esac	
done
fi
#----------------------------------------------------------#
echo "Now installing important Tools"
cd ~/tools
echo "Istalling Amass"
snap install amass #(By Danielmiessler) https://twitter.com/DanielMiessler?s=20 | https://twitter.com/jeff_foley?s=20 | https://twitter.com/owaspamass?s=20
echo "Installing assetfinder"
go get -u github.com/tomnomnom/assetfinder #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
echo "Installing CSP"
go get -u github.com/edoverflow/csp #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
echo "Installing ShuffleDns"
GO111MODULE=on go get -v github.com/projectdiscovery/shuffledns/cmd/shuffledns #(By pdiscoveryio) https://twitter.com/pdiscoveryio
echo "Installing Dnsprobe"
GO111MODULE=on go get -v github.com/projectdiscovery/dnsprobe
echo "Installing Shuffledns"
GO111MODULE=on go get -v github.com/projectdiscovery/shuffledns/cmd/shuffledns
echo "Installing BLC"
npm install broken-link-checker
echo "Installing Subfinder"
go get -v github.com/projectdiscovery/subfinder/cmd/subfinder #(By projectdiscovery)
echo "Cloning Massdns"
git clone https://github.com/blechschmidt/massdns.git #(By blechschmidt) 
echo "Installing Sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git #(By aboul3la) https://twitter.com/aboul3la?s=20
echo "Cloneing byp4xx"
git clone https://github.com/lobuhi/byp4xx.git
echo "Installing Httporbe"
go get -u github.com/tomnomnom/httprobe #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
echo "Installing Httpx"
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx #By(projectdiscovery)
echo "Installing Aquatone"
go get github.com/michenriksen/aquatone #(BY michenriksen) https://twitter.com/michenriksen?s=20
echo "Installinh Dnsprobe"
go get -u -v github.com/projectdiscovery/dnsprobe #(By projectdiscovery) https://twitter.com/pdiscoveryio?s=20
echo "Cloning Linkfinder"
git clone https://github.com/dark-warlord14/LinkFinder #(By GerbenJavado) https://twitter.com/gerben_javado?s=20
echo "Cloning acao"
curl --url https://raw.githubusercontent.com/tomnomnom/dotfiles/master/scripts/acao > cors.sh && mv cors.sh /usr/bin && cd /usr/bin && chmod +x cors.sh #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
#------------------------------------------------------------#
apt install wget -y
pip install py-altdns #(By infosec_au) https://twitter.com/infosec_au?s=20 
#------------------------------------------------------------#
echo "Installing Findomain"
cd ~/Broly/findomain*
sudo wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -O findomain
chmod +x findomain
#-------------------------------------------------------------#
echo "Installing Sublist3r"
cd ~/tools/Sublist3r*
pip install -r requirements.txt
echo "done"
#-------------------------------------------------------------#
echo "Installing Massdns"
cd ~/tools/massdns*
make 
cp /lists/resolvers.txt /usr/share/wordlists
#-------------------------------------------------------------#
echo "Installing Linkfinder"
cd ~/tools/LinkFinder*
pip3 install -r requirements.txt
python3 setup.py install
#-------------------------------------------------------------#
echo "Copying Every Go tools in /usr/bin"
cd
cp ~/tools/massdns*/bin/massdns /usr/bin
cp ~/tools/findomain*/findomain /usr/bin/
cp ~/go/bin/httprobe /usr/bin
cp ~/go/bin/fprobe /usr/bin
cp ~/go/bin/aquatone /usr/bin
cp ~/go/bin/assetfinder /usr/bin
cp ~/go/bin/subfinder /usr/bin
cp ~/go/bin/filter-resolved /usr/bin
cp ~/tools/byp4xx* /usr/bin
echo "Installation Completed,You are Good to Go ;)"
echo 'Please add ""All_Your_keys"" in /usr/bin/auto.sh'
