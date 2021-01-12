#!/bin/bash


#Help menu
if [[ $1 == "-h" ]];
    then
        echo -e "\nUse this script to configurate the pipelines, install required softwares, configure files, and export path. More information read README.txt"
        exit 0
elif [[ $# > 0 ]];
    then
        echo -e "\nIt is not a valid argment. Try ./install.sh -h"
        exit 1
fi

#echo -e "\033[1m" #bols text
#echo -e "\033[1;31m" #red text

#Configuring path
grep "$PWD" ~/.bash_profile ~/.bashrc > /dev/null
if [ $? -ne 0 ];
    then
      if [ "$(uname)" == "Linux" ]; then
        echo -e "\n#Added by BAQCOM\nPATH=\$PATH:$PWD:\n" >> ~/.bashrc;
        #bash;
        echo -e "\nPath" $PWD "added in ~/.bashrc successfully"
      else
        echo -e "\n#Added by BAQCOM\nPATH=\$PATH:$PWD:\n" >> ~/.bash_profile;
        #source ~/.bash_profile;
        echo -e "\nPath" $PWD "added in ~/.bash_profile successfully"
    fi
      else
        if [ "$(uname)" == "Linux" ]; then
        echo -e "\nPath" $PWD "It is already in ~/.bashrc"
      else
        echo -e "\nPath" $PWD "It is already in ~/.bash_profile"
      fi
fi


#Configuring STAR, downloading Hisat2 and FeaturesCount in unix systems
if [ "$(uname)" == "Linux" ];
    then
      chmod +x bin/STAR_linux_2.7.6a
      rm -f STAR
      ln -s bin/STAR_linux_2.7.6a STAR
      echo -e "\nSTAR symbolic link created successfully"
       if ! [ -d bin/hisat2-2.1.0 ];
        then
            while true;
            do
              read -p "hisat2 doesn't exist in BAQCOM folder. Would you like to download it? [y,n] " dohisat
              case $dohisat in
                y|Y|yes|YES)
                  wget https://cloud.biohpc.swmed.edu/index.php/s/hisat2-210-Linux_x86_64/download -O bin/hisat2-2.1.0-Linux_x86_64.zip
                  cd bin/
                  unzip -q hisat2-2.1.0-Linux_x86_64.zip
                  cd ..
                  ln -s bin/hisat2-2.1.0/hisat2 hisat2
                  ln -s bin/hisat2-2.1.0/hisat2-build hisat2-build
                  ln -s bin/hisat2-2.1.0/hisat2_extract_exons.py
                  ln -s bin/hisat2-2.1.0/hisat2_extract_splice_sites.py
                  echo -e "\nhisat2 downloaded and symbolic link created successfully"
                  break;;
                n|N|no|NO)
                    echo -e "\nOk, I wont do that\n"
                    break;;
                *) echo "Insvalid option, specify y or n "
              esac
            done
        else
             echo -e "\nhisat2 exists and doesn't need to download"
        fi
        if ! [ -d bin/subread-2.0.0-Linux-x86_64 ];
        then
            while true;
            do
                read -p "featureCounts doesn't exist in BAQCOM folder. Would you like to download it? [y,n] " doft
                case $doft in
                  y|Y|yes|YES)
                    wget https://downloads.sourceforge.net/project/subread/subread-2.0.0/subread-2.0.0-Linux-x86_64.tar.gz -O bin/subread-2.0.0-Linux-x86_64.tar.gz
                    cd bin/
                    tar xzf subread-2.0.0-Linux-x86_64.tar.gz
                    #cd subread-2.0.0-Linux-x86_64/src
                    #make -f Makefile.Linux
                    #cd ../../../
                    cd ../
                    ln -s bin/subread-2.0.0-Linux-x86_64/bin/featureCounts featureCounts
                    break;;
                  n|N|no|NO)
                      echo -e "\nOk, I wont do that\n"
                      break;;
                  *) echo "Insvalid option, specify y or n "
              esac
            done
        else
            echo -e "\nfeatureCounts exists and doesn't need to download"
        fi
    else
      chmod +x bin/STAR_mac_2.7.6a
      rm -f STAR
      ln -s bin/STAR_mac_2.7.6a STAR
      echo -e "\nSTAR symbolic link created successfully"
        if ! [ -d bin/hisat2-2.1.0 ];
        then
            while true;
            do
              read -p "hisat2 doesn't exist in BAQCOM folder. Would you like to download it? [y,n] " dohisat
              case $dohisat in
                y|Y|yes|YES)
                  wget https://cloud.biohpc.swmed.edu/index.php/s/hisat2-210-OSX_x86_64/download -O bin/hisat2-2.1.0-OSX_x86_64.zip
                  cd bin/
                  unzip -q hisat2-2.1.0-OSX_x86_64.zip
                  cd ..
                  ln -s bin/hisat2-2.1.0/hisat2 hisat2
                  ln -s bin/hisat2-2.1.0/hisat2-build hisat2-build
                  ln -s bin/hisat2-2.1.0/hisat2_extract_exons.py
                  ln -s bin/hisat2-2.1.0/hisat2_extract_splice_sites.py
                  echo -e "\nhisat2 downloaded and symbolic link created successfully\n"
                  break;;
                n|N|no|NO)
                  echo -e "\nOk, I wont do that\n"
                  break;;
                *) echo "Insvalid option, specify y or n "
              esac
            done
        else
             echo -e "\nhisat2 exists and doesn't need to download"
        fi
        if ! [ -d bin/subread-2.0.0-MacOS-x86_64 ];
        then
            while true;
            do
                read -p "featureCounts doesn't exist in BAQCOM folder. Would you like to download it? [y,n] " doft
                case $doft in
                  y|Y|yes|YES)
                    wget https://downloads.sourceforge.net/project/subread/subread-2.0.0/subread-2.0.0-MacOS-x86_64.tar.gz -O bin/subread-2.0.0-MacOS-x86_64.tar.gz
                    cd bin/
                    tar xzf subread-2.0.0-MacOS-x86_64.tar.gz
                    #cd subread-2.0.0-MacOS-x86_64/src
                    #make -f Makefile.MacOS
                    #cd ../../../
                    cd ../
                    ln -s bin/subread-2.0.0-MacOS-x86_64/bin/featureCounts featureCounts
                    break;;
                  n|N|no|NO)
                    echo -e "\nOk, I wont do that\n"
                    break;;
                  *) echo "Insvalid option, specify y or n  "
                esac
            done
        else
            echo -e "\nfeatureCounts exists and doesn't need to download"
        fi
