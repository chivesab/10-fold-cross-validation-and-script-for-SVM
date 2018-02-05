#!/bin/bash
start_time=$(date +%s.%N)
while getopts "m:" option;
do
     case "${option}"
     in
     m) month=${OPTARG};;
     esac
done
python mk_fold.py ${month}
end=$(date +%s.%N)
runtime=$(python -c "print(${end}-${start_time})")
echo "Runtime was $runtime seconds"

echo "month= ${month}">>record_file.txt
echo "Runtime = $runtime seconds" >> record_file.txt



