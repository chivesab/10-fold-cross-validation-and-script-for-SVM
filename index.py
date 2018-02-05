import sys,os, subprocess
month=sys.argv[1]

## =====  For cluster ===============================================

DATA_PATH='/home/hpc/intel_parking/iParking/data/sensor/cv_fold/'

## ==================================================================

label_posind=DATA_PATH+'label_posindex_'+month+'.txt'
label_negind=DATA_PATH+'label_negindex_'+month+'.txt'


for j in range(1,11):
    label_testing='label_'+month+'_testing_fold'+str(j)+'.txt'
    label_training='label_'+month+'_training_fold'+str(j)+'.txt'
    data_testing_pos='data_'+month+'_testing_fold'+str(j)+'_pos.txt'
    data_testing_neg='data_'+month+'_testing_fold'+str(j)+'_neg.txt'
    data_testing='data_'+month+'_testing_fold'+str(j)+'.txt'
    data_training_pos='data_'+month+'_training_fold'+str(j)+'_pos.txt'
    data_training_neg='data_'+month+'_training_fold'+str(j)+'_neg.txt'
    data_training='data_'+month+'_training_fold'+str(j)+'.txt'
    if os.path.exists(label_testing):
        subprocess.call(["rm label_%s_testing_fold%d.txt" %(month,j)],shell=True)
    if os.path.exists(label_training): 
        subprocess.call(["rm label_%s_training_fold%d.txt"%(month,j)],shell=True)
    if os.path.exists(data_testing_pos):
        subprocess.call(["rm data_%s_testing_fold%d_pos.txt" %(month,j)],shell=True)
    if os.path.exists(data_testing_neg):
        subprocess.call(["rm data_%s_testing_fold%d_neg.txt" %(month,j)],shell=True)
    if os.path.exists(data_testing):
        subprocess.call(["rm data_%s_testing_fold%d.txt" %(month,j)],shell=True)
    if os.path.exists(data_training_pos):
        subprocess.call(["rm data_%s_training_fold%d_pos.txt" %(month,j)],shell=True)
    if os.path.exists(data_training_neg):
        subprocess.call(["rm data_%s_training_fold%d_neg.txt" %(month,j)],shell=True)
    if os.path.exists(data_training):
        subprocess.call(["rm data_%s_training_fold%d.txt" %(month,j)],shell=True)

## =========== make label_month_testing_fold(1~10).txt ====================================================
index_pos=[]
f=open(label_posind,'r')
for line in f.readlines():
    index_pos.append(line)
length_pos=len(index_pos)
f.close()

index_neg=[]
f=open(label_negind,'r')
for line in f.readlines():
    index_neg.append(line)
length_neg=len(index_neg)
f.close()

c=1
for c in range(1,11):
    label_fold_testing='label_'+month+'_testing_fold'+str(c)+'.txt'
    label_foldopen=open(label_fold_testing,'a')
    for i in range(0,length_pos/10):
        label_foldopen.write('1\n')
    for j in range(0,length_neg/10):
        label_foldopen.write('-1\n')
    label_foldopen.close()
    label_fold_training='label_'+month+'_training_fold'+str(c)+'.txt'
    label_foldopen2=open(label_fold_training,'a')
    for i in range(0,(length_pos*9/10)):
        label_foldopen2.write('1\n')
    for j in range(0,(length_neg*9/10)):
        label_foldopen2.write('-1\n')
    label_foldopen2.close()

length_fold_pos=length_pos/10
length_fold_neg=length_neg/10


## ==============make data_month_testing_fold(1~10)_pos.txt ============================================
## ==============make data_month_training_fold(1~10)_pos.txt ============================================


