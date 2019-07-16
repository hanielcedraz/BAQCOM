#!/bin/bash

## Example: ./run_test.sh baqcomSTARmapping.R


usage="usage: ./$(basename "$0") [options] -- runTest version 0.3.0

     Use this script to test the functionality of the pipelines
     This script runs by default baqcomTrimmomatic.R (Quality Control). You have to specify which mapping pipeline you want to test

Examples:
    ./runTest.sh baqcomSTARmapping.R --- This option will run:
        - baqcomTrimmomatic.R (Quality Control)
        - baqcomSTARmapping.R (Index, Mapping and Counting)

    ./runTest.sh baqcomHisat2Mapping.R --- This option will run:
        - baqcomTrimmomatic.R (Quality Control)
        - baqcomHisat2Mapping.R (Index, Mapping)
        - baqcomHtseqCounting.R (Counting)
        - baqcomFeaturesCount.R (Counting)

    ./run_test.sh all --- This option will run all available pipelines"

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
if [ "$1" != ""  ] && [ "$1" != "baqcomSTARmapping.R"  ] && [ "$1" != "baqcomHisat2Mapping.R" ] && [ "$1" != "all" ];
then
    echo "Please enter a valid argument"
    echo "Example: run_test.sh baqcomSTARmapping.R"
    echo "Example: run_test.sh baqcomHisat2Mapping.R"
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
    ./baqcomTrimmomatic.R -p 36 -s 2 -l -r
    echo -e "\n"
    echo "baqcomTrimmomatic test is done"
}


run.STAR () {
    echo -e "\nRunning baqcomSTARmapping\n"
        ./baqcomSTARmapping.R -p 20 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo -e "\nbaqcomSTARmapping test is done\n"
}


run.HISAT2 () {
    echo -e "\nRunning baqcomHisat2Mapping test\n"
    ./baqcomHisat2Mapping.R -p 20 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo -e "\nbaqcomHisat2Mapping test is done\n"
}


run.HTSEQ () {
    echo -e "\nRunning baqcomHtseqCounting test\n"
    ./baqcomHtseqCounting.R -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo -e "\nbaqcomHtseqCounting test is done\n"
}


run.FeatCount () {
    echo "Running baqcomFeaturesCount test"
    echo -e "\n"
    ./baqcomFeaturesCount.R -a examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo "baqcomFeaturesCount test is done"
    echo -e "\n"
}


if [ "$pipeline" == "" ];
then
    run.trimmomatic
elif [[ "$pipeline" == "baqcomSTARmapping.R" ]];
then
    run.trimmomatic
    run.STAR
elif [[ "$pipeline" == "baqcomHisat2Mapping.R" ]];
then
    run.trimmomatic
    run.HISAT2
    run.HTSEQ
    run.FeatCount
elif [[ "$pipeline" == "all" ]];
then
    run.trimmomatic
    run.STAR
    run.HISAT2
    run.HTSEQ
    run.FeatCount
fi
