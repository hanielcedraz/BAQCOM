#!/bin/bash

## Example: ./run_test.sh baqcomSTARmapping.R


usage="$(basename "$0") [options] -- runTest version 0.3.0
where:
     Use this script to test the functionality of the pipelines
     This script runs by default baqcomTrimmomatic.R. You have to specify which mapping pipeline you want to test

     Example: runTest.sh baqcomSTARmapping.R
     Example: runTest.sh baqcomHisat2Mapping.R
     Example: Example: run_test.sh all"

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



gunzip examples/genome/Sus.Scrofa*
echo -e "files extracted successfully\n"

#create input_folder
mkdir 00-Fastq
echo -e "00-Fastq created successfully\n"

#moving files from examples folder to 00-Fastq Folder
cp examples/HE2* 00-Fastq/
echo -e "files moved successfully\n"

#Creating samples.txt
./createSamples.sh
echo -e "\n"


run.trimmomatic () {
    echo -e "\n"
    echo "Running baqcomTrimmomatic test"
    echo -e "\n"
    ./baqcomTrimmomatic.R -p 36 -s 2 -l -r
    echo -e "\n"
    echo "baqcomTrimmomatic test is done"
}

run.trimmomatic.and.STAR () {
    echo -e "\n"
    echo "Running baqcomTrimmomatic test"
    echo -e "\n"
    ./baqcomTrimmomatic.R -p 36 -s 2 -l -r
    echo -e "\n"
    echo "baqcomTrimmomatic test is done"
    echo -e "\n"
    echo "Running baqcomSTARmapping"
    echo -e "\n"
    ./baqcomSTARmapping.R -p 20 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo "baqcomSTARmapping test is done"
}

run.trimmomatic.and.hisat2.and.counts () {
    echo -e "\n"
    echo "Running baqcomTrimmomatic test"
    echo -e "\n"
    ./baqcomTrimmomatic.R -p 36 -s 2 -l -r
    echo -e "\n"
    echo "baqcomTrimmomatic test is done"
    echo -e "\n"
    echo "Running baqcomHisat2Mapping test"
    echo -e "\n"
    ./baqcomHisat2Mapping.R -p 20 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo "baqcomHisat2Mapping test is done"
    echo -e "\n"
    echo "Running baqcomHtseqCounting test"
    echo -e "\n"
    ./baqcomHtseqCounting.R -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo -e "\n"
    echo "Running baqcomFeaturesCount test"
    echo -e "\n"
    ./baqcomFeaturesCount.R -a examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo "baqcomFeaturesCount test is done"
    echo -e "\n"
}

run.all.pipelines () {
    echo -e "\n"
    echo "Running baqcomTrimmomatic test"
    echo -e "\n"
    ./baqcomTrimmomatic.R -p 36 -s 2 -l -r
    echo -e "\n"
    echo "baqcomTrimmomatic test is done"
    echo -e "\n"
    echo "Running baqcomSTARmapping"
    echo -e "\n"
    ./baqcomSTARmapping.R -p 20 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo "baqcomSTARmapping test is done"
    echo -e "\n"
    echo "Running baqcomHisat2Mapping test"
    echo -e "\n"
    ./baqcomHisat2Mapping.R -p 20 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo "baqcomHisat2Mapping test is done"
    echo -e "\n"
    echo "Running baqcomHtseqCounting test"
    echo -e "\n"
    ./baqcomHtseqCounting.R -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
    echo -e "\n"
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
    run.trimmomatic.and.STAR
elif [[ "$pipeline" == "baqcomHisat2Mapping" ]];
then
    run.trimmomatic.and.hisat2.and.counts
elif [[ "$pipeline" == "all" ]]; then
    run.all.pipelines
fi

