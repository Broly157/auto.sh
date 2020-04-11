#!/bin/bash

chmod +x auto.sh
cp auto.sh /usr/bin
cp pwords.txt /usr/bin
echo "auto.sh Ready to use"
mkdir ~/recondata
mkdir ~/recondata/automatd
#-------------------------------------------------------------#
echo "Copying JSfileScanner.sh > /usr/bin (By dark_warlord14) https://twitter.com/dark_warlord14?s=20" #You can find the article related to this script here https://securityjunky.com/scanning-js-files-for-endpoint-and-secrets/ 
cp JSfileScanner.sh /usr/bin
#----------------------------------------------------------#
echo "Now installing important Tools"
mkdir ~/Broly
cd ~/Broly
snap install amass #(By Danielmiessler) https://twitter.com/DanielMiessler?s=20 | https://twitter.com/jeff_foley?s=20 | https://twitter.com/owaspamass?s=20
git clone https://github.com/Edu4rdSHL/findomain.git #(By Edu4rdSHL) https://twitter.com/Edu4rdSHL?s=20
go get -u github.com/tomnomnom/assetfinder #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
go get -u github.com/edoverflow/csp #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
go get -v github.com/projectdiscovery/subfinder/cmd/subfinder #(By projectdiscovery)
git clone https://github.com/blechschmidt/massdns.git #(By blechschmidt) 
git clone https://github.com/aboul3la/Sublist3r.git #(By aboul3la) https://twitter.com/aboul3la?s=20
go get -u github.com/tomnomnom/httprobe #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
go get github.com/tomnomnom/hacks/filter-resolved #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
go get -u github.com/theblackturtle/fprobe #By(theblackturtle)
git clone https://github.com/michenriksen/aquatone.git #(BY michenriksen) https://twitter.com/michenriksen?s=20
git clone https://github.com/dark-warlord14/LinkFinder #(By GerbenJavado) https://twitter.com/gerben_javado?s=20
curl --url https://raw.githubusercontent.com/tomnomnom/dotfiles/master/scripts/acao > cors.sh && mv cors.sh /usr/bin && cd /usr/bin && chmod +x cors.sh #(By Tomnomnom) https://twitter.com/TomNomNom?s=20
#------------------------------------------------------------#
apt install wget -y
pip install py-altdns #(By infosec_au) https://twitter.com/infosec_au?s=20 
#------------------------------------------------------------#
echo "Installing Findomain"
cd ~/Broly/findomain*
cargo build --release
cp target/release/findomain /usr/bin/
#-------------------------------------------------------------#
echo "Installing Massdns"
cd ~/Broly/massdns*
make 
cp /lists/resolvers.txt /usr/share/wordlists/resolvers.txt
cp /bin/massdns /usr/bin
#-------------------------------------------------------------#
echo "Installing Linkfinder"
cd ~/Broly/LinkFinder*
pip3 install -r requirements.txt
python3 setup.py install
#-------------------------------------------------------------#
echo "Installation Completed,You are Good to Go ;)"
