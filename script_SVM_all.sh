#!/bin/bash
#Do 201504 fold1 --> fold10 , 201510 fold1 --> fold10 , 201604 fold1 --> fold10, 201610 fold1 --> fold10, 201703 fold1 --> fold10
#Read job_list.txt, check the state of job, if it's 'incomplete' then run it.
#Before running a job, locking the job_list.txt when reading it, make sure only one job read this file.
#df -H to make sure cluster size is enough for running jobs.  


start=0
if [ ! $1 ]; then
	echo "default start from head"
else
	start = $1
fi

mon=(201504 201510 201610 201703)

NM=${#mon[@]}
NTEST=${#test_mon[@]}



df_tmp=$(df -H |tail -1 |awk '{print $4}') #get the cluster disk size , ex: 3.6T
df_tmp=${df_tmp:0:3}
df_value=$(bc -l <<<"$df_tmp*1000") #script doesn't support float calculating, should use bc -l for instead 
df_value=${df_value:0:4}
echo $df_value #cluster available disk size in GB


## ====================  preprocess: create weka, remove attribute ==================================

for (( i = 0; i < ${NM}; i++))
do
    echo "=============== start from step $start ==============="
   
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold1_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold1 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold1.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold1.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold1 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold1 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold1.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold1.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold1 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold1 step 3 start !!! ==============="
                ./batch_SVM_condor_fold1.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold1.sh
                echo "============== fold1 step 3 finished !! ==============="
            fi
        

        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold1 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold1.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold1.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold1 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold1 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold1.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold1.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold1 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold1 step 3 start !!! ==============="
                ./batch_SVM_condor_fold1.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold1.sh
                echo "============== fold1 step 3 finished !! ==============="
            fi
  
        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold1 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold1.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold1.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold1 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold1 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold1.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold1.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold1 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold1 step 3 start !!! ==============="
                ./batch_SVM_condor_fold1.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold1.sh
                echo "============== fold1 step 3 finished !! ==============="
            fi

        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold1 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold1.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold1.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold1 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold1 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold1.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold1.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold1 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold1 step 3 start !!! ==============="
                ./batch_SVM_condor_fold1.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold1.sh
                echo "============== fold1 step 3 finished !! ==============="
            fi

        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold1*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold1 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold1.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold1.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold1 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold1 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold1.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold1.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold1 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold1_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold1 step 3 start !!! ==============="
                ./batch_SVM_condor_fold1.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold1.sh
                echo "============== fold1 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py
#    if [$i -eq 0]; then
#	issue_201504=$(df -H |tail -1 |awk '{print $4}')
           

#df -H |tail -1 |awk '{print $4}'

    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold2_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold2 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold2.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold2.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold2 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold2 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold2.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold2.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold2 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold2 step 3 start !!! ==============="
                ./batch_SVM_condor_fold2.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold2.sh
                echo "============== fold2 step 3 finished !! ==============="
            fi

        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold2 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold2.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold2.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold2 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold2 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold2.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold2.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold2 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold2 step 3 start !!! ==============="
                ./batch_SVM_condor_fold2.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold2.sh
                echo "============== fold2 step 3 finished !! ==============="
            fi

        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold2 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold2.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold2.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold2 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold2 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold2.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold2.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold2 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold2 step 3 start !!! ==============="
                ./batch_SVM_condor_fold2.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold2.sh
                echo "============== fold2 step 3 finished !! ==============="
            fi

        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold2 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold2.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold2.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold2 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold2 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold2.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold2.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold2 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold2 step 3 start !!! ==============="
                ./batch_SVM_condor_fold2.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold2.sh
                echo "============== fold2 step 3 finished !! ==============="
            fi

        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold2*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold2 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold2.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold2.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold2 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold2 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold2.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold2.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold2 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold2_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold2 step 3 start !!! ==============="
                ./batch_SVM_condor_fold2.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold2.sh
                echo "============== fold2 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py

 
    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold3_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold3 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold3.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold3.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold3 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold3 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold3.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold3.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold3 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold3 step 3 start !!! ==============="
                ./batch_SVM_condor_fold3.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold3.sh
                echo "============== fold3 step 3 finished !! ==============="
            fi

        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold3 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold3.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold3.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold3 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold3 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold3.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold3.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold3 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold3 step 3 start !!! ==============="
                ./batch_SVM_condor_fold3.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold3.sh
                echo "============== fold3 step 3 finished !! ==============="
            fi

        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold3 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold3.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold3.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold3 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold3 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold3.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold3.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold3 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold3 step 3 start !!! ==============="
                ./batch_SVM_condor_fold3.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold3.sh
                echo "============== fold3 step 3 finished !! ==============="
            fi

        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold3 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold3.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold3.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold3 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold3 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold3.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold3.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold3 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold3 step 3 start !!! ==============="
                ./batch_SVM_condor_fold3.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold3.sh
                echo "============== fold3 step 3 finished !! ==============="
            fi

        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold3*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold3 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold3.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold3.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold3 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold3 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold3.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold3.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold3 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold3_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold3 step 3 start !!! ==============="
                ./batch_SVM_condor_fold3.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold3.sh
                echo "============== fold3 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py
 

    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold4_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold4 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold4.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold4.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold4 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold4 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold4.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold4.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold4 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold4 step 3 start !!! ==============="
                ./batch_SVM_condor_fold4.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold4.sh
                echo "============== fold4 step 3 finished !! ==============="
            fi

        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold4 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold4.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold4.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold4 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold4 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold4.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold4.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold4 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold4 step 3 start !!! ==============="
                ./batch_SVM_condor_fold4.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold4.sh
                echo "============== fold4 step 3 finished !! ==============="
            fi

        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold4 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold4.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold4.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold4 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold4 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold4.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold4.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold4 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold4 step 3 start !!! ==============="
                ./batch_SVM_condor_fold4.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold4.sh
                echo "============== fold4 step 3 finished !! ==============="
            fi

        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold4 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold4.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold4.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold4 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold4 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold4.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold4.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold4 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold4 step 3 start !!! ==============="
                ./batch_SVM_condor_fold4.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold4.sh
                echo "============== fold4 step 3 finished !! ==============="
            fi

        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold4*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold4 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold4.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold4.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold4 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold4 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold4.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold4.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold4 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold4_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold4 step 3 start !!! ==============="
                ./batch_SVM_condor_fold4.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold4.sh
                echo "============== fold4 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py

    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold5_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold5 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold5.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold5.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold5 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold5 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold5.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold5.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold5 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold5 step 3 start !!! ==============="
                ./batch_SVM_condor_fold5.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold5.sh
                echo "============== fold5 step 3 finished !! ==============="
            fi

        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold5 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold5.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold5.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold5 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold5 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold5.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold5.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold5 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold5 step 3 start !!! ==============="
                ./batch_SVM_condor_fold5.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold5.sh
                echo "============== fold5 step 3 finished !! ==============="
            fi
        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold5 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold5.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold5.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold5 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold5 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold5.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold5.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold5 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold5 step 3 start !!! ==============="
                ./batch_SVM_condor_fold5.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold5.sh
                echo "============== fold5 step 3 finished !! ==============="
            fi
        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold5 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold5.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold5.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold5 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold5 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold5.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold5.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold5 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold5 step 3 start !!! ==============="
                ./batch_SVM_condor_fold5.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold5.sh
                echo "============== fold5 step 3 finished !! ==============="
            fi
        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold5*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold5 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold5.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold5.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold5 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold5 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold5.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold5.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold5 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold5_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold5 step 3 start !!! ==============="
                ./batch_SVM_condor_fold5.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold5.sh
                echo "============== fold5 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py


    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold6_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold6*
        continue 
    else
        if [ $i -eq 0 ];then 
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
        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
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
        elif [ $i -eq 2 ];then 
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
        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
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
        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
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
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py
    

    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold7_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold7 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold7.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold7.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold7 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold7 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold7.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold7.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold7 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold7 step 3 start !!! ==============="
                ./batch_SVM_condor_fold7.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold7.sh
                echo "============== fold7 step 3 finished !! ==============="
            fi
        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold7 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold7.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold7.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold7 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold7 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold7.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold7.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold7 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold7 step 3 start !!! ==============="
                ./batch_SVM_condor_fold7.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold7.sh
                echo "============== fold7 step 3 finished !! ==============="
            fi
        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold7 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold7.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold7.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold7 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold7 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold7.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold7.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold7 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold7 step 3 start !!! ==============="
                ./batch_SVM_condor_fold7.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold7.sh
                echo "============== fold7 step 3 finished !! ==============="
            fi
        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold7 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold7.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold7.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold7 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold7 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold7.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold7.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold7 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold7 step 3 start !!! ==============="
                ./batch_SVM_condor_fold7.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold7.sh
                echo "============== fold7 step 3 finished !! ==============="
            fi
        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold7*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold7 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold7.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold7.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold7 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold7 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold7.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold7.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold7 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold7_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold7 step 3 start !!! ==============="
                ./batch_SVM_condor_fold7.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold7.sh
                echo "============== fold7 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py


    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold8_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold8 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold8.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold8.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold8 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold8 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold8.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold8.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold8 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold8 step 3 start !!! ==============="
                ./batch_SVM_condor_fold8.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold8.sh
                echo "============== fold8 step 3 finished !! ==============="
            fi
        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold8 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold8.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold8.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold8 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold8 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold8.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold8.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold8 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold8 step 3 start !!! ==============="
                ./batch_SVM_condor_fold8.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold8.sh
                echo "============== fold8 step 3 finished !! ==============="
            fi
        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold8 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold8.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold8.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold8 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold8 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold8.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold8.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold8 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold8 step 3 start !!! ==============="
                ./batch_SVM_condor_fold8.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold8.sh
                echo "============== fold8 step 3 finished !! ==============="
            fi
        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold8 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold8.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold8.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold8 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold8 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold8.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold8.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold8 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold8 step 3 start !!! ==============="
                ./batch_SVM_condor_fold8.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold8.sh
                echo "============== fold8 step 3 finished !! ==============="
            fi
        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold8*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold8 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold8.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold8.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold8 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold8 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold8.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold8.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold8 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold8_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold8 step 3 start !!! ==============="
                ./batch_SVM_condor_fold8.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold8.sh
                echo "============== fold8 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py



    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold9_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold9 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold9.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold9.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold9 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold9 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold9.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold9.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold9 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold9 step 3 start !!! ==============="
                ./batch_SVM_condor_fold9.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold9.sh
                echo "============== fold9 step 3 finished !! ==============="
            fi
        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold9 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold9.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold9.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold9 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold9 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold9.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold9.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold9 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold9 step 3 start !!! ==============="
                ./batch_SVM_condor_fold9.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold9.sh
                echo "============== fold9 step 3 finished !! ==============="
            fi
        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold9 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold9.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold9.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold9 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold9 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold9.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold9.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold9 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold9 step 3 start !!! ==============="
                ./batch_SVM_condor_fold9.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold9.sh
                echo "============== fold9 step 3 finished !! ==============="
            fi
        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold9 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold9.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold9.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold9 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold9 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold9.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold9.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold9 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold9 step 3 start !!! ==============="
                ./batch_SVM_condor_fold9.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold9.sh
                echo "============== fold9 step 3 finished !! ==============="
            fi
        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold9*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold9 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold9.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold9.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold9 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold9 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold9.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold9.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold9 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold9_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold9 step 3 start !!! ==============="
                ./batch_SVM_condor_fold9.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold9.sh
                echo "============== fold9 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py

    
    if [ -f "/home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/out_22_${mon[${i}]}_fold10_training" ];then
        rm /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10*
        continue 
    else
        if [ $i -eq 0 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold10 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold10.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold10.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold10 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold10 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold10.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold10.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold10 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold10 step 3 start !!! ==============="
                ./batch_SVM_condor_fold10.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold10.sh
                echo "============== fold10 step 3 finished !! ==============="
            fi
        elif [ $i -eq 1 ];then 
            until [ $df_value -gt 150 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold10 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold10.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold10.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold10 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold10 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold10.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold10.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold10 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold10 step 3 start !!! ==============="
                ./batch_SVM_condor_fold10.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold10.sh
                echo "============== fold10 step 3 finished !! ==============="
            fi
        elif [ $i -eq 2 ];then 
            until [ $df_value -gt 110 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold10 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold10.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold10.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold10 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold10 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold10.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold10.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold10 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold10 step 3 start !!! ==============="
                ./batch_SVM_condor_fold10.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold10.sh
                echo "============== fold10 step 3 finished !! ==============="
            fi
        elif [ $i -eq 3 ];then 
            until [ $df_value -gt 730 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold10 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold10.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold10.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold10 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold10 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold10.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold10.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold10 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold10 step 3 start !!! ==============="
                ./batch_SVM_condor_fold10.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold10.sh
                echo "============== fold10 step 3 finished !! ==============="
            fi
        elif [ $i -eq 4 ];then 
            until [ $df_value -gt 400 ]
            do
                echo "wait until df -H is enough"
                sleep 10m
            done        
            cd /home/hpc/intel_parking/iParking/data/sensor/
            
            #check whether preprocess has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            #check whether weka_preprocess_resample.sh has been done or not, if done, remove them
            if [ -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                rm weka_${mon[${i}]}_fold10*
            fi
        
        
            if [ $start -le 1 ]; then
                echo "=============== ${mon[${i}]}  fold10 start !!!  ==============="
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
        
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_testing.norm.fix.arff.gz" ]; then
                    cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            	    ./batch_format_convert_mat_arff_testing_fold10.sh -m ${mon[${i}]}  
                    ./batch_format_convert_mat_arff_training_fold10.sh -m ${mon[${i}]}
                fi
            	echo "=============== ${mon[${i}]} fold10 step 1 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/preprocess/
            if [ $start -le 2 ]; then
                echo "=============== ${mon[${i}]}  fold10 step 2 start !!!  ==============="
                #step 4
                if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balancearff.gz" ]; then
                    ./weka_preprocess_resample_testing_fold10.sh -m ${mon[${i}]}
            	    ./weka_preprocess_resample_training_fold10.sh -m ${mon[${i}]} 
                fi
                echo "=============== ${mon[${i}]} fold10 step 2 finished !! ==============="
            fi
            cd /home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/
            chmod 777 ./*
            if [ ! -f "/home/hpc/intel_parking/iParking/data/sensor/SVM_sampling/${mon[${i}]}/weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz" ]; then
                echo "weka_${mon[${i}]}_fold10_training.norm.fix.fltr.balance.arff.gz doesn't exist"
            fi
            cd /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/
            if [ $start -le 3 ]; then
            	echo "=============== ${mon[${i}]} fold10 step 3 start !!! ==============="
                ./batch_SVM_condor_fold10.sh -m ${mon[${i}]}
                chmod 777 ./*
                ./all_${mon[${i}]}_fold10.sh
                echo "============== fold10 step 3 finished !! ==============="
            fi
        fi
    fi
    python /home/hpc/intel_parking/iParking/git_repository/ml_weka/script/fig8a/SVM/job_list_all.py    
done
