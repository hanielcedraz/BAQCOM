gunzip exemples/genome/Escherichia*

#create input_folder
mkdir 00-Fastq

#moving files from exemples folder to 00-Fastq Folder
cp exemples/SAMPLE* 00-Fastq/

#Creating samples.txt
./create_samples.sh

#Run baqcom_qc.R
./baqcom_qc.R -p 36 

#Run baqcom_mapping.R
./baqcom_mapping.R -p 20 -m exemples/genome -t exemples/genome/Escherichia_coli.HUSEC2011CHR1.cdna.all.fa -g exemples/genome/Escherichia_coli.HUSEC2011CHR1.42.gtf

