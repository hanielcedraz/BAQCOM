#!/bin/bash

## Example: ./run_test.sh baqcomSTARmapping.R


usage="usage: ./$(basename "$0") [options] -- runTest version 0.3.1

     Use this script to test the functionality of the pipelines
     This script runs by default baqcomTrimmomatic.R (Quality Control). You have to specify which mapping pipeline you want to test

Examples:
    ./runTest.sh baqcomSTAR.R --- This option will run:
        - baqcomTrimmomatic.R (Quality Control)
        - baqcomSTAR.R (Index, Mapping and Counting)

    ./runTest.sh baqcomHisat2.R --- This option will run:
        - baqcomTrimmomatic.R (Quality Control)
        - baqcomHisat2.R (Index, Mapping)
        - baqcomHtseq.R (Counting)
        - baqcomFeatureCounts.R (Counting)

    ./run_test.sh all --- This option will run all available pipelines
    
    "

unset OPTARG
unset OPTIND


while getopts ':h' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    # p) $endFile
    #    ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
#exit 0
shift $((OPTIND-1))


pipeline=$1

#check if command line argument is empty or not present
#
if [ "$1" != ""  ] && [ "$1" != "baqcomSTAR.R"  ] && [ "$1" != "baqcomHisat2.R" ] && [ "$1" != "all" ];
then
    echo "Please enter a valid argument"
    echo "Example: run_test.sh baqcomSTAR.R"
    echo "Example: run_test.sh baqcomHisat2.R"
    echo "Example: run_test.sh all"
    exit 0
fi

genome=examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa.gz
annotation=examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf.gz
if [ -f "$genome" ];
then
    gunzip $genome
    echo -e "\nGenome files extracted successfully"
fi
if [ -f "$annotation" ];
then
    gunzip $annotation
    echo -e "Annotation files extracted successfully\n"
fi

#create input_folder
if [ ! -d 00-Fastq ];
then
    mkdir 00-Fastq
    if [ "$(ls -A 00-Fastq)" ]
    then
        echo -e "00-Fastq and files already exist\n"
    else
        cp examples/HE2* 00-Fastq/
        echo -e "00-Fastq created and files moved successfully\n"
    fi
fi
#moving files from examples folder to 00-Fastq Folder



#Creating samples.txt
echo -e "\n"
rm -f samples.txt
./createSamples.sh
echo -e "\n"
#





run.trimmomatic () {
    echo -e "\n"
    echo "Running baqcomTrimmomatic test"
    echo -e "\n"
    ./baqcomTrimmomatic.R -p 36 -s 2 -l
    echo -e "\n"
    echo "baqcomTrimmomatic test is done"
}


run.STAR () {
    echo -e "\nRunning baqcomSTAR\n"
        ./baqcomSTAR.R -p 19 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf 
    echo -e "\nbaqcomSTAR test is done\n"
}


run.HISAT2 () {
    echo -e "\nRunning baqcomHisat2 test\n"
    ./baqcomHisat2.R -p 19 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf 
    echo -e "\nbaqcomHisat2 test is done\n"
}


run.HTSEQ () {
    echo -e "\nRunning baqcomHtseq test\n"
    ./baqcomHtseq.R -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf 
    echo -e "\nbaqcomHtseq test is done\n"
}


run.FeatCount () {
    echo "Running baqcomFeatureCounts test"
    echo -e "\n"
    ./baqcomFeatureCounts.R -a examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf 
    echo "baqcomFeatureCounts test is done"
    echo -e "\n"
}


if [ "$pipeline" == "" ];
then
    run.trimmomatic
elif [[ "$pipeline" == "baqcomSTAR.R" ]];
then
    run.trimmomatic
    run.STAR
elif [[ "$pipeline" == "baqcomHisat2.R" ]];
then
    run.trimmomatic
    run.HISAT2
    run.HTSEQ
    run.FeatCount
elif [[ "$pipeline" == "all" ]];
then
    run.trimmomatic
    cp -r 02-Reports/ 02-Reports_2/
    run.STAR
    mv 02-Reports_2 02-Reports
    run.HISAT2
    run.HTSEQ
    run.FeatCount
fi
