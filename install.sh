while getopts 'h' c;
do
  echo "help"
  case $c in
    h) ACTION=echo "#Use this script to change the trimmomatic path in "qc_trimmomatic-V.0.0.1" 
        and put theses file into the bash"


cat "qc_trimmomatic-V.0.0.1" | sed "s|XXX|$PWD|" > qc_trimmomatic-V.0.0.1.R

chmod +x qc_trimmomatic-V.0.0.1.R

grep "$PWD" > /dev/null
if [ $? -eq 1 ] then
  echo -e "\n"PATH=$PATH:$PWD >> ~/.bashrc
  bash
  
  ln -s qc_trimmomatic-V.0.0.1.R qc_trimmomatic

  mv qc_trimmomatic-V.0.0.1 .qc_trimmomatic-V.0.0.1
fi


