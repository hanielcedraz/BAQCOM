#!/bin/bash



chmod +x bin/STAR_linux_2.7.6a
rm -f STAR
ln -s bin/STAR_linux_2.7.6a STAR
echo -e "\nSTAR symbolic link created successfully"
wget https://cloud.biohpc.swmed.edu/index.php/s/hisat2-210-Linux_x86_64/download -O bin/hisat2-2.1.0-Linux_x86_64.zip
cd bin/
unzip -q hisat2-2.1.0-Linux_x86_64.zip
cd ..
ln -s bin/hisat2-2.1.0/hisat2 hisat2
ln -s bin/hisat2-2.1.0/hisat2-build hisat2-build
ln -s bin/hisat2-2.1.0/hisat2_extract_exons.py
ln -s bin/hisat2-2.1.0/hisat2_extract_splice_sites.py

wget https://downloads.sourceforge.net/project/subread/subread-2.0.0/subread-2.0.0-Linux-x86_64.tar.gz -O bin/subread-2.0.0-Linux-x86_64.tar.gz
cd bin/
tar xzf subread-2.0.0-Linux-x86_64.tar.gz
                  
cat "baqcomTrimmomatic" | sed "s|XXX|$PWD|" > baqcomTrimmomatic.R
chmod +x baqcomTrimmomatic.R;
rm baqcomTrimmomatic



#giving executable permission to the pipelines and scripts
chmod +x baqcomFeatureCounts.R baqcomHisat2.R baqcomHtseq.R baqcomSTAR.R createSamples.sh runTest.sh countSTARreads.R



#install and configure fastQC

unzip -q -u bin/fastqc_v0.11.8.zip -d bin
mv -f bin/fastqc_v0.11.8.zip bin/.fastqc_v0.11.8.zip
rm -f fastqc
ln -s bin/FastQC/fastqc
chmod +x fastqc
    

#Install required R packages

chmod +x installPackages.R;
./installPackages.R;
mv installPackages.R .installPackages.R
      

#echo "successfully installed"
#echo -e "\033[0m" #Regular color
