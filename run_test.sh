#!/bin/bash

pipeline=$1

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


#Run baqcomTrimmomatic.R
echo -e "\n"
echo "Running Quality Control Analysis"
echo -e "\n"
./baqcomTrimmomatic.R -p 36 -s 2 -l -r
echo -e "\n"

#Run baqcomSTARmapping.R
echo -e "\n"
echo "Running Mapping Analysis"
echo -e "\n"
./$pipeline -p 20 -t examples/genome/Sus.Scrofa.chr1.genome.dna.toplevel.fa -g examples/genome/Sus.Scrofa.chr1.gene.annotation.gtf -m
