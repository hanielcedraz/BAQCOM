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


grep "$PWD" ~/.bash_profile ~/.bashrc > /dev/null
if [ $? -ne 0 ];
    then
      if [ "$(uname)" == "Linux" ]; then
        echo -e "\n#Added by BAQCOM\nPATH=\$PATH:$PWD:\n" >> ~/.bashrc;
        bash;
        echo "Path" $PWD "added in ~/.bashrc successfully"
      else
        echo -e "\n#Added by BAQCOM\nPATH=\$PATH:$PWD:\n" >> ~/.bash_profile;
        source ~/.bash_profile;
        echo "Path" $PWD "added in ~/.bash_profile successfully"
    fi
      else
        if [ "$(uname)" == "Linux" ]; then
        echo "Path" $PWD "It is already in ~/.bashrc"
      else
        echo "Path" $PWD "It is already in ~/.bash_profile"
      fi
fi


if [ "$(uname)" == "Linux" ];
    then
      chmod +x bin/STAR_linux_2.7.0f
      rm -f STAR
      ln -s bin/STAR_linux_2.7.0f STAR
      echo "Symbolic link (STAR) created successfully"
    else
      chmod +x bin/STAR_mac_2.7.0f
      rm -f STAR
      ln -s bin/STAR_mac_2.7.0f STAR
      echo "Symbolic link (STAR) created successfully"
fi



if [[  -f baqcom_qc ]];
    then
        cat "baqcom_qc" | sed "s|XXX|$PWD|" > baqcom_qc.R
        chmod +x baqcom_qc.R baqcom_mapping.R install_packages.R create_samples.sh run_test.sh;
        rm baqcom_qc
    else
        echo "baqcom_qc.R already exists"
fi

if [[ -e bin/fastqc_v0.11.8.zip ]];
   then
       unzip -q -u bin/fastqc_v0.11.8.zip -d bin
       mv -f bin/fastqc_v0.11.8.zip bin/.fastqc_v0.11.8.zip
       rm -f fastqc
       ln -s bin/FastQC/fastqc
       chmod +x fastqc
       echo "Symbolic link (fastqc) created successfully"
   else
       echo "fastqc (Symbolic link) already exists"

fi


if [ -e install_packages.R ];
    then
        ./install_packages.R;
        mv install_packages.R .install_packages.R
        echo "packages installed successfully"
    else
        echo "packages are already installed"
fi

which multiqc > /dev/null
if [ $? -ne 0 ];
    then
        echo "If you would like to use multiqc analysis, please install using administrator permission"
        echo "Installation
        #If pip is not installed, please install as follow:
            curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
            python get-pip.py

        #You can install MultiQC from PyPI using pip as follow:
            pip install multiqc"

        echo "More information, please acesse https://github.com/ewels/MultiQC"
fi

#echo "successfully installed"
