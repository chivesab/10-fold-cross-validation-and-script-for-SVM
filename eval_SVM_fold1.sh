#!/bin/bash
##################
##
## example:
##   bash eval.sh -C="LibSVM" -c=1 -g=2 -t="norm.fix" -d=200 -M="201604" -T="norm.fix" -r=80 -N=20
##################

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

start=$(date +%s.%N)

## Inputs
echo "Inputs"

#DATA_PATH="/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/201608"
MODEL_PATH="/home/hpc/intel_parking/iParking/data/model"
PRED_PATH="/home/hpc/intel_parking/iParking/data/ml_weka"

CLASSIFIER="LibSVM"
TRAIN_MON=""
TRAIN_TYPE=""
DUP=100
TEST_MON=""
TEST_TYPE="" #"norm.fix"
DET_RNG=100
WEKA_EVAL=""
WEKA_SEARCH=""
N=20
D=1
COST=""
GAMMA=0


for i in "$@"; do
    case $i in
        -C=*|--Classifier=*)
        CLASSIFIER="${i#*=}"
        ;;
        -c=*|--Cost=*)
        COST="${i#*=}"
        ;;
        -g=*|--gamma=*)
        GAMMA="${i#*=}"
        ;;
        -N=*|--NumFeatures=*)
        N="${i#*=}"
        ;;
        -m=*|--train_mon=*)
        TRAIN_MON="${i#*=}"
        ;;
        -t=*|--train_type=*)
        TRAIN_TYPE="${i#*=}"
        ;;
        -d=*|--duplicate=*)
        DUP="${i#*=}"
        ;;
        -M=*|--Test_mon=*)
        TEST_MON="${i#*=}"
        ;;
        -T=*|--Test_type=*)
        TEST_TYPE="${i#*=}"
        ;;
        -r=*|--range=*)
        DET_RNG="${i#*=}"
        ;;
	-E=*|--Evaluate=*)
	WEKA_EVAL="${i#*=}"
	;;
	-S=*|--Search=*)
	WEKA_SEARCH="${i#*=}"
	;;
        *)
        ;;
    esac
done

suffix='_fold1_training'
MOMO=${TRAIN_MON%$suffix}
echo ${MOMO}
echo ${TRAIN_MON}
DATA_PATH="/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}"
echo "test_month=" ${TEST_MON}
echo "test_type=" ${TEST_TYPE}


BAL=""
if [[ ${DUP} > 0 ]]; then
#    BAL=".bal${DUP}"
    BAL=".fltr"   #train type is norm.fix but the file we used is norm.fix.fltr.balance
fi

if [[ ${TRAIN_TYPE} == "" ]]; then
    TRAIN_FILE="weka_${SENSOR}${TRAIN_MON}${BAL}"
else
    TRAIN_FILE="weka_${SENSOR}${TRAIN_MON}.${TRAIN_TYPE}${BAL}.balance"  #weka_201608.norm.fix.fltr.balance
fi


#TEST_FILE="weka_${SENSOR}${TEST_MON}.${TEST_TYPE}"  #weka_201505.norm.fix.
TEST_FILE="weka_${SENSOR}${TEST_MON}.${TEST_TYPE}${BAL}"  #weka_201505.norm.fix.fltr
TEST_TYPE2=${TEST_TYPE}  #norm.fix
#TEST_FILE=""
#TEST_TYPE2=""

## Classifier name
if [[ -z ${COST} ]]; then
    WEKA_CLS_TRAIN="weka.classifiers.functions.LibSVM -B"   
    WEKA_CLS_TEST="weka.classifiers.functions.LibSVM"
    WEKA_CLS_WRAP="weka.classifiers.functions.LibSVM"
else
    WEKA_CLS_TRAIN="weka.classifiers.functions.LibSVM -G ${GAMMA} -C ${COST} -B"
    WEKA_CLS_TEST="weka.classifiers.functions.LibSVM"
    WEKA_CLS_WRAP="weka.classifiers.functions.LibSVM"
fi

