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
      chmod +x bin/STAR_linux_2.7.1a
      rm -f STAR
      ln -s bin/STAR_linux_2.7.1a STAR
      echo "STAR symbolic link created successfully"
       if ! [ -x  "$(command -v hisat2)" ];
        then
              wget http://ccb.jhu.edu/software/hisat2/dl/hisat2-2.1.0-Linux_x86_64.zip -O bin/hisat2-2.1.0-Linux_x86_64.zip
              cd bin/
              unzip -q hisat2-2.1.0-Linux_x86_64.zip
              cd ..
              ln -s bin/hisat2-2.1.0/hisat2 hisat2
              ln -s bin/hisat2-2.1.0/hisat2_extract_exons.py
              ln -s bin/hisat2-2.1.0/hisat2_extract_splice_sites.py
              echo "hisat2 downloaded and symbolic link created successfully"
        else
             echo "hisat2 exists and doesn't need to download"
        fi
        if [ -x  "$(command -v featureCounts)" ];
        then
            wget https://sourceforge.net/projects/subread/files/subread-1.6.4/subread-1.6.4-source.tar.gz -O bin/subread-1.6.4-source.tar.gz
            cd bin/
            tar xzvf subread-1.6.4-source.tar.gz
            cd subread-1.6.4-source/src
            make -f Makefile.Linux
            cd ../../../
            ln -s bin/subread-1.6.4-source/bin/featureCounts featureCounts
        else
            echo "hisat2 exists and doesn't need to download"
        fi
    else
      chmod +x bin/STAR_mac_2.7.1a
      rm -f STAR
      ln -s bin/STAR_mac_2.7.1a STAR
      echo "STAR symbolic link created successfully"
        if ! [ -x  "$(command -v hisat2)" ];
        then
              wget http://ccb.jhu.edu/software/hisat2/dl/hisat2-2.1.0-OSX_x86_64.zip -O bin/hisat2-2.1.0-OSX_x86_64.zip
              cd bin/
              unzip -q hisat2-2.1.0-OSX_x86_64.zip
              cd ..
              ln -s bin/hisat2-2.1.0/hisat2 hisat2
              ln -s bin/hisat2-2.1.0/hisat2_extract_exons.py
              ln -s bin/hisat2-2.1.0/hisat2_extract_splice_sites.py
              echo "hisat2 downloaded and symbolic link created successfully"
        else
             echo "hisat2 exists and doesn't need to download"
        fi
        if ! [ -x  "$(command -v featureCounts)" ];
        then
            wget https://sourceforge.net/projects/subread/files/subread-1.6.4/subread-1.6.4-source.tar.gz -O bin/subread-1.6.4-source.tar.gz
            cd bin/
            tar xzvf subread-1.6.4-source.tar.gz
            cd subread-1.6.4-source/src
            make -f make -f Makefile.MacOS
            cd ../../../
            ln -s bin/subread-1.6.4-source/bin/featureCounts featureCounts
        else
            echo "featureCounts exists and doesn't need to download"
        fi
fi



if [[  -f baqcomTrimmomatic ]];
    then
        cat "baqcomTrimmomatic" | sed "s|XXX|$PWD|" > baqcomTrimmomatic.R
        chmod +x baqcomTrimmomatic.R;
        rm baqcomTrimmomatic
    else
        echo "baqcomTrimmomatic.R already exists"
fi


      chmod +x baqcomFeaturesCount.R baqcomHisat2Mapping.R baqcomHtseqCounting.R baqcomSTARmapping.R createSamples.sh runTest.sh

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


if [ -e installPackages.R ];
    then
        chmod +x installPackages.R;
        ./installPackages.R;
        mv installPackages.R .installPackages.R
        echo "packages installed successfully"
    else
        echo "packages are already installed"
fi


#echo "successfully installed"
