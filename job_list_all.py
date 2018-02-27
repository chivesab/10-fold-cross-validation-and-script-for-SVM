import pandas as pd
import numpy as np
import subprocess
import os.path, sys
from subprocess import call
if os.path.exists('job_id_all.txt'):
    subprocess.call(["cp job_id_all.txt job_id_compare_all.txt"],shell=True)

MONTH=["201504","FCBF_SVM","Cfs_SVM","R22_SVM","R43_SVM","R65_SVM","R86_SVM","R108_SVM","201510","FCBF_SVM","Cfs_SVM","R22_SVM","R43_SVM","R65_SVM","R86_SVM","R108_SVM","201604","FCBF_SVM","Cfs_SVM","R22_SVM","R43_SVM","R65_SVM","R86_SVM","R108_SVM","201610","FCBF_SVM","Cfs_SVM","R22_SVM","R43_SVM","R65_SVM","R86_SVM","R108_SVM","201703","FCBF_SVM","Cfs_SVM","R22_SVM","R43_SVM","R65_SVM","R86_SVM","R108_SVM"]
MONTH_for_arrange=["201504","FCBF_SVM  ","Cfs_SVM   ","R22_SVM   ","R43_SVM   ","R65_SVM   ","R86_SVM   ","R108_SVM  ","201510","FCBF_SVM  ","Cfs_SVM   ","R22_SVM   ","R43_SVM   ","R65_SVM   ","R86_SVM   ","R108_SVM  ","201604","FCBF_SVM  ","Cfs_SVM   ","R22_SVM   ","R43_SVM   ","R65_SVM   ","R86_SVM   ","R108_SVM  ","201610","FCBF_SVM  ","Cfs_SVM   ","R22_SVM   ","R43_SVM   ","R65_SVM   ","R86_SVM   ","R108_SVM  ","201703","FCBF_SVM  ","Cfs_SVM   ","R22_SVM   ","R43_SVM   ","R65_SVM   ","R86_SVM   ","R108_SVM  "]
fold1=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold2=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold3=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold4=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold5=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold6=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold7=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold8=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold9=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]
fold10=["","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i","","i","i","i","i","i","i","i"]

pbs=".pbs"
job_id_list=[]
num_output=subprocess.check_output(["qstat -u intel_parking|wc -l"],shell=True)
num_output=int(num_output)+1
g=open('job_id_all.txt','w')
for i in range(6,num_output):
    job_id=subprocess.check_output(["qstat -u intel_parking| sed -n '%ip' | awk '{print $1}'" %(i)],shell=True)
    if pbs in job_id:
        job_id=job_id.replace(pbs,"")
        if '\n' in job_id:
             job_id=job_id.replace('\n','')
        fold=subprocess.check_output(["qstat -f %s |grep 'Job_Name'| grep -o -P 'fold.{0,2}'|head -n 1"%(job_id)],shell=True)
        fold=fold[4:6]
        if fold=='10':
            dict={'id':job_id,'fold':fold}
        else:
            fold=fold.replace('_','')
            dict={'id':job_id,'fold':fold}
        g.write("%s"%(job_id)+'\n')
        job_id_list.append(job_id)
        month=subprocess.check_output(["qstat -f %s|grep 'Job_Name'|grep -o -P 'Train.{0,6}'"%(job_id)],shell=True)
        if '\n' in month:
            month=month.replace('\n','')
        if 'Train' in month:
            month=month.replace('Train','')
        dict['month']=month
        feature=subprocess.check_output(["qstat -f %s|grep 'Job_Name'"%(job_id)],shell=True)
        if feature[22:28]=='RANKER':
            if feature[28:30]=='22':
                dict['feature']='RANKER22'
            elif feature[28:30]=='43':
                dict['feature']='RANKER43'
            elif feature[28:30]=='65':
                dict['feature']='RANKER65'
            elif feature[28:30]=='86':
                dict['feature']='RANKER86'
            elif feature[28:31]=='108':
                dict['feature']='RANKER108'
        elif feature[22:26]=='FCBF':
            dict['feature']='FCBF'
        elif feature[22:25]=='CFs':
            dict['feature']='Cfs'
