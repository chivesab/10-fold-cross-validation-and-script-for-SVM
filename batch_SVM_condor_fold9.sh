#!/bin/bash

#rm all.sh

EVAL_PATH="/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/"

while getopts "m:" option
do
    case "${option}"
    in
    m) MOTH=${OPTARG};;
    esac
done

cnt=0
MOMO=${MOTH}
TYPES=("norm.fix")
MONTHS_train="${MOTH}_fold9_training"
MONTHS_test="${MOTH}_fold9_testing"
DUPS=(100)
FEATURES=(22 43 65 86 108)
RNG=100
CLASSIFIER="LibSVM"
SENSOR=""
VALID=""
if [[ ${SENSOR} != "" ]]; then
    VALID=".valid"
fi

NT=${#TYPES[@]}
NM_t=${#MONTHS_train[@]}
NM_T=${#MONTHS_test[@]}
ND=${#DUPS[@]}
NF=${#FEATURES[@]}
NC=${#CLASSIFIERS[@]}


for (( ti = 0; ti < ${NM_t}; ti++ )); do

    i=0 ## MONTHS
    j=0 ## DUPS
    t=0 ## TYPES
    GRIDSEARCH_FILEPATH="/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/gridSearch_bestResult.txt"
    exec < $GRIDSEARCH_FILEPATH
    read line
    cost=${line}
    read line
    gamma=${line}

    for (( tj = 0; tj < ${NM_T}; tj++ )); do
        FILENAME="weka_${SENSOR}${MONTHS[${i}]}.${TYPES[${t}]}"
        echo "-----------------"
        echo "FILE=${FILENAME}"


        BAL=""
        if [[ ${DUPS[${j}]} > 0 ]]; then
            BAL=".bal${DUPS[${j}]}"
        fi
        echo "#!/bin/bash">>${EVAL_PATH}all_${MOMO}_fold9.sh
        echo "start=$(date +%s.%N)">>${EVAL_PATH}all_${MOMO}_fold9.sh
#        echo "  > all"
#	filename_all="${CLASSIFIER}.ALL.C${cost}.G${gamma}.Train${MONTHS_train[${ti}]}.Test${MONTHS_test[${tj}]}"
#	echo "	${filename_all}"
#        echo "bash ${EVAL_PATH}eval_SVM_fold9.sh -C=\"${CLASSIFIER}\" -c=\"${cost}\" -g=\"${gamma}\" -m=\"${MONTHS_train[${ti}]}\" -t=\"${TYPES[${t}]}\" -d=${DUPS[${j}]} -M=\"${MONTHS_test[${tj}]}\" -T=\"${TYPES[${t}]}\" -r=${RNG} -N=108" > ${EVAL_PATH}${filename_all}.sh
 #       echo "qsub -q long2 -o ${EVAL_PATH}out_all_${MONTHS_train[${ti}]} -e ${EVAL_PATH}err_all_${MONTHS_train[${ti}]} -l walltime=48:00:00 ${EVAL_PATH}${filename_all}.sh" >> ${EVAL_PATH}all_${MOMO}.sh

        echo "  > FCBF"
        filename_FCBF="${CLASSIFIER}.FCBF.C${cost}.G${gamma}.Train${MONTHS_train[${ti}]}.Test${MONTHS_test[${tj}]}"
	echo "	${filename_FCBF}"
        echo "bash ${EVAL_PATH}eval_SVM_fold9.sh -C=\"${CLASSIFIER}\" -c=\"${cost}\" -g=\"${gamma}\" -E=\"SymmetricalUncertAttributeSetEval\" -S=\"FCBFSearch\" -m=\"${MONTHS_train[${ti}]}\" -t=\"${TYPES[${t}]}\" -d=${DUPS[${j}]} -M=\"${MONTHS_test[${tj}]}\" -T=\"${TYPES[${t}]}\" -r=${RNG} -N=30" > ${EVAL_PATH}${filename_FCBF}.sh
        echo "qsub -q long2 -o ${EVAL_PATH}out_FCBF_${MONTHS_train[${ti}]} -e ${EVAL_PATH}err_FCBF_${MONTHS_train[${ti}]} -l walltime=480:00:00 ${EVAL_PATH}${filename_FCBF}.sh" >> ${EVAL_PATH}all_${MOMO}_fold9.sh



        echo "  > Cfs, BesttFirst"
        filename_cfs="${CLASSIFIER}.CFs.C${cost}.G${gamma}.Train${MONTHS_train[${ti}]}.Test${MONTHS_test[${tj}]}"
	echo "	${filename_cfs}"
        echo "bash ${EVAL_PATH}eval_SVM_fold9.sh -C=\"${CLASSIFIER}\" -c=\"${cost}\" -g=\"${gamma}\" -E=\"CfsSubsetEval\" -S=\"BestFirst\" -m=\"${MONTHS_train[${ti}]}\" -t=\"${TYPES[${t}]}\" -d=${DUPS[${j}]} -M=\"${MONTHS_test[${tj}]}\" -T=\"${TYPES[${t}]}\" -r=${RNG} -N=30" > ${EVAL_PATH}${filename_cfs}.sh
        echo "qsub -q long2 -o ${EVAL_PATH}out_Cfs_${MONTHS_train[${ti}]} -e ${EVAL_PATH}err_Cfs_${MONTHS_train[${ti}]} -l walltime=480:00:00 ${EVAL_PATH}${filename_cfs}.sh" >> ${EVAL_PATH}all_${MOMO}_fold9.sh


        for (( k = 0; k < ${NF}; k++ )); do
            echo "  > Ranker: ${FEATURES[${k}]}"
	    filename_ranker="${CLASSIFIER}.RANKER${FEATURES[${k}]}.C${cost}.G${gamma}.Train${MONTHS_train[${ti}]}.Test${MONTHS_test[${tj}]}"

            echo "bash ${EVAL_PATH}eval_SVM_fold9.sh -C=\"${CLASSIFIER}\" -c=\"${cost}\" -g=\"${gamma}\" -E=\"GainRatioAttributeEval\" -S=\"Ranker\" -m=\"${MONTHS_train[${ti}]}\" -t=\"${TYPES[${t}]}\" -d=${DUPS[${j}]} -M=\"${MONTHS_test[${tj}]}\" -T=\"${TYPES[${t}]}\" -r=${RNG} -N=${FEATURES[${k}]}" > ${EVAL_PATH}${filename_ranker}.sh
        echo "qsub -q long2 -o ${EVAL_PATH}out_${FEATURES[${k}]}_${MONTHS_train[${ti}]} -e ${EVAL_PATH}err_${FEATURES[${k}]}_${MONTHS_train[${ti}]} -l walltime=480:00:00 ${EVAL_PATH}${filename_ranker}.sh" >> ${EVAL_PATH}all_${MOMO}_fold9.sh
        done
   	echo "end=\$(date +%s.%N)">>${EVAL_PATH}all_${MOMO}_fold9.sh
	echo "runtime=\$(python -c \"print(\${end}-\${start})\")">>${EVAL_PATH}all_${MOMO}_fold9.sh
	echo "echo \"Runtime was \$runtime\"">>${EVAL_PATH}all_${MOMO}_fold9.sh
    done
done
