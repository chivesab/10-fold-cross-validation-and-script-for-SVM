./mk_fold.sh -m 201601
./mk_fold.sh -m 201602
./mk_fold.sh -m 201603
./mk_fold.sh -m 201604
./mk_fold.sh -m 201605
./mk_fold.sh -m 201606

chmod 777 ./*
qsub -q long2 -o /home/hpc/intel_parking/iParking/data/sensor/cv_fold/output_201601.txt -e /home/hpc/intel_parking/iParking/data/sensor/cv_fold/error_201601.txt -l walltime=48:00:00 -l nodes=1:ppn=20 index_201601.sh
qsub -q long2 -o /home/hpc/intel_parking/iParking/data/sensor/cv_fold/output_201602.txt -e /home/hpc/intel_parking/iParking/data/sensor/cv_fold/error_201602.txt -l walltime=48:00:00 -l nodes=1:ppn=20 index_201602.sh
qsub -q long2 -o /home/hpc/intel_parking/iParking/data/sensor/cv_fold/output_201603.txt -e /home/hpc/intel_parking/iParking/data/sensor/cv_fold/error_201603.txt -l walltime=48:00:00 -l nodes=1:ppn=20 index_201603.sh
qsub -q long2 -o /home/hpc/intel_parking/iParking/data/sensor/cv_fold/output_201604.txt -e /home/hpc/intel_parking/iParking/data/sensor/cv_fold/error_201604.txt -l walltime=48:00:00 -l nodes=1:ppn=20 index_201604.sh
qsub -q long2 -o /home/hpc/intel_parking/iParking/data/sensor/cv_fold/output_201605.txt -e /home/hpc/intel_parking/iParking/data/sensor/cv_fold/error_201605.txt -l walltime=48:00:00 -l nodes=1:ppn=20 index_201605.sh
qsub -q long2 -o /home/hpc/intel_parking/iParking/data/sensor/cv_fold/output_201606.txt -e /home/hpc/intel_parking/iParking/data/sensor/cv_fold/error_201606.txt -l walltime=48:00:00 -l nodes=1:ppn=20 index_201606.sh