#        print dict
        if dict['fold']=='6':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold6[1]=dict['id']
               elif dict['month']=='201510':
                   fold6[9]=dict['id']
               elif dict['month']=='201604':
                   fold6[17]=dict['id']
               elif dict['month']=='201610':
                   fold6[25]=dict['id']
               elif dict['month']=='201703':
                   fold6[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold6[2]=dict['id']
               elif dict['month']=='201510':
                   fold6[10]=dict['id']
               elif dict['month']=='201604':
                   fold6[18]=dict['id']
               elif dict['month']=='201610':
                   fold6[26]=dict['id']
               elif dict['month']=='201703':
                   fold6[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold6[3]=dict['id']
               elif dict['month']=='201510':
                   fold6[11]=dict['id']
               elif dict['month']=='201604':
                   fold6[19]=dict['id']
               elif dict['month']=='201610':
                   fold6[27]=dict['id']
               elif dict['month']=='201703':
                   fold6[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold6[4]=dict['id']
               elif dict['month']=='201510':
                   fold6[12]=dict['id']
               elif dict['month']=='201604':
                   fold6[20]=dict['id']
               elif dict['month']=='201610':
                   fold6[28]=dict['id']
               elif dict['month']=='201703':
                   fold6[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold6[5]=dict['id']
               elif dict['month']=='201510':
                   fold6[13]=dict['id']
               elif dict['month']=='201604':
                   fold6[21]=dict['id']
               elif dict['month']=='201610':
                   fold6[29]=dict['id']
               elif dict['month']=='201703':
                   fold6[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold6[6]=dict['id']
               elif dict['month']=='201510':
                   fold6[14]=dict['id']
               elif dict['month']=='201604':
                   fold6[22]=dict['id']
               elif dict['month']=='201610':
                   fold6[30]=dict['id']
               elif dict['month']=='201703':
                   fold6[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold6[7]=dict['id']
               elif dict['month']=='201510':
                   fold6[15]=dict['id']
               elif dict['month']=='201604':
                   fold6[23]=dict['id']
               elif dict['month']=='201610':
                   fold6[31]=dict['id']
               elif dict['month']=='201703':
                   fold6[39]=dict['id']
        elif dict['fold']=='7':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold7[1]=dict['id']
               elif dict['month']=='201510':
                   fold7[9]=dict['id']
               elif dict['month']=='201604':
                   fold7[17]=dict['id']
               elif dict['month']=='201610':
                   fold7[25]=dict['id']
               elif dict['month']=='201703':
                   fold7[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold7[2]=dict['id']
               elif dict['month']=='201510':
                   fold7[10]=dict['id']
               elif dict['month']=='201604':
                   fold7[18]=dict['id']
               elif dict['month']=='201610':
                   fold7[26]=dict['id']
               elif dict['month']=='201703':
                   fold7[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold7[3]=dict['id']
               elif dict['month']=='201510':
                   fold7[11]=dict['id']
               elif dict['month']=='201604':
                   fold7[19]=dict['id']
               elif dict['month']=='201610':
                   fold7[27]=dict['id']
               elif dict['month']=='201703':
                   fold7[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold7[4]=dict['id']
               elif dict['month']=='201510':
                   fold7[12]=dict['id']
               elif dict['month']=='201604':
                   fold7[20]=dict['id']
               elif dict['month']=='201610':
                   fold7[28]=dict['id']
               elif dict['month']=='201703':
                   fold7[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold7[5]=dict['id']
               elif dict['month']=='201510':
                   fold7[13]=dict['id']
               elif dict['month']=='201604':
                   fold7[21]=dict['id']
               elif dict['month']=='201610':
                   fold7[29]=dict['id']
               elif dict['month']=='201703':
                   fold7[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold7[6]=dict['id']
               elif dict['month']=='201510':
                   fold7[14]=dict['id']
               elif dict['month']=='201604':
                   fold7[22]=dict['id']
               elif dict['month']=='201610':
                   fold7[30]=dict['id']
               elif dict['month']=='201703':
                   fold7[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold7[7]=dict['id']
               elif dict['month']=='201510':
                   fold7[15]=dict['id']
               elif dict['month']=='201604':
                   fold7[23]=dict['id']
               elif dict['month']=='201610':
                   fold7[31]=dict['id']
               elif dict['month']=='201703':
                   fold7[39]=dict['id']
        elif dict['fold']=='8':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold8[1]=dict['id']
               elif dict['month']=='201510':
                   fold8[9]=dict['id']
               elif dict['month']=='201604':
                   fold8[17]=dict['id']
               elif dict['month']=='201610':
                   fold8[25]=dict['id']
               elif dict['month']=='201703':
                   fold8[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold8[2]=dict['id']
               elif dict['month']=='201510':
                   fold8[10]=dict['id']
               elif dict['month']=='201604':
                   fold8[18]=dict['id']
               elif dict['month']=='201610':
                   fold8[26]=dict['id']
               elif dict['month']=='201703':
                   fold8[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold8[3]=dict['id']
               elif dict['month']=='201510':
                   fold8[11]=dict['id']
               elif dict['month']=='201604':
                   fold8[19]=dict['id']
               elif dict['month']=='201610':
                   fold8[27]=dict['id']
               elif dict['month']=='201703':
                   fold8[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold8[4]=dict['id']
               elif dict['month']=='201510':
                   fold8[12]=dict['id']
               elif dict['month']=='201604':
                   fold8[20]=dict['id']
               elif dict['month']=='201610':
                   fold8[28]=dict['id']
               elif dict['month']=='201703':
                   fold8[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold8[5]=dict['id']
               elif dict['month']=='201510':
                   fold8[13]=dict['id']
               elif dict['month']=='201604':
                   fold8[21]=dict['id']
               elif dict['month']=='201610':
                   fold8[29]=dict['id']
               elif dict['month']=='201703':
                   fold8[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold8[6]=dict['id']
               elif dict['month']=='201510':
                   fold8[14]=dict['id']
               elif dict['month']=='201604':
                   fold8[22]=dict['id']
               elif dict['month']=='201610':
                   fold8[30]=dict['id']
               elif dict['month']=='201703':
                   fold8[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold8[7]=dict['id']
               elif dict['month']=='201510':
                   fold8[15]=dict['id']
               elif dict['month']=='201604':
                   fold8[23]=dict['id']
               elif dict['month']=='201610':
                   fold8[31]=dict['id']
               elif dict['month']=='201703':
                   fold8[39]=dict['id']
        elif dict['fold']=='9':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold9[1]=dict['id']
               elif dict['month']=='201510':
                   fold9[9]=dict['id']
               elif dict['month']=='201604':
                   fold9[17]=dict['id']
               elif dict['month']=='201610':
                   fold9[25]=dict['id']
               elif dict['month']=='201703':
                   fold9[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold9[2]=dict['id']
               elif dict['month']=='201510':
                   fold9[10]=dict['id']
               elif dict['month']=='201604':
                   fold9[18]=dict['id']
               elif dict['month']=='201610':
                   fold9[26]=dict['id']
               elif dict['month']=='201703':
                   fold9[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold9[3]=dict['id']
               elif dict['month']=='201510':
                   fold9[11]=dict['id']
               elif dict['month']=='201604':
                   fold9[19]=dict['id']
               elif dict['month']=='201610':
                   fold9[27]=dict['id']
               elif dict['month']=='201703':
                   fold9[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold9[4]=dict['id']
               elif dict['month']=='201510':
                   fold9[12]=dict['id']
               elif dict['month']=='201604':
                   fold9[20]=dict['id']
               elif dict['month']=='201610':
                   fold9[28]=dict['id']
               elif dict['month']=='201703':
                   fold9[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold9[5]=dict['id']
               elif dict['month']=='201510':
                   fold9[13]=dict['id']
               elif dict['month']=='201604':
                   fold9[21]=dict['id']
               elif dict['month']=='201610':
                   fold9[29]=dict['id']
               elif dict['month']=='201703':
                   fold9[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold9[6]=dict['id']
               elif dict['month']=='201510':
                   fold9[14]=dict['id']
               elif dict['month']=='201604':
                   fold9[22]=dict['id']
               elif dict['month']=='201610':
                   fold9[30]=dict['id']
               elif dict['month']=='201703':
                   fold9[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold9[7]=dict['id']
               elif dict['month']=='201510':
                   fold9[15]=dict['id']
               elif dict['month']=='201604':
                   fold9[23]=dict['id']
               elif dict['month']=='201610':
                   fold9[31]=dict['id']
               elif dict['month']=='201703':
                   fold9[39]=dict['id']
        elif dict['fold']=='10':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold10[1]=dict['id']
               elif dict['month']=='201510':
                   fold10[9]=dict['id']
               elif dict['month']=='201604':
                   fold10[17]=dict['id']
               elif dict['month']=='201610':
                   fold10[25]=dict['id']
               elif dict['month']=='201703':
                   fold10[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold10[2]=dict['id']
               elif dict['month']=='201510':
                   fold10[10]=dict['id']
               elif dict['month']=='201604':
                   fold10[18]=dict['id']
               elif dict['month']=='201610':
                   fold10[26]=dict['id']
               elif dict['month']=='201703':
                   fold10[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold10[3]=dict['id']
               elif dict['month']=='201510':
                   fold10[11]=dict['id']
               elif dict['month']=='201604':
                   fold10[19]=dict['id']
               elif dict['month']=='201610':
                   fold10[27]=dict['id']
               elif dict['month']=='201703':
                   fold10[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold10[4]=dict['id']
               elif dict['month']=='201510':
                   fold10[12]=dict['id']
               elif dict['month']=='201604':
                   fold10[20]=dict['id']
               elif dict['month']=='201610':
                   fold10[28]=dict['id']
               elif dict['month']=='201703':
                   fold10[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold10[5]=dict['id']
               elif dict['month']=='201510':
                   fold10[13]=dict['id']
               elif dict['month']=='201604':
                   fold10[21]=dict['id']
               elif dict['month']=='201610':
                   fold10[29]=dict['id']
               elif dict['month']=='201703':
                   fold10[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold10[6]=dict['id']
               elif dict['month']=='201510':
                   fold10[14]=dict['id']
               elif dict['month']=='201604':
                   fold10[22]=dict['id']
               elif dict['month']=='201610':
                   fold10[30]=dict['id']
               elif dict['month']=='201703':
                   fold10[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold10[7]=dict['id']
               elif dict['month']=='201510':
                   fold10[15]=dict['id']
               elif dict['month']=='201604':
                   fold10[23]=dict['id']
               elif dict['month']=='201610':
                   fold10[31]=dict['id']
               elif dict['month']=='201703':
                   fold10[39]=dict['id']
        elif dict['fold']=='1':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold1[1]=dict['id']
               elif dict['month']=='201510':
                   fold1[9]=dict['id']
               elif dict['month']=='201604':
                   fold1[17]=dict['id']
               elif dict['month']=='201610':
                   fold1[25]=dict['id']
               elif dict['month']=='201703':
                   fold1[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold1[2]=dict['id']
               elif dict['month']=='201510':
                   fold1[10]=dict['id']
               elif dict['month']=='201604':
                   fold1[18]=dict['id']
               elif dict['month']=='201610':
                   fold1[26]=dict['id']
               elif dict['month']=='201703':
                   fold1[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold1[3]=dict['id']
               elif dict['month']=='201510':
                   fold1[11]=dict['id']
               elif dict['month']=='201604':
                   fold1[19]=dict['id']
               elif dict['month']=='201610':
                   fold1[27]=dict['id']
               elif dict['month']=='201703':
                   fold1[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold1[4]=dict['id']
               elif dict['month']=='201510':
                   fold1[12]=dict['id']
               elif dict['month']=='201604':
                   fold1[20]=dict['id']
               elif dict['month']=='201610':
                   fold1[28]=dict['id']
               elif dict['month']=='201703':
                   fold1[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold1[5]=dict['id']
               elif dict['month']=='201510':
                   fold1[13]=dict['id']
               elif dict['month']=='201604':
                   fold1[21]=dict['id']
               elif dict['month']=='201610':
                   fold1[29]=dict['id']
               elif dict['month']=='201703':
                   fold1[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold1[6]=dict['id']
               elif dict['month']=='201510':
                   fold1[14]=dict['id']
               elif dict['month']=='201604':
                   fold1[22]=dict['id']
               elif dict['month']=='201610':
                   fold1[30]=dict['id']
               elif dict['month']=='201703':
                   fold1[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold1[7]=dict['id']
               elif dict['month']=='201510':
                   fold1[15]=dict['id']
               elif dict['month']=='201604':
                   fold1[23]=dict['id']
               elif dict['month']=='201610':
                   fold1[31]=dict['id']
               elif dict['month']=='201703':
                   fold1[39]=dict['id']
        elif dict['fold']=='2':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold2[1]=dict['id']
               elif dict['month']=='201510':
                   fold2[9]=dict['id']
               elif dict['month']=='201604':
                   fold2[17]=dict['id']
               elif dict['month']=='201610':
                   fold2[25]=dict['id']
               elif dict['month']=='201703':
                   fold2[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold2[2]=dict['id']
               elif dict['month']=='201510':
                   fold2[10]=dict['id']
               elif dict['month']=='201604':
                   fold2[18]=dict['id']
               elif dict['month']=='201610':
                   fold2[26]=dict['id']
               elif dict['month']=='201703':
                   fold2[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold2[3]=dict['id']
               elif dict['month']=='201510':
                   fold2[11]=dict['id']
               elif dict['month']=='201604':
                   fold2[19]=dict['id']
               elif dict['month']=='201610':
                   fold2[27]=dict['id']
               elif dict['month']=='201703':
                   fold2[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold2[4]=dict['id']
               elif dict['month']=='201510':
                   fold2[12]=dict['id']
               elif dict['month']=='201604':
                   fold2[20]=dict['id']
               elif dict['month']=='201610':
                   fold2[28]=dict['id']
               elif dict['month']=='201703':
                   fold2[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold2[5]=dict['id']
               elif dict['month']=='201510':
                   fold2[13]=dict['id']
               elif dict['month']=='201604':
                   fold2[21]=dict['id']
               elif dict['month']=='201610':
                   fold2[29]=dict['id']
               elif dict['month']=='201703':
                   fold2[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold2[6]=dict['id']
               elif dict['month']=='201510':
                   fold2[14]=dict['id']
               elif dict['month']=='201604':
                   fold2[22]=dict['id']
               elif dict['month']=='201610':
                   fold2[30]=dict['id']
               elif dict['month']=='201703':
                   fold2[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold2[7]=dict['id']
               elif dict['month']=='201510':
                   fold2[15]=dict['id']
               elif dict['month']=='201604':
                   fold2[23]=dict['id']
               elif dict['month']=='201610':
                   fold2[31]=dict['id']
               elif dict['month']=='201703':
                   fold2[39]=dict['id']
        elif dict['fold']=='3':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold3[1]=dict['id']
               elif dict['month']=='201510':
                   fold3[9]=dict['id']
               elif dict['month']=='201604':
                   fold3[17]=dict['id']
               elif dict['month']=='201610':
                   fold3[25]=dict['id']
               elif dict['month']=='201703':
                   fold3[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold3[2]=dict['id']
               elif dict['month']=='201510':
                   fold3[10]=dict['id']
               elif dict['month']=='201604':
                   fold3[18]=dict['id']
               elif dict['month']=='201610':
                   fold3[26]=dict['id']
               elif dict['month']=='201703':
                   fold3[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold3[3]=dict['id']
               elif dict['month']=='201510':
                   fold3[11]=dict['id']
               elif dict['month']=='201604':
                   fold3[19]=dict['id']
               elif dict['month']=='201610':
                   fold3[27]=dict['id']
               elif dict['month']=='201703':
                   fold3[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold3[4]=dict['id']
               elif dict['month']=='201510':
                   fold3[12]=dict['id']
               elif dict['month']=='201604':
                   fold3[20]=dict['id']
               elif dict['month']=='201610':
                   fold3[28]=dict['id']
               elif dict['month']=='201703':
                   fold3[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold3[5]=dict['id']
               elif dict['month']=='201510':
                   fold3[13]=dict['id']
               elif dict['month']=='201604':
                   fold3[21]=dict['id']
               elif dict['month']=='201610':
                   fold3[29]=dict['id']
               elif dict['month']=='201703':
                   fold3[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold3[6]=dict['id']
               elif dict['month']=='201510':
                   fold3[14]=dict['id']
               elif dict['month']=='201604':
                   fold3[22]=dict['id']
               elif dict['month']=='201610':
                   fold3[30]=dict['id']
               elif dict['month']=='201703':
                   fold3[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold3[7]=dict['id']
               elif dict['month']=='201510':
                   fold3[15]=dict['id']
               elif dict['month']=='201604':
                   fold3[23]=dict['id']
               elif dict['month']=='201610':
                   fold3[31]=dict['id']
               elif dict['month']=='201703':
                   fold3[39]=dict['id']
        elif dict['fold']=='4':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold4[1]=dict['id']
               elif dict['month']=='201510':
                   fold4[9]=dict['id']
               elif dict['month']=='201604':
                   fold4[17]=dict['id']
               elif dict['month']=='201610':
                   fold4[25]=dict['id']
               elif dict['month']=='201703':
                   fold4[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold4[2]=dict['id']
               elif dict['month']=='201510':
                   fold4[10]=dict['id']
               elif dict['month']=='201604':
                   fold4[18]=dict['id']
               elif dict['month']=='201610':
                   fold4[26]=dict['id']
               elif dict['month']=='201703':
                   fold4[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold4[3]=dict['id']
               elif dict['month']=='201510':
                   fold4[11]=dict['id']
               elif dict['month']=='201604':
                   fold4[19]=dict['id']
               elif dict['month']=='201610':
                   fold4[27]=dict['id']
               elif dict['month']=='201703':
                   fold4[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold4[4]=dict['id']
               elif dict['month']=='201510':
                   fold4[12]=dict['id']
               elif dict['month']=='201604':
                   fold4[20]=dict['id']
               elif dict['month']=='201610':
                   fold4[28]=dict['id']
               elif dict['month']=='201703':
                   fold4[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold4[5]=dict['id']
               elif dict['month']=='201510':
                   fold4[13]=dict['id']
               elif dict['month']=='201604':
                   fold4[21]=dict['id']
               elif dict['month']=='201610':
                   fold4[29]=dict['id']
               elif dict['month']=='201703':
                   fold4[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold4[6]=dict['id']
               elif dict['month']=='201510':
                   fold4[14]=dict['id']
               elif dict['month']=='201604':
                   fold4[22]=dict['id']
               elif dict['month']=='201610':
                   fold4[30]=dict['id']
               elif dict['month']=='201703':
                   fold4[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold4[7]=dict['id']
               elif dict['month']=='201510':
                   fold4[15]=dict['id']
               elif dict['month']=='201604':
                   fold4[23]=dict['id']
               elif dict['month']=='201610':
                   fold4[31]=dict['id']
               elif dict['month']=='201703':
                   fold4[39]=dict['id']
        elif dict['fold']=='5':
           if dict['feature']=='FCBF':
               if dict['month']=='201504':
                   fold5[1]=dict['id']
               elif dict['month']=='201510':
                   fold5[9]=dict['id']
               elif dict['month']=='201604':
                   fold5[17]=dict['id']
               elif dict['month']=='201610':
                   fold5[25]=dict['id']
               elif dict['month']=='201703':
                   fold5[33]=dict['id']
           elif dict['feature']=='Cfs':
               if dict['month']=='201504':
                   fold5[2]=dict['id']
               elif dict['month']=='201510':
                   fold5[10]=dict['id']
               elif dict['month']=='201604':
                   fold5[18]=dict['id']
               elif dict['month']=='201610':
                   fold5[26]=dict['id']
               elif dict['month']=='201703':
                   fold5[34]=dict['id']
           elif dict['feature']=='RANKER22':
               if dict['month']=='201504':
                   fold5[3]=dict['id']
               elif dict['month']=='201510':
                   fold5[11]=dict['id']
               elif dict['month']=='201604':
                   fold5[19]=dict['id']
               elif dict['month']=='201610':
                   fold5[27]=dict['id']
               elif dict['month']=='201703':
                   fold5[35]=dict['id']
           elif dict['feature']=='RANKER43':
               if dict['month']=='201504':
                   fold5[4]=dict['id']
               elif dict['month']=='201510':
                   fold5[12]=dict['id']
               elif dict['month']=='201604':
                   fold5[20]=dict['id']
               elif dict['month']=='201610':
                   fold5[28]=dict['id']
               elif dict['month']=='201703':
                   fold5[36]=dict['id']
           elif dict['feature']=='RANKER65':
               if dict['month']=='201504':
                   fold5[5]=dict['id']
               elif dict['month']=='201510':
                   fold5[13]=dict['id']
               elif dict['month']=='201604':
                   fold5[21]=dict['id']
               elif dict['month']=='201610':
                   fold5[29]=dict['id']
               elif dict['month']=='201703':
                   fold5[37]=dict['id']
           elif dict['feature']=='RANKER86':
               if dict['month']=='201504':
                   fold5[6]=dict['id']
               elif dict['month']=='201510':
                   fold5[14]=dict['id']
               elif dict['month']=='201604':
                   fold5[22]=dict['id']
               elif dict['month']=='201610':
                   fold5[30]=dict['id']
               elif dict['month']=='201703':
                   fold5[38]=dict['id']
           elif dict['feature']=='RANKER108':
               if dict['month']=='201504':
                   fold5[7]=dict['id']
               elif dict['month']=='201510':
                   fold5[15]=dict['id']
               elif dict['month']=='201604':
                   fold5[23]=dict['id']
               elif dict['month']=='201610':
                   fold5[31]=dict['id']
               elif dict['month']=='201703':
                   fold5[39]=dict['id']
          
          
          
          
          
                   
                
                
#dict={'id':110949,'fold':10,'feature':'FCBF'}
#qstat -f 110927 |grep 'Job_Name'| grep -o -P 'fold.{0,2}'|head -n 1
#fold=subprocess.check_output(["qstat -f 110927 |grep 'Job_Name'| grep -o -P 'fold.{0,2}'|head -n 1"],shell=True)
#fold=subprocess.check_output(["qstat -f 110949| grep -A1 'Job_Name'| tail -n +2"],shell=True)


#RANKER=subprocess.check_output(["qstat -f 110949| grep 'Job_Name'"],shell=True)
#FCBF=subprocess.check_output(["qstat -f 110944| grep 'Job_Name'"],shell=True)
#CFs=subprocess.check_output(["qstat -f 110945| grep 'Job_Name'"],shell=True)
#print RANKER[22:30]
#print FCBF[22:26]
#print CFs[22:25]
#[id,fold,month,feature]

month_str="201504 201510 201604 201610 201703"
month_str_split=month_str.split()
for word in month_str_split:
    Month=word
    if Month=='201504':
        for number in range(1,11):
            out_file="out_22_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[3]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[3]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[3]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[3]='c'
            elif number==10:
                if os.path.exists(out_file):
                    fold10[3]='c'
            elif number==1:
                if os.path.exists(out_file):
                    fold1[3]='c'
            elif number==2:
                if os.path.exists(out_file):
                    fold2[3]='c'
            elif number==3:
                if os.path.exists(out_file):
                    fold3[3]='c'
            elif number==4:
                if os.path.exists(out_file):
                    fold4[3]='c'
            elif number==5:
                if os.path.exists(out_file):
                    fold5[3]='c'
            out_file="out_43_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[4]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[4]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[4]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[4]='c'
            elif number==10:
                if os.path.exists(out_file):
                    fold10[4]='c'
            elif number==1:
                if os.path.exists(out_file):
                    fold1[4]='c'
            elif number==2:
                if os.path.exists(out_file):
                    fold2[4]='c'
            elif number==3:
                if os.path.exists(out_file):
                    fold3[4]='c'
            elif number==4:
                if os.path.exists(out_file):
                    fold4[4]='c'
            elif number==5:
                if os.path.exists(out_file):
                    fold5[4]='c'
            out_file="out_65_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[5]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[5]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[5]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[5]='c'
            elif number==10:
                if os.path.exists(out_file):
                    fold10[5]='c'
            elif number==1:
                if os.path.exists(out_file):
                    fold1[5]='c'
            elif number==2:
                if os.path.exists(out_file):
                    fold2[5]='c'
            elif number==3:
                if os.path.exists(out_file):
                    fold3[5]='c'
            elif number==4:
                if os.path.exists(out_file):
                    fold4[5]='c'
            elif number==5:
                if os.path.exists(out_file):
                    fold5[5]='c'
            out_file="out_86_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[6]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[6]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[6]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[6]='c'
            elif number==10:
                if os.path.exists(out_file):
                    fold10[6]='c'
            elif number==1:
                if os.path.exists(out_file):
                    fold1[6]='c'
            elif number==2:
                if os.path.exists(out_file):
                    fold2[6]='c'
            elif number==3:
                if os.path.exists(out_file):
                    fold3[6]='c'
            elif number==4:
                if os.path.exists(out_file):
                    fold4[6]='c'
            elif number==5:
                if os.path.exists(out_file):
                    fold5[6]='c'
            out_file="out_108_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[7]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[7]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[7]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[7]='c'
            elif number==10:
                if os.path.exists(out_file):
                    fold10[7]='c'
            elif number==1:
                if os.path.exists(out_file):
                    fold1[7]='c'
            elif number==2:
                if os.path.exists(out_file):
                    fold2[7]='c'
            elif number==3:
                if os.path.exists(out_file):
                    fold3[7]='c'
            elif number==4:
                if os.path.exists(out_file):
                    fold4[7]='c'
            elif number==5:
                if os.path.exists(out_file):
                    fold5[7]='c'
            out_file="out_FCBF_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[1]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[1]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[1]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[1]='c'
            elif number==10:
                if os.path.exists(out_file):
                    fold10[1]='c'
            elif number==1:
                if os.path.exists(out_file):
                    fold1[1]='c'
            elif number==2:
                if os.path.exists(out_file):
                    fold2[1]='c'
            elif number==3:
                if os.path.exists(out_file):
                    fold3[1]='c'
            elif number==4:
                if os.path.exists(out_file):
                    fold4[1]='c'
            elif number==5:
                if os.path.exists(out_file):
                    fold5[1]='c'
            out_file="out_Cfs_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[2]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[2]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[2]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[2]='c'
            elif number==10:
                if os.path.exists(out_file):
                    fold10[2]='c'
            elif number==1:
                if os.path.exists(out_file):
                    fold1[2]='c'
            elif number==2:
                if os.path.exists(out_file):
                    fold2[2]='c'
            elif number==3:
                if os.path.exists(out_file):
                    fold3[2]='c'
            elif number==4:
                if os.path.exists(out_file):
                    fold4[2]='c'
            elif number==5:
                if os.path.exists(out_file):
                    fold5[2]='c'
            

    elif Month=='201510':
        for number in range(6,11):
            out_file="out_22_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[11]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[11]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[11]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[11]='c'
            else:
                if os.path.exists(out_file):
                    fold10[11]='c'
            out_file="out_43_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[12]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[12]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[12]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[12]='c'
            else:
                if os.path.exists(out_file):
                    fold10[12]='c'
            out_file="out_65_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[13]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[13]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[13]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[13]='c'
            else:
                if os.path.exists(out_file):
                    fold10[13]='c'
            out_file="out_86_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[14]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[14]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[14]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[14]='c'
            else:
                if os.path.exists(out_file):
                    fold10[14]='c'
            out_file="out_108_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[15]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[15]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[15]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[15]='c'
            else:
                if os.path.exists(out_file):
                    fold10[15]='c'
            out_file="out_FCBF_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[9]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[9]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[9]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[9]='c'
            else:
                if os.path.exists(out_file):
                    fold10[9]='c'
            out_file="out_Cfs_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[10]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[10]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[10]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[10]='c'
            else:
                if os.path.exists(out_file):
                    fold10[10]='c'

    elif Month=='201604':
        for number in range(6,11):
            out_file="out_22_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[19]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[19]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[19]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[19]='c'
            else:
                if os.path.exists(out_file):
                    fold10[19]='c'
            out_file="out_43_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[20]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[20]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[20]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[20]='c'
            else:
                if os.path.exists(out_file):
                    fold10[20]='c'
            out_file="out_65_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[21]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[21]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[21]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[21]='c'
            else:
                if os.path.exists(out_file):
                    fold10[21]='c'
            out_file="out_86_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[22]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[22]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[22]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[22]='c'
            else:
                if os.path.exists(out_file):
                    fold10[22]='c'
            out_file="out_108_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[23]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[23]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[23]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[23]='c'
            else:
                if os.path.exists(out_file):
                    fold10[23]='c'
            out_file="out_FCBF_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[9]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[17]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[17]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[17]='c'
            else:
                if os.path.exists(out_file):
                    fold10[17]='c'
            out_file="out_Cfs_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[18]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[18]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[18]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[18]='c'
            else:
                if os.path.exists(out_file):
                    fold10[18]='c'

    elif Month=='201610':
        for number in range(6,11):
            out_file="out_22_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[27]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[27]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[27]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[27]='c'
            else:
                if os.path.exists(out_file):
                    fold10[27]='c'
            out_file="out_43_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[28]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[28]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[28]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[28]='c'
            else:
                if os.path.exists(out_file):
                    fold10[28]='c'
            out_file="out_65_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[29]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[29]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[29]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[29]='c'
            else:
                if os.path.exists(out_file):
                    fold10[29]='c'
            out_file="out_86_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[30]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[30]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[30]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[30]='c'
            else:
                if os.path.exists(out_file):
                    fold10[30]='c'
            out_file="out_108_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[31]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[31]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[31]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[31]='c'
            else:
                if os.path.exists(out_file):
                    fold10[31]='c'
            out_file="out_FCBF_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[25]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[25]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[25]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[25]='c'
            else:
                if os.path.exists(out_file):
                    fold10[25]='c'
            out_file="out_Cfs_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[26]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[26]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[26]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[26]='c'
            else:
                if os.path.exists(out_file):
                    fold10[26]='c'

    elif Month=='201703':
        for number in range(6,11):
            out_file="out_22_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[35]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[35]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[35]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[35]='c'
            else:
                if os.path.exists(out_file):
                    fold10[35]='c'
            out_file="out_43_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[36]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[36]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[36]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[36]='c'
            else:
                if os.path.exists(out_file):
                    fold10[36]='c'
            out_file="out_65_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[37]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[37]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[37]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[37]='c'
            else:
                if os.path.exists(out_file):
                    fold10[37]='c'
            out_file="out_86_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[38]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[38]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[38]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[38]='c'
            else:
                if os.path.exists(out_file):
                    fold10[38]='c'
            out_file="out_108_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[39]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[39]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[39]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[39]='c'
            else:
                if os.path.exists(out_file):
                    fold10[39]='c'
            out_file="out_FCBF_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[33]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[33]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[33]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[33]='c'
            else:
                if os.path.exists(out_file):
                    fold10[33]='c'
            out_file="out_Cfs_"+Month+"_fold"+str(number)+"_training"
            if number==6:
                if os.path.exists(out_file):
                    fold6[34]='c'
            elif number==7:
                if os.path.exists(out_file):
                    fold7[34]='c'
            elif number==8:
                if os.path.exists(out_file):
                    fold8[34]='c'
            elif number==9:
                if os.path.exists(out_file):
                    fold9[34]='c'
            else:
                if os.path.exists(out_file):
                    fold10[34]='c'

g.close()





state_dict={ "month           ": MONTH_for_arrange, "fold1": fold1,"fold2":fold2,"fold3":fold3,"fold4":fold4,"fold5":fold5,"fold6":fold6,"fold7":fold7,"fold8":fold8,"fold9":fold9,"fold10":fold10}
state_df=pd.DataFrame(state_dict)
cols=state_df.columns.tolist()
#print 'cols', cols
cols=cols[-1:]+cols[:1]+cols[2:-1]+cols[1:2]
#print 'cols',cols

state_df=state_df[cols]
f=open('job_list_all.txt','w')
state_df.to_csv('job_list_all.txt',sep="\t",index=False,index_label='month')
f.close()

# =========================
# delete month version
# =========================

#call(["cp job_list_all.txt job_list_all_month.txt"],shell=True)
call(["sed -e '3,9 s/^/201504_/' job_list_all.txt > tmp_sed"],shell=True)
call(["sed -e '11,17 s/^/201510_/' tmp_sed > tmp_sed_2"],shell=True)
call(["sed -e '19,25 s/^/201604_/' tmp_sed_2 > tmp_sed_3"],shell=True)
call(["sed -e '27,33 s/^/201610_/' tmp_sed_3 > tmp_sed_4"],shell=True)
call(["sed -e '35,41 s/^/201703_/' tmp_sed_4 > tmp_sed_5"],shell=True)
call(["sed -e '2 d' tmp_sed_5 >tmp_sed_6"],shell=True)
call(["sed -e '9 d' tmp_sed_6 >tmp_sed_7"],shell=True)
call(["sed -e '16 d' tmp_sed_7 >tmp_sed_8"],shell=True)
call(["sed -e '23 d' tmp_sed_8 >tmp_sed_9"],shell=True)
call(["sed -e '30 d' tmp_sed_9 >tmp_sed_10"],shell=True)
call(["mv tmp_sed_10 tmp"],shell=True)
call(["rm tmp_sed_*"],shell=True)





#job complete 
#f=open('job_id_compare_all.txt','r')
#g=open('job_id_all.txt','r')
#id_complete=[]
#Found=False
#for line in f.readlines():
#    for line_2 in g.readlines():
#        if line in line_2:
#            Found=True
#    if not Found:
#        print 'Not Found'
#        id_complete.append(line)
#        for i in range(0,40):
#            if fold6[i]==line:
#                fold6[i]='c'
#            if fold7[i]==line:
#                fold7[i]='c'
#            if fold8[i]==line:
#                fold8[i]='c'
#            if fold9[i]==line:
#                fold9[i]='c'
#            if fold10[i]==line:
#                fold10[i]='c'
#            if fold1[i]==line:
#                fold1[i]='c'
#            if fold2[i]==line:
#                fold2[i]='c'
#            if fold3[i]==line:
#                fold3[i]='c'
#            if fold4[i]==line:
#                fold4[i]='c'
#            if fold5[i]==line:
#                fold5[i]='c'
#f.close()
#g.close()


