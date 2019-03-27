if [[ $1 == "-h" ]];
    then
        echo "#Use this script to create a sample file from 00-Fastq folder"
        exit 0
elif [[ $# > 0 ]];
    then
        echo "It is not a valid argment. Try ./install.sh -h"
        exit 1
fi



#
#Creating samples_file.txt
file="samples.txt"
rm -f $file

dir="00-Fastq"
if [ -d "$dir" ]
#if [ -d "$(ls -A "$dir")" ]
then
        if [ "$(ls -A $dir)" ]
        then
                cd $dir
                echo -e 'SAMPLE_ID\tRead_1\tRead_2' > ../samples.txt
                paste <(ls *_R1_001.fastq.gz | cut -d "_" -f1) <(ls *_R1_001.fastq.gz) <(ls *_R2_001.fastq.gz) >> ../samples.txt
                cd -
                echo -e "\033[1;31m Samples_File ($file) successfully created"
                echo -e "\033[0m"
        else
                echo -e "\033[1;31m $dir exist and is empty"
                echo -e "\033[0m"
        fi
else
        echo -e "\033[1;31m $dir not found"
        echo -e "\033[0m"
fi
