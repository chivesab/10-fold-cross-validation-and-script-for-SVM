# 10-fold-cross-validation-and-script fo SVM


Yu-Che Lin @ National Taiwan University


----------------------------------------
 Preprocessing
----------------------------------------

Step1. mkfold.sh
    
    call mkfold.py, make data into ten fold has average positive and negative labels.
    
Step2. job_list_all.py
    
    create file job_list_all.txt, if job completes, change state of that job into 'c', if job is incomplete, mark it as 'i', if job is   running,get its job-id and updates it in the job_list_all.txt

Step3. fetch.py
   
    get the job-id which is running and record them.
    
Step4. count_label.py
    
    check which label is chnaged from 1 to -1 due to the proprecessing step ( fix labeling preprocess )
    
    
------------------------------------------
 SVM script for 10-fold cross validation
------------------------------------------


Step1. batch_SVM_condor_fold1.sh 
    
    (a). This script will write a all_${month}_fold1.sh , which call eval_SVM_fold1.sh script to use SVM
    
    (b). we have batch_SVM_condor_fold2.sh to batch_SVM_condor_fold10.sh due to 10-cv, each one is a little bit different from the others.
         Each of the batch script will call eval_SVM_fold2.sh to eval_SVM_fold10.sh, and each of eval_SVM_*.sh script will call eval_pred.py
         to calculate confustion matrix, precision, recall rate, accuracy and f1 score.
Step2. script_SVM_all.sh
    
    (a). A automation script would preprocess data including merging data_month.norm.fix.txt and label_month.fix.txt into weka file, removing attributes
         from 73 to 78, balancing and sampling weka files.
    
    (b). Check whether Disk size if enough, if not, sleep for disk size if enought and then continue.
    
    (c). Deciding which job should be dispatch by reading job_list_all.txt to check the state of job.
    
    (d). Serially to finish each month 10-fold jobs and going on to next month jobs.



-----------------------------------------------
 Too huge to train ---> sampling 
-----------------------------------------------
