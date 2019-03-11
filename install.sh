#!/bin/bash

if [[ $1 == "-h" ]];
    then
        echo "#Use this script to change the trimmomatic path in ".baqcom_qc", configure files, 
            and put theses file into the bash. More information read LEIAME.txt"
        exit 0
elif [[ $# > 0 ]];
    then
        echo "It is not a valid argment. Try ./install.sh -h"
        exit 1  
fi

grep "$PWD" ~/.bash_profile > /dev/null
if [ $? -ne 0 ]; 
    then
        cat "baqcom_qc" | sed "s|XXX|$PWD|" > baqcom_qc.R
        echo -e "\n#Added by BAQCOM\nPATH=\$PATH:$PWD:\n" >> ~/.bash_profile;
        source ~/.bash_profile;
        chmod +x baqcom_qc.R baqcom_mapping.R install_packages.R create_samples.sh run_test.sh ;
        ./install_packages.R;
        
    else
        echo "It is already installed"
fi

 
if [ "$(uname)" == "Linux" ]; then
     chmod +x bin/STAR_linux_2.7.0e
     ln -s bin/STAR_linux_2.7.0e STAR
     echo "Using Linux"
else
    chmod +x bin/STAR_mac_2.7.0e
    ln -s bin/STAR_mac_2.7.0e STAR
    echo "Using MacOS"
fi
unzip -q bin/fastqc_v0.11.8.zip -d bin
rm -f bin/fastqc_v0.11.8.zip
ln -s bin/FastQC/fastqc .

mv baqcom_qc .baqcom_qc
mv install_packages.R .install_packages.R

echo "successfully installed"
