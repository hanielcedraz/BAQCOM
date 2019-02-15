

#Use this script to change the trimmomatic path in R and put theses file into the bash

cat "qc_trimmomatic-V.0.0.1" | sed "s|XXX|$PWD|" > qc_trimmomatic-V.0.0.1.R

chmod +x qc_trimmomatic-V.0.0.1.R

echo -e "\n"PATH=$PATH:$PWD >> ~/.bashrc
bash

