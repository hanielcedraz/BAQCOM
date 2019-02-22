gunzip exemples/genome/Escherichia*

#create input_folder
mkdir 00-Fastq

#moving files from exemples folder to 00-Fastq Folder
cp exemples/SAMPLE* 00-Fastq/

#Creating samples.txt
./create_samples.sh
echo -e "\n"


#Run baqcom_qc.R
echo -e "\n"
echo "Running Quality Control Analysis"
echo -e "\n"
./baqcom_qc.R -p 36
echo -e "\n"

#Run baqcom_mapping.R
echo -e "\n"
echo "Running Mapping Analysis"
echo -e "\n"
./baqcom_mapping.R -p 20 -m exemples/genome -t exemples/genome/Escherichia_coli.HUSEC2011CHR1.dna.toplevel.fa -g exemples/genome/Escherichia_coli.HUSEC2011CHR1.42.gtf