## Train/Test output name
 TRAIN_FILE2=${TRAIN_FILE}   #weka_201505.norm.fix.fltr.balance
 TEST_FILE2=${TEST_FILE}     #weka_201505.norm.fix.fltr
 OUTPUT_FILE=${CLASSIFIER}.${TRAIN_FILE}.${TEST_FILE} #Libsvm.weka_201505.norm.fix.fltr.balance.weka_201505.norm.fix.fltr
 MODEL_FILE=${CLASSIFIER}.${TRAIN_FILE}   #Libsvm.weka_201505.norm.fix.fltr.balance
 if [[ ${WEKA_SEARCH} != "" ]]; then
     TRAIN_FILE2=${CLASSIFIER}.${TRAIN_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
     TEST_FILE2=${CLASSIFIER}.${TEST_FILE}.${TRAIN_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
     OUTPUT_FILE=${CLASSIFIER}.${TRAIN_FILE}.${TEST_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
     MODEL_FILE=${CLASSIFIER}.${TRAIN_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}

     if [[ ${TEST_TYPE} == "" ]]; then
         TEST_TYPE2=${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
     else
         TEST_TYPE2=${TEST_TYPE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
     fi
 fi
OUTPUT_FILE=${CLASSIFIER}.${TRAIN_FILE}.${TEST_FILE}
TRAIN_FILE2_ORIG=${TRAIN_FILE}
TEST_FILE2_ORIG=${TEST_FILE}
MODEL_FILE_ORIG=${CLASSIFIER}.${TRAIN_FILE}
if [[ ${WEKA_SEARCH} != "" ]]; then
    OUTPUT_FILE=${CLASSIFIER}.${TRAIN_FILE}.${TEST_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}

    if [[ ${TEST_TYPE} == "" ]]; then
        TEST_TYPE2=${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
    else
        TEST_TYPE2=${TEST_TYPE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
    fi

    TRAIN_FILE2_ORIG=${CLASSIFIER}.${TRAIN_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
    TEST_FILE2_ORIG=${CLASSIFIER}.${TEST_FILE}.${TRAIN_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
    MODEL_FILE_ORIG=${CLASSIFIER}.${TRAIN_FILE}.${WEKA_SEARCH}_${WEKA_EVAL}_N${N}_D${D}
fi

#python signal.signal(signal.SIGPIPE, signal.SIG_DFL)

TRAIN_FILE2=$(LC_ALL=C; cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32;)
TEST_FILE2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32;)
MODEL_FILE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32;)



#PRED_PATH= ../../data/ml_weka

#OUTPUT_FILE=${CLASSIFIER}.${TRAIN_FILE}.weka_201505_testing.norm.fix,fltr
if [ -f ${PRED_PATH}/${OUTPUT_FILE}.result.txt ]; then
  echo "${PRED_PATH}/${OUTPUT_FILE}.result.txt exists"
  #exit
else 
  echo "${PRED_PATH}/${OUTPUT_FILE}.result.txt doesn't exist"
fi

OUTPUT_FILE=${CLASSIFIER}.${TRAIN_FILE}.${TEST_FILE} #Libsvm.weka_201505_training.norm.fix.fltr.balance.weka_201505_testing.norm.fix.fltr

echo "eval_SVM_fold1.sh">>file_record.txt
echo "${OUTPUT_FILE}">>file_record.txt
echo "TRAIN_FILE2" >>file_record.txt
echo "${TRAIN_FILE2}">>file_record.txt
gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff.gz
sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff >> file_record.txt
gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff
echo '  '>>file_record.txt
echo "TEST_FILE2">>file_record.txt
echo "${TEST_FILE2}">>file_record.txt
gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff.gz
sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff >> file_record.txt
gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff
echo '  '>>file_record.txt
echo "MODEL_FILE">>file_record.txt
echo "${MODEL_FILE}">>file_record.txt
echo "---------------------------------------------------------------" >>file_record.txt




#echo "  (-N) weka num features: " ${N}
#echo "  (-m) train month: " ${TRAIN_MON}
#echo "  (-t) train type: " ${TRAIN_TYPE}
#echo "  (-d) duplicate: " ${DUP}
#echo "  (-M) test month: " ${TEST_MON}
#echo "  (-T) test type: " ${TEST_TYPE}
#echo "  (-r) range: " ${DET_RNG}
#echo "  train complete: " ${TRAIN_FILE2}
#echo "  test complete: " ${TEST_FILE2}

#cp ${DATA_PATH}/${TRAIN_FILE}.arff.gz ${DATA_PATH}/${TRAIN_FILE2}.arff.gz
#cp ${DATA_PATH}/${TEST_FILE}.arff.gz ${DATA_PATH}/${TEST_FILE2}.arff.gz

##Disable feature selection
#if false; then
###########################
## Feature Selection


if [ -f "${DATA_PATH}/${TRAIN_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff
fi
if [ -f "${DATA_PATH}/${TEST_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff
fi

echo "Feature Selection"
# if [[ ${WEKA_SEARCH} != "" ]] && ([ ! -f ${DATA_PATH}/${TRAIN_FILE2}.arff ] || [ ! -f ${DATA_PATH}/${TEST_FILE2}.arff ]); then
if [[ ${WEKA_SEARCH} == "" ]]; then
  cp ${DATA_PATH}/${TRAIN_FILE}.arff.gz ${DATA_PATH}/${TRAIN_FILE2}.arff.gz
  cp ${DATA_PATH}/${TEST_FILE}.arff.gz ${DATA_PATH}/${TEST_FILE2}.arff.gz

else
  ## Wrapper Evaluator
  if [[ ${WEKA_EVAL} == "WrapperSubsetEval" ]]; then
    java -classpath /home/hpc/intel_parking/weka-3-8-0/weka.jar:/home/hpc/intel_parking/wekafiles/packages/fastCorrBasedFS/fastCorrBasedFS.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/LibSVM.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/lib/libsvm.jar weka.filters.supervised.attribute.AttributeSelection \
        -E "weka.attributeSelection.${WEKA_EVAL} -B ${WEKA_CLS_WRAP}" \
        -S "weka.attributeSelection.${WEKA_SEARCH} -D ${D} -N ${N}" \
        -i ${DATA_PATH}/${TRAIN_FILE}.arff.gz \
        -o ${DATA_PATH}/${TRAIN_FILE2}.arff \
        -c last \
        -b \
        -r ${DATA_PATH}/${TEST_FILE}.arff.gz \
        -s ${DATA_PATH}/${TEST_FILE2}.arff
    gzip ${DATA_PATH}/${TRAIN_FILE2}.arff
    gzip ${DATA_PATH}/${TEST_FILE2}.arff

  ## RankSearch Searcher
  elif [[ ${WEKA_SEARCH} == "RankSearch" ]]; then
    java -classpath /home/hpc/intel_parking/weka-3-8-0/weka.jar:/home/hpc/intel_parking/wekafiles/packages/fastCorrBasedFS/fastCorrBasedFS.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/LibSVM.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/lib/libsvm.jar weka.filters.supervised.attribute.AttributeSelection \
        -E "weka.attributeSelection.${WEKA_EVAL} -M" \
        -S "weka.attributeSelection.${WEKA_SEARCH} -A weka.attributeSelection.GainRatioAttributeEval -- -M" \
        -i ${DATA_PATH}/${TRAIN_FILE}.arff.gz \
        -o ${DATA_PATH}/${TRAIN_FILE2}.arff \
        -c last \
        -b \
        -r ${DATA_PATH}/${TEST_FILE}.arff.gz \
        -s ${DATA_PATH}/${TEST_FILE2}.arff
    gzip ${DATA_PATH}/${TRAIN_FILE2}.arff
    gzip ${DATA_PATH}/${TEST_FILE2}.arff

  ## Ranker Searcher
  elif [[ ${WEKA_SEARCH} == "Ranker" ]]; then
    java -classpath /home/hpc/intel_parking/weka-3-8-0/weka.jar:/home/hpc/intel_parking/wekafiles/packages/fastCorrBasedFS/fastCorrBasedFS.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/LibSVM.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/lib/libsvm.jar weka.filters.supervised.attribute.AttributeSelection \
        -E "weka.attributeSelection.${WEKA_EVAL} -M" \
        -S "weka.attributeSelection.${WEKA_SEARCH} -N ${N}" \
        -i ${DATA_PATH}/${TRAIN_FILE}.arff.gz \
        -o ${DATA_PATH}/${TRAIN_FILE2}.arff \
        -c last \
        -b \
        -r ${DATA_PATH}/${TEST_FILE}.arff.gz \
        -s ${DATA_PATH}/${TEST_FILE2}.arff
    gzip ${DATA_PATH}/${TRAIN_FILE2}.arff
    gzip ${DATA_PATH}/${TEST_FILE2}.arff

  else
    java -classpath /home/hpc/intel_parking/weka-3-8-0/weka.jar:/home/hpc/intel_parking/wekafiles/packages/fastCorrBasedFS/fastCorrBasedFS.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/LibSVM.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/lib/libsvm.jar weka.filters.supervised.attribute.AttributeSelection \
        -E "weka.attributeSelection.${WEKA_EVAL} -M" \
        -S "weka.attributeSelection.${WEKA_SEARCH} -D ${D} -N ${N}" \
        -i ${DATA_PATH}/${TRAIN_FILE}.arff.gz \
        -o ${DATA_PATH}/${TRAIN_FILE2}.arff \
        -c last \
        -b \
        -r ${DATA_PATH}/${TEST_FILE}.arff.gz \
        -s ${DATA_PATH}/${TEST_FILE2}.arff
    gzip ${DATA_PATH}/${TRAIN_FILE2}.arff
    gzip ${DATA_PATH}/${TEST_FILE2}.arff
  fi
fi
##############################
##Disable feature selection endi
#fi
##############################


if [ -f "${DATA_PATH}/${TRAIN_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff
fi
if [ -f "${DATA_PATH}/${TEST_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff
fi

## Training
echo "Training: -t ${DATA_PATH}/${TRAIN_FILE2}.arff -d ${MODEL_PATH}/${MODEL_FILE}.model"
if [ ! -f ${MODEL_PATH}/${MODEL_FILE}.model ]; then
  java -classpath /home/hpc/intel_parking/weka-3-8-0/weka.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/LibSVM.jar:/home/hpc/intel_parking/libsvm-3.22/java/libsvm.jar ${WEKA_CLS_TRAIN} -t ${DATA_PATH}/${TRAIN_FILE2}.arff.gz -d ${MODEL_PATH}/${MODEL_FILE}.model -no-cv -o
fi


#if [ ! -f ${MODEL_PATH}/${MODEL_FILE}.model ]; then
#  java -classpath /home/hpc/intel_parking/weka-3-8-0/weka.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/LibSVM.jar:/home/hpc/intel_parking/libsvm-3.22/java/libsvm.jar ${WEKA_CLS_TRAIN} -t ${DATA_PATH}/${TRAIN_FILE2}.arff.gz -d ${MODEL_PATH}/${MODEL_FILE}.model -no-cv -o
#fi



## Testing
echo "PRED_PATH= ${PRED_PATH}"
echo "OUTPUT_FILE= ${OUTPUT_FILE}"
echo "Testing > ${PRED_PATH}/${OUTPUT_FILE}.pred.csv"
echo "Testing: -l ${MODEL_PATH}/${MODEL_FILE}.model -T ${DATA_PATH}/${TEST_FILE2}.arff > ${PRED_PATH}/${OUTPUT_FILE}.pred.csv"
java -classpath /home/hpc/intel_parking/weka-3-8-0/weka.jar:/home/hpc/intel_parking/wekafiles/packages/LibSVM1.0.10/LibSVM.jar:/home/hpc/intel_parking/libsvm-3.22/java/libsvm.jar ${WEKA_CLS_TEST} -l ${MODEL_PATH}/${MODEL_FILE}.model -T ${DATA_PATH}/${TEST_FILE2}.arff.gz -classifications "weka.classifiers.evaluation.output.prediction.CSV" > ${PRED_PATH}/${OUTPUT_FILE}.pred.csv



echo "eval_SVM_fold1.sh">>file_record.txt
echo "${OUTPUT_FILE}">>file_record.txt
echo "TRAIN_FILE2" >>file_record.txt
echo "${TRAIN_FILE2}">>file_record.txt
if [ -f "${DATA_PATH}/${TRAIN_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff
fi
echo '  '>>file_record.txt
echo "TEST_FILE2">>file_record.txt
echo "${TEST_FILE2}">>file_record.txt
if [ -f "${DATA_PATH}/${TEST_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff
fi
echo '  '>>file_record.txt
echo "MODEL_FILE">>file_record.txt
echo "${MODEL_FILE}">>file_record.txt
echo "---------------------------------------------------------------" >>file_record.txt



/bin/rm -f ${DATA_PATH}/${TRAIN_FILE2}.arff.gz
/bin/rm -f ${DATA_PATH}/${TEST_FILE2}.arff.gz
/bin/rm -f ${MODEL_PATH}/${MODEL_FILE}.model



if [ -f "${DATA_PATH}/${TRAIN_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TRAIN_FILE2}.arff
fi
if [ -f "${DATA_PATH}/${TEST_FILE2}.arff.gz" ];then
    gunzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff.gz
    sed -ne '/feature/p' /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff >> file_record.txt
    gzip /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${MOMO}/${TEST_FILE2}.arff
fi

## Evaluation
# echo "Evaluation: ${OUTPUT_FILE} ${DET_RNG}"
# python eval_pred.py ${OUTPUT_FILE} ${DET_RNG}
##    1. classifier
##    2. sensor
##    3. training month
##    4. training type
##    5. balance
##    6. testing month
##    7. testing type
##    8. tolerant range: allowed time difference between real and estimated event
#echo "Evaluation: ${CLASSIFIER} ${SENSOR} ${TRAIN_MON} ${TRAIN_TYPE} ${DUP} ${TEST_MON} ${TEST_TYPE2} ${DET_RNG}"
#echo "CLASSIFIER= "${CLASSIFIER}
#echo "SENSOR= "${SENSOR}
#echo "TRAIN_MON"${TRAIN_MON}
#echo "TRAIN_TYPE"${TRAIN_TYPE}
#echo "DUP= "${DUP}
#echo "TEST_MON= "${TEST_MON}
#echo "TEST_TYPE2= "${TEST_TYPE2}
#echo "DET_RNG= "${DET_RNG}

python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/eval_pred.py ${CLASSIFIER} "${SENSOR}" ${TRAIN_MON} ${TRAIN_TYPE} ${DUP} ${TEST_MON} ${TEST_TYPE2} ${DET_RNG}

end=$(date +%s.%N)
runtime=$(python -c "print(${end}-${start})")

echo "RUntime was $runtime"
echo "${MOMO}" >> runtime.txt
echo "RUntime was $runtime" >> runtime.txt
