#!/bin/bash

start=0
if [ ! $1 ]; then
	echo "default start from head"
else
	start = $1
fi

mon=(201504 201510 201604 201610 201703)
test_mon=(201504 201510 201604 201610 201703)

NM=${#mon[@]}
NTEST=${#test_mon[@]}


## ====================  preprocess: create weka, remove attribute ==================================


#for (( i = 0; i < ${NM}; i++)); do
#    echo "=============== start from step $start ==============="
#
#    cd /home/hpc/intel_parking/iParking/data/sensor/
#
#    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
#        rm weka_${mon[${i}]}*
#    fi
#    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
#    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
#        rm weka_${mon[${i}]}*
#    fi
#
#    echo "=============== step 0 finished ! ==============="
#
#    if [ $start -le 1 ]; then
#    	echo "===============  step 1 start !!!  ==============="
#    	#step 1
#        cd /home/hpc/intel_parking/iParking/data/sensor/
#        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
#            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
#            python mk_fold.py ${mon[${i}]}
#        fi
#        cd /home/hpc/intel_parking/iParking/data/sensor/
#        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
#            echo "number_of_index_${mon[${i}]}.txt doesn't exist"
#        fi
#        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
#    	./batch_format_convert_mat_arff_testing.sh -m ${mon[${i}]}  
#        ./batch_format_convert_mat_arff_training.sh -m ${mon[${i}]}
#
#    	echo "=============== step 1 finished !! ==============="
#    fi
#    cd /home/hpc/intel_parking/iParking/data/sensor/
#    chmod 777 ./*
#    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
#        echo "weka_${mon[${i}]}_training.norm.fix.arff.gz doesn't exist"
#    fi
#    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
#    if [ $start -le 2 ]; then
#    	echo "===============  step 2 start !!!  ==============="
#    	#step 4
#        ./weka_preprocess_resample_testing.sh -m ${mon[${i}]}
#    	./weka_preprocess_resample_training.sh -m ${mon[${i}]} 
#    	echo "=============== step 2 finished !! ==============="
#    fi
#    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
#    chmod 777 ./*
#    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
#        echo "weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz doesn't exist"
#    fi
#    cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
#    if [ $start -le 3 ]; then
#    	echo "===============  step 3 start !!! ==============="
#        ./batch_SVM_condor.sh -m ${mon[${i}]}
#        chmod 777 ./*
#        ./all_${mon[${i}]}_fold1.sh
#        echo "============== step 3 finished !! ==============="
#    fi
#   
##    if [$i -eq 0]; then
##	issue_201504=$(df -H |tail -1 |awk '{print $4}')
#           
#done

#df -H |tail -1 |awk '{print $4}'

echo " ===================   fold 2 start =============================================="
echo "=============== wait after fold1 finished ==============="

for (( i = 0; i < ${NM}; i++)); do    
    until [ -f /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_108_${mon[${i}]}_training_fold1 ]
    do 
        sleep 10m
    done
    echo "fold1 finished"
    echo "=============== start from step $start ==============="

    cd /home/hpc/intel_parking/iParking/data/sensor/

    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
        rm weka_${mon[${i}]}*
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
        rm weka_${mon[${i}]}*
    fi

    echo "=============== step 0 finished ! ==============="

    if [ $start -le 1 ]; then
    	echo "===============  step 1 start !!! ==============="
    	#step 1
        cd /home/hpc/intel_parking/iParking/data/sensor/
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            python mk_fold.py ${mon[${i}]}
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
    	./batch_format_convert_mat_arff_testing_fold2.sh -m ${mon[${i}]}  
        ./batch_format_convert_mat_arff_training_fold2.sh -m ${mon[${i}]}

    	echo "=============== step 1 finished !! ==============="
    fi
    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
        echo "weka_${mon[${i}]}_training.norm.fix.arff.gz doesn't exist"
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/
    chmod 777 ./*
    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
    if [ $start -le 2 ]; then
    	echo "===============  step 2 start !!!  ==============="
    	#step 4
        ./weka_preprocess_resample_testing.sh -m ${mon[${i}]}
    	./weka_preprocess_resample_training.sh -m ${mon[${i}]} 
    	echo "=============== step 2 finished !! ==============="
    fi
    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
        echo "weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz doesn't exist"
    fi  
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    chmod 777 ./*
    cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
    if [ $start -le 3 ]; then
    	echo "===============  step 3 start !!! ==============="
        ./batch_SVM_condor_fold2.sh -m ${mon[${i}]}
        chmod 777 ./*
        ./all_${mon[${i}]}_fold2.sh
        echo "=============== step 3 finished !! ==============="
    fi
done



echo " ===================   fold 3 start =============================================="

for (( i = 0; i < ${NM}; i++)); do
    until [ -f /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_108_${mon[${i}]}_training_fold2 ]
    do 
        sleep 10m
    done
    echo "fold2 finished"
    echo "=============== start from step $start ==============="

    cd /home/hpc/intel_parking/iParking/data/sensor/
    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
        rm weka_${mon[${i}]}*
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
        rm weka_${mon[${i}]}*
    fi

    echo "=============== step 0 finished ! =============="

    if [ $start -le 1 ]; then
    	echo "===============  step 1 start !!!  ================"
    	#step 1
        cd /home/hpc/intel_parking/iParking/data/sensor/
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            python mk_fold.py ${mon[${i}]}
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
    	./batch_format_convert_mat_arff_testing_fold3.sh -m ${mon[${i}]}  
        ./batch_format_convert_mat_arff_training_fold3.sh -m ${mon[${i}]}

    	echo "============== step 1 finished !! ================="
    fi
    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.fltr.arff.gz" ]; then
        echo "weka_${mon[${i}]}_training.norm.fix.arff.gz doesn't exist"
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/
    chmod 777 ./*
    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
    if [ $start -le 2 ]; then
    	echo "===============  step 2 start !!! ==============="
    	#step 4
        ./weka_preprocess_resample_testing.sh -m ${mon[${i}]}
    	./weka_preprocess_resample_training.sh -m ${mon[${i}]} 
    	echo "=============== step 2 finished !! ==============="
    fi
    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
        echo "weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz doesn't exist"
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    chmod 777 ./*
    cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/ 
    if [ $start -le 3 ]; then
    	echo "===============  step 3 start !!! ==============="
        ./batch_SVM_condor_fold3.sh -m ${mon[${i}]}
        chmod 777 ./*
        ./all_${mon[${i}]}_fold3.sh
        echo "=============== step 3 finished !! =============="
    fi
done 



echo "=============== fold 4 start ==============="

for (( i = 0; i < ${NM}; i++)); do
    until [ -f /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_108_${mon[${i}]}_training_fold3 ]
    do 
        sleep 10m
    done
    echo "fold3 finished"

    echo "=============== start from step $start ==============="

    cd /home/hpc/intel_parking/iParking/data/sensor/

    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
	rm weka_${mon[${i}]}*
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
	rm weka_${mon[${i}]}*
    fi

    echo "=============== step 0 finished ! ==============="

    if [ $start -le 1 ]; then
	echo "===============  step 1 start !!!  ==============="
	#step 1
	cd /home/hpc/intel_parking/iParking/data/sensor/
	if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
	    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
	    python mk_fold.py ${mon[${i}]}
	fi
	cd /home/hpc/intel_parking/iParking/data/sensor/
	if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
	    echo "number_of_index_${mon[${i}]}.txt doesn't exist"
	fi
	cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
	./batch_format_convert_mat_arff_testing_fold4.sh -m ${mon[${i}]}  
	./batch_format_convert_mat_arff_training_fold4.sh -m ${mon[${i}]}

	echo "=============== step 1 finished !! ==============="
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/
    chmod 777 ./*
    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
	echo "weka_${mon[${i}]}_training.norm.fix.arff.gz doesn't exist"
    fi
    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
    if [ $start -le 2 ]; then
	echo "===============  step 2 start !!!  ==============="
	#step 4
	./weka_preprocess_resample_testing.sh -m ${mon[${i}]}
	./weka_preprocess_resample_training.sh -m ${mon[${i}]} 
	echo "=============== step 2 finished !! ==============="
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    chmod 777 ./*
    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
	echo "weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz doesn't exist"
    fi
    cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
    if [ $start -le 3 ]; then
	echo "===============  step 3 start !!! ==============="
	./batch_SVM_condor_fold4.sh -m ${mon[${i}]}
	chmod 777 ./*
	./all_${mon[${i}]}_fold4.sh
	echo "============== step 3 finished !! ==============="
    fi
   
done
 
echo "=============== fold 5 start =============="

for (( i = 0; i < ${NM}; i++)); do
    until [ -f /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_108_${mon[${i}]}_training_fold4 ]
    do 
        sleep 10m
    done
    echo "fold4 finished"

    echo "=============== start from step $start ==============="

    cd /home/hpc/intel_parking/iParking/data/sensor/

    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
        rm weka_${mon[${i}]}*
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
        rm weka_${mon[${i}]}*
    fi

    echo "=============== step 0 finished ! ==============="

    if [ $start -le 1 ]; then
    	echo "===============  step 1 start !!!  ==============="
    	#step 1
        cd /home/hpc/intel_parking/iParking/data/sensor/
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            python mk_fold.py ${mon[${i}]}
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/number_of_index_${mon[${i}]}.txt" ]; then
            echo "number_of_index_${mon[${i}]}.txt doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
    	./batch_format_convert_mat_arff_testing_fold5.sh -m ${mon[${i}]}  
        ./batch_format_convert_mat_arff_training_fold5.sh -m ${mon[${i}]}

    	echo "=============== step 1 finished !! ==============="
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/
    chmod 777 ./*
    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_training.norm.fix.arff.gz" ]; then
        echo "weka_${mon[${i}]}_training.norm.fix.arff.gz doesn't exist"
    fi
    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
    if [ $start -le 2 ]; then
    	echo "===============  step 2 start !!!  ==============="
    	#step 4
        ./weka_preprocess_resample_testing.sh -m ${mon[${i}]}
    	./weka_preprocess_resample_training.sh -m ${mon[${i}]} 
    	echo "=============== step 2 finished !! ==============="
    fi
    cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
    chmod 777 ./*
    if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz" ]; then
        echo "weka_${mon[${i}]}_training.norm.fix.fltr.balance.arff.gz doesn't exist"
    fi
    cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
    if [ $start -le 3 ]; then
    	echo "===============  step 3 start !!! ==============="
        ./batch_SVM_condor_fold5.sh -m ${mon[${i}]}
        chmod 777 ./*
        ./all_${mon[${i}]}_fold5.sh
        echo "============== step 3 finished !! ==============="
    fi
   
done

if [ ! -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[4]}_training_fold5" ]; then
    echo "fold5 finished"
fi