fi


#Configuring trimmomatic pipeline
if [[  -f baqcomTrimmomatic ]];
    then
        cat "baqcomTrimmomatic" | sed "s|XXX|$PWD|" > baqcomTrimmomatic.R
        chmod +x baqcomTrimmomatic.R;
        rm baqcomTrimmomatic
    else
        echo -e "\nbaqcomTrimmomatic.R already exists"
fi

#giving executable permission to the pipelines and scripts
      chmod +x baqcomFeatureCounts.R baqcomHisat2.R baqcomHtseq.R baqcomSTAR.R createSamples.sh runTest.sh countSTARreads.R

#install and configure fastQC
if [[ -e bin/fastqc_v0.11.8.zip ]];
   then
       unzip -q -u bin/fastqc_v0.11.8.zip -d bin
       mv -f bin/fastqc_v0.11.8.zip bin/.fastqc_v0.11.8.zip
       rm -f fastqc
       ln -s bin/FastQC/fastqc
       chmod +x fastqc
       echo -e "\nSymbolic link (fastqc) created successfully"
   else
       echo -e "\nfastqc (Symbolic link) already exists"

fi

#Install required R packages
if [ -e installPackages.R ];
    then
        chmod +x installPackages.R;
        ./installPackages.R;
        mv installPackages.R .installPackages.R
        echo -e "\npackages installed successfully"
    else
        echo -e "\npackages are already installed\n"
fi


if [ "$(uname)" == "Linux" ];
    then
        bash
    else
        source ~/.bash_profile;
fi
#echo "successfully installed"
#echo -e "\033[0m" #Regular color
