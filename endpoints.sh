#!/bin/bash
#looping through the scriptsresponse directory
mkdir endpoints

CUR_DIR=$(pwd)

for domain in $(ls Jscriptsresponse)
do
        #looping through files in each domain
        mkdir endpoints/$domain
        for file in $(ls Jscriptsresponse/$domain)
        do
                ruby ~/relative-url-extractor/extract.rb Jscriptsresponse/$domain/$file >> endpoints/$domain/$file 
        done
done