data_all=DATA_PATH+'data_'+month+'.txt'
z=0
for i in range(1,11):
    if i==1:
        print 'i=',i
        context=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context.append(line)
            #context=[x.strip() for x in dread]
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold1_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold1_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==2:
        print 'i=',i
        context2=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context2.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold2_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold2_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==3:
        print 'i=',i
        context3=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context3.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold3_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold3_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==4:
        print 'i=',i
        context4=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context4.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold4_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold4_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==5:
        print 'i=',i
        context5=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context5.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold5_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold5_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==6:
        print 'i=',i
        context6=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context6.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold6_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold6_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==7:
        print 'i=',i
        context7=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context7.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold7_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold7_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==8:
        print 'i=',i
        context8=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context8.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold8_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold8_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==9:
        print 'i=',i
        context9=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context9.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold9_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold9_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==10:
        print 'i=',i
        context10=[]
        d=open(label_posind,'r')
        for line in d.readlines()[z:length_fold_pos*i]:
            line=line.strip()
            context10.append(line)
        z=length_fold_pos*i
        for k in range(0,length_fold_pos):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold10_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' <%s >> data_%s_training_fold10_pos.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()

##=============  make data_month_testing_fold(1~10)_neg.txt ================================
##=============  make data_month_training_fold(1~10)_neg.txt ===============================

z=0
for i in range(1,11):
    if i==1:
        print 'i=',i
        context=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context.append(line)
            #context=[x.strip() for x in dread]
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
#            print 'context[k]=',context[k]
#            print 'type context[k]=',type(context[k])
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold1_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold1_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==2:
        print 'i=',i
        context2=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context2.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold2_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold2_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==3:
        print 'i=',i
        context3=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context3.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold3_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold3_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==4:
        print 'i=',i
        context4=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context4.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold4_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold4_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==5:
        print 'i=',i
        context5=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context5.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold5_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold5_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==6:
        print 'i=',i
        context6=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context6.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold6_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold6_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==7:
        print 'i=',i
        context7=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context7.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold7_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold7_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==8:
        print 'i=',i
        context8=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context8.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold8_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold8_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==9:
        print 'i=',i
        context9=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context9.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold9_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold9_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()
    elif i==10:
        print 'i=',i
        context10=[]
        d=open(label_negind,'r')
        for line in d.readlines()[z:length_fold_neg*i]:
            line=line.strip()
            context10.append(line)
        z=length_fold_neg*i
        for k in range(0,length_fold_neg):
            subprocess.call(["sed -e '%s !d' < %s >> data_%s_testing_fold10_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
            subprocess.call(["sed -e '%s d' < %s >> data_%s_training_fold10_neg.txt" %(str(int(context[k])+1),data_all,month)], shell=True)
        d.close()






## ==============  merging testing data file fold(1~10) =====================================================================
## ==============  merging data_month_testing_fold(1~10)_pos.txt and data_month_testing_fold(1~10)_neg.txt===================

for i in range(1,11):
    test1=DATA_PATH+'data_'+month+'testing_fold'+str(i)+'_pos.txt'
    test1=DATA_PATH+'data_'+month+'testing_fold'+str(i)+'_neg.txt'
    filename=[test1,test2] #type(filename)=list, filename[0]=test1
    test_all='data_'+month+'testing_fold'+str(i)+'.txt' 
    with open(test_all, 'w') as outfile: 
        for fname in filename: #test1 and test2
            with open(fname) as infile: #open test1 (first) and test2(secondly) 
                for line in infile: #text in test1
                    outfile.write(line)   #write into file
    outfile.close()
    infile.close() 


## ============== merging training data file fold(1~10) =====================================================================
## ============== merging data_month_training_fold(1~10)_pos.txt and data_month_training_fold(1~10)_pos.txt =================

for i in range(1,11):
    test1=DATA_PATH+'data_'+month+'training_fold'+str(i)+'_pos.txt'
    test1=DATA_PATH+'data_'+month+'training_fold'+str(i)+'_neg.txt'
    filename=[test1,test2] #type(filename)=list, filename[0]=test1
    test_all='data_'+month+'training_fold'+str(i)+'.txt' 
    with open(test_all, 'w') as outfile: 
        for fname in filename: #test1 and test2
            with open(fname) as infile: #open test1 (first) and test2(secondly) 
                for line in infile: #text in test1
                    outfile.write(line)   #write into file
    outfile.close()
    infile.close() 



