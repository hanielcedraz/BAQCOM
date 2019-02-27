#
#Criar o arquivo samples.txt
file="samples.txt"
rm -f $file

dir="00-Fastq"
if [ -d "$dir" ]
then
	cd $dir
	echo -e 'SAMPLE_ID\tRead_1\tRead_2' > ../samples.txt
	paste <(ls *_R1_001.fastq.gz | cut -d "_" -f1) <(ls *_R1_001.fastq.gz) <(ls *_R2_001.fastq.gz) >> ../samples.txt
	cd -
	echo -e "\033[1;31m Samples_File ($file) successfully created"
	echo -e "\033[0m"
else
	echo -e "\033[1;31m $dir not found"
	echo -e "\033[0m"
fi
