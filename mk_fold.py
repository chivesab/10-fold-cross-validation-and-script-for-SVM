# -*- coding: UTF-8 -*-
# make label_posindex_month.txt and label_negindex_month.txt 
import sys
import numpy as np

if (len(sys.argv)<1):
    print "format: ./mk_fold.sh -m month"
month=sys.argv[1]

## === select positive and negative ========
data_month='data_'+month+'.txt'
label_month='label_'+month+'.txt'
label_posindex='label_posindex_'+month+'.txt'
label_negindex='label_negindex_'+month+'.txt'
lpind=open(label_posindex,'w')
lnind=open(label_negindex,'w')
with open(label_month,'r') as label:
    ldata=[line.strip() for line in label]
    label_list_pos=[i for i,element in enumerate(ldata) if element =='1'] #positive index in label_month.txt
    label_list_neg=[i for i,element in enumerate(ldata) if element =='-1'] #negative index in label_month.txt
    lpind.write('\n'.join(map(str,label_list_pos)))
    lnind.write('\n'.join(map(str,label_list_neg)))
lpind.close()
lnind.close()
#c=0
#multiple=1
#with open(data_month,'r') as data:  #write fold data file
#    ddata=[line.strip() for line in data]
#    for multiple in range(1,2):
#        data_pos='data_pos_'+str(multiple)+'_'+month+'.txt'
#        data_posw=open(data_pos,'w')
#        for i in range (c,len(label_list_pos)*multiple/10):
#            print 'multiple={}'.format(multiple)
#            print "c={}, len(label_list_pos*multiple/10={}".format(c,len(label_list_pos)*multiple/10)
#            print 'label_list_pos[i]={}'.format(label_list_pos[i])
#            for k in range(0,len(ddata)):
#                if (label_list_pos[i]==[j for j, element in enumerate(ddata)][k]):
#                    data_posw.write("%s" %element+'\n')
#                    break
#        c=len(label_list_pos)*multiple/10
#        data_posw.close()
#    c=0        
#    for multiple in range(1,10):
#        data_neg='data_neg_'+str(multiple)+'_'+month+'.txt'
#        data_negw=open(data_neg,'w')
#        for i in range(0,len(label_list_neg)/10):
#            if (label_list_neg[i]==[r for r, element in enumerate(ddata)]):
#                data_negw.write("%s" %element +'\n')
#                continue
#        c=len(label_list_neg)*multiple/10
#data_posw.close()
#data_negw.close()
lpind=open(label_posindex,'r')
lnind=open(label_negindex,'r')
number_of_lpind=len(lpind.readlines())
number_of_lnind=len(lnind.readlines())
print '# of negative= ',number_of_lnind
print '# of positive= ',number_of_lpind
num_of_fold_pos=number_of_lpind/10
num_of_fold_neg=number_of_lnind/10
print '# of fold negative= ',num_of_fold_neg
print '# of fold positive= ',num_of_fold_pos
