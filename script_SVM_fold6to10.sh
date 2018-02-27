#!/bin/bash
#Do 201504 fold6~fold10 -> 201510 fold6~fold10 -> 201604 fold6~fold10 -> 201610 fold6~fold10 -> 201703 fold6~fold10
start=0
if [ ! $1 ]; then
	echo "default start from head"
else
	start = $1
fi

mon=(201504 201510 201610 201703)

NM=${#mon[@]}
NTEST=${#test_mon[@]}



df_tmp=$(df -H |tail -1 |awk '{print $4}')
df_tmp=${df_tmp:0:3}
df_value=$(bc -l <<<"$df_tmp*1000")
df_value=${df_value:0:4}
echo $df_value


## ====================  preprocess: create weka, remove attribute ==================================


for (( i = 0; i < ${NM}; i++)); do
    echo "=============== start from step $start ==============="
    

    #check whether output_month_fold6 exist, if exist, branch to do fold7    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold6_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold6*
        continue 
    else
        until [ $df_value -gt 110 ]
        do
            echo "wait until df -H is enough"
            sleep 10m
        done        
        cd /home/hpc/intel_parking/iParking/data/sensor/
        
        #check whether preprocess has been done or not, if done, remove them
        if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold6_training.norm.fix.arff.gz" ]; then
            rm weka_${mon[${i}]}_fold6*
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
        #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
        if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold6_training.norm.fix.fltr.balance.arff.gz" ]; then
            rm weka_${mon[${i}]}_fold6*
        fi
    
    
        if [ $start -le 1 ]; then
            echo "=============== ${mon[${i}]}  fold6 start !!!  ==============="
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
    
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold6_testing.norm.fix.arff.gz" ]; then
                cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
        	./batch_format_convert_mat_arff_testing_fold6.sh -m ${mon[${i}]}  
                ./batch_format_convert_mat_arff_training_fold6.sh -m ${mon[${i}]}
            fi
        	echo "=============== ${mon[${i}]} fold6 step 1 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold6_training.norm.fix.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold6_training.norm.fix.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
        if [ $start -le 2 ]; then
            echo "=============== ${mon[${i}]}  fold6 step 2 start !!!  ==============="
            #step 4
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold6_training.norm.fix.fltr.balancearff.gz" ]; then
                ./weka_preprocess_resample_testing_fold6.sh -m ${mon[${i}]}
        	./weka_preprocess_resample_training_fold6.sh -m ${mon[${i}]} 
            fi
            echo "=============== ${mon[${i}]} fold6 step 2 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold6_training.norm.fix.fltr.balance.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold6_training.norm.fix.fltr.balance.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
        if [ $start -le 3 ]; then
        	echo "=============== ${mon[${i}]} fold6 step 3 start !!! ==============="
            ./batch_SVM_condor_fold6.sh -m ${mon[${i}]}
            chmod 777 ./*
            ./all_${mon[${i}]}_fold6.sh
            echo "============== fold6 step 3 finished !! ==============="
        fi
    fi
#    if [$i -eq 0]; then
#	issue_201504=$(df -H |tail -1 |awk '{print $4}')
           

#df -H |tail -1 |awk '{print $4}'
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold7_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7*
        continue
    else 
        until [ $df_value -gt 150 ]
        do 
            echo "wait until df -H is enough"
            sleep 10m
        done   
        if [ $start -le 1 ]; then
            echo "=============== ${mon[${i}]} fold7 step 1 start !!!  ==============="
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
            ./batch_format_convert_mat_arff_testing_fold7.sh -m ${mon[${i}]}  
            ./batch_format_convert_mat_arff_training_fold7.sh -m ${mon[${i}]}
            echo "=============== ${mon[${i}]} fold7 step 1 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
        if [ $start -le 2 ]; then
            echo "=============== ${mon[${i}]} fold7  step 2 start !!!  ==============="
            #step 4
            ./weka_preprocess_resample_testing_fold7.sh -m ${mon[${i}]}
            ./weka_preprocess_resample_training_fold7.sh -m ${mon[${i}]} 
            echo "=============== ${mon[${i}]} fold7 step 2 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
        if [ $start -le 3 ]; then
            echo "=============== ${mon[${i}]} fold7  step 3 start !!! ==============="
            ./batch_SVM_condor_fold7.sh -m ${mon[${i}]}
            chmod 777 ./*
            ./all_${mon[${i}]}_fold7.sh
            echo "============== ${mon[${i}]} fold7  step 3 finished !! ==============="
        fi
    fi 
#    if [$i -eq 0]; then
#	issue_201504=$(df -H |tail -1 |awk '{print $4}')
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold8_training" ]; then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8*
        continue
    else
        until [ $df_value -gt 110 ]
        do
            echo "wait until df -H is enough"
            sleep 10m
        done
        if [ $start -le 1 ]; then
            echo "=============== ${mon[${i}]} fold8 step 1 start !!!  ==============="
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
            ./batch_format_convert_mat_arff_testing_fold8.sh -m ${mon[${i}]}  
            ./batch_format_convert_mat_arff_training_fold8.sh -m ${mon[${i}]}
            echo "=============== ${mon[${i}]} fold8 step 1 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
        if [ $start -le 2 ]; then
            echo "=============== ${mon[${i}]} fold8  step 2 start !!!  ==============="
            #step 4
            ./weka_preprocess_resample_testing_fold8.sh -m ${mon[${i}]}
            ./weka_preprocess_resample_training_fold8.sh -m ${mon[${i}]} 
            echo "=============== ${mon[${i}]} fold8 step 2 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
        if [ $start -le 3 ]; then
            echo "=============== ${mon[${i}]} fold8  step 3 start !!! ==============="
            ./batch_SVM_condor_fold8.sh -m ${mon[${i}]}
            chmod 777 ./*
            ./all_${mon[${i}]}_fold8.sh
            echo "============== ${mon[${i}]} fold8  step 3 finished !! ==============="
        fi
    fi

    if [ -f "home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold9_training" ]; then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9*
        continue
    else
        until [ $df_value -gt 730 ]
        do 
            echo "wait until df -H is enough"
            sleep 10m
        done
        if [ $start -le 1 ]; then
            echo "=============== ${mon[${i}]} fold9 step 1 start !!!  ==============="
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
            ./batch_format_convert_mat_arff_testing_fold9.sh -m ${mon[${i}]}  
            ./batch_format_convert_mat_arff_training_fold9.sh -m ${mon[${i}]}
            echo "=============== ${mon[${i}]} fold9 step 1 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
        if [ $start -le 2 ]; then
            echo "=============== ${mon[${i}]} fold9  step 2 start !!!  ==============="
            #step 4
            ./weka_preprocess_resample_testing_fold9.sh -m ${mon[${i}]}
            ./weka_preprocess_resample_training_fold9.sh -m ${mon[${i}]} 
            echo "=============== ${mon[${i}]} fold9 step 2 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
        if [ $start -le 3 ]; then
            echo "=============== ${mon[${i}]} fold9  step 3 start !!! ==============="
            ./batch_SVM_condor_fold9.sh -m ${mon[${i}]}
            chmod 777 ./*
            ./all_${mon[${i}]}_fold9.sh
            echo "============== ${mon[${i}]} fold9  step 3 finished !! ==============="
        fi
    fi

    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold10_training" ]; then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10*
        continue
    else
        until [ $df_value -gt 400 ]
        do 
            echo "wait until df -H is enough"
            sleep 10m
        done
        if [ $start -le 1 ]; then
            echo "=============== ${mon[${i}]} fold10 step 1 start !!!  ==============="
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
            ./batch_format_convert_mat_arff_testing_fold10.sh -m ${mon[${i}]}  
            ./batch_format_convert_mat_arff_training_fold10.sh -m ${mon[${i}]}
            echo "=============== ${mon[${i}]} fold10 step 1 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
        if [ $start -le 2 ]; then
            echo "=============== ${mon[${i}]} fold10  step 2 start !!!  ==============="
            #step 4
            ./weka_preprocess_resample_testing_fold10.sh -m ${mon[${i}]}
            ./weka_preprocess_resample_training_fold10.sh -m ${mon[${i}]} 
            echo "=============== ${mon[${i}]} fold10 step 2 finished !! ==============="
        fi
        cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
        chmod 777 ./*
        if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
            echo "weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz doesn't exist"
        fi
        cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
        if [ $start -le 3 ]; then
            echo "=============== ${mon[${i}]} fold10  step 3 start !!! ==============="
            ./batch_SVM_condor_fold10.sh -m ${mon[${i}]}
            chmod 777 ./*
            ./all_${mon[${i}]}_fold10.sh
            echo "============== ${mon[${i}]} fold10  step 3 finished !! ==============="
        fi
    fi

done
