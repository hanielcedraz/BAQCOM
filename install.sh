while getopts 'h' c;
do
  echo "help"
  case $c in
        h) ACTION= echo "#Use this script to change the trimmomatic path in "qc_trimmomatic-V.0.0.1" and put theses file into the bash"

           exit
           ;;
  esac
done
shift $((OPTIND - 1))

#Use this script to change the trimmomatic path in R and put theses file into the bash

cat "qc_trimmomatic-V.0.0.1" | sed "s|XXX|$PWD|" > qc_trimmomatic-V.0.0.1.R

chmod +x qc_trimmomatic-V.0.0.1.R


grep "$PWD" ~/.bashrc > /dev/null
if [ $? -ne 0 ]; then
  echo -e "\n"PATH=$PATH:$PWD >> ~/.bashrc;
  bash;
  
  ln -s qc_trimmomatic-V.0.0.1.R qc_trimmomatic
  ln -s mapping_STAR-V-0.0.1.R mapping_STAR
  mv qc_trimmomatic-V.0.0.1 .qc_trimmomatic-V.0.0.1
  
fi

