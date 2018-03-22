import numpy as np
import pandas as np
import matplotlib.pyplot as plt
import pylab as pl
#matplotlib.use('Agg')
#import tkinter
#import _tkinter

# calculating average, maximum and minimum
# --------------------------#
g=open("mean_201603.txt",'w')
p=open("over_average_201603.txt",'w')
for i in range(1,109):
    f_txt="f_{}.txt".format(i)
    List=[]
    with open(f_txt) as f:
        for line in f:
           List.append(float(line)) 
    ave=np.mean(List)
    maximum=max(List)
    minimum=min(List)
    std=np.std(List,ddof=1)
    cv=std*float(100)/ave
    g.write("f_{} mean= {}, max= {}, min={},std={},cv={}% ".format(i,ave,maximum,minimum,std,cv)+'\n')
    if cv>25000:
        p.write("f_{} mean= {}, max= {}, min={},std={},cv={}% ".format(i,ave,maximum,minimum,std,cv)+'\n')
    List[:]=[]
    f.close()
g.close()
p.close()

# -------------------------- #

x=range(108)
y=List3
pl.plot(x,y)
pl.show()



#matplotlib inline
#%config InlineBackend.figure_format='retina'

#def normfun(x,mu,sigma):
#    pdf=np.exp(-((x-mu)**2)/(2*sigma**2))/(sigma*np.sqrt(2*np.pi))
#    return pdf

#x=List2
#y=normfun(x,mean2,std2)
#plt.hist(mean2, bins=10, rwidth=0.9, normed=True)
#plt.title('F-15 distirbution')
#plt.xlabel('F-15')
#plt.ylabel('probability')
#plr.show()










