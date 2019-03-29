bunzip2 examples/genome/Sus_scrofa*
echo -e "files extracted successfully\n"

#create input_folder
mkdir 00-Fastq
echo -e "00-Fastq created successfully\n"

#moving files from examples folder to 00-Fastq Folder
cp examples/SAMPLE* 00-Fastq/
echo -e "files moved successfully\n"

#Creating samples.txt
./create_samples.sh
echo -e "\n"


#Run baqcom_qc.R
echo -e "\n"
echo "Running Quality Control Analysis"
echo -e "\n"
./baqcom_qc.R -p 36 -s 2 -l yes
echo -e "\n"

#Run baqcom_mapping.R
echo -e "\n"
echo "Running Mapping Analysis"
echo -e "\n"
./baqcom_mapping.R -p 20 -q 2 -t examples/genome/Sus_scrofa.Sscrofa11.1.dna.chromosome.1.fa -g examples/genome/Sus_scrofa.Sscrofa11.1.95.chromosome.1.gtf
