#get all running job_name
from subprocess import check_output
f=open('job_id_all.txt','r')
g=open('job_all.txt','w')
for line in f.readlines():
    line=line.replace("\n","")
    job=check_output(["qstat -f %s |grep -A1 'Job_Name'"%(line)],shell=True)
    g.write(job)
f.close()
g.close()
