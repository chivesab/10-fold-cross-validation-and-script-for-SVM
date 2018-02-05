import subprocess,sys
from subprocess import Popen, PIPE
clrecord=open('count_label_record.txt','a')
month='201601'
for i in range(1,11): 
    label_file='label_'+month+'.txt'
    label_fix='label_'+month+'.fix.txt'
    f=open(label_file,'r')
    g=open(label_fix,'r')
    print ('%s' %label_file) 
    subprocess.call(["sed -ne '/^1/p' %s | sed -ne '$='" %(label_file)],shell=True) 
    clrecord.write('%s'%label_file+'\n')
    a=subprocess.check_output(["sed -ne '/^1/p' %s | sed -ne '$='" %(label_file)],shell=True)
    clrecord.write('%s'%a+'\n')
    print ('%s' %label_fix) 
    subprocess.call(["sed -ne '/^1/p' %s | sed -ne '$='" %(label_fix)],shell=True) 
    clrecord.write('%s'%label_fix+'\n')
    b=subprocess.check_output(["sed -ne '/^1/p' %s | sed -ne '$='" %(label_fix)],shell=True)
    clrecord.write('%s'%b+'\n')
    f.close()
    g.close()
    month=str(int(month)+1)

clrecord.close()
