#!/bin/sh
#MSUB -n 176   
#MSUB -N 11
#MSUB -A ra2410
#MSUB -r FLEXWIN_MADJ_SEM     
#MSUB -x        
#MSUB -o FMS_sol_%I.o     
#MSUB -e FMS_sol_%I.e     
#MSUB -@ federica.magnoni@ingv.it :begin,end
#MSUB -Q test
#MSUB -T 1800
#MSUB -q standard


cd ${BRIDGE_MSUB_PWD}
#date

#BEST_STEP=`get_best_steplength.py CMTs_?/misfit*txt`
#echo $BEST_STEP
#cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*external*.bin CMTs_adj/run0001/OUTPUT_FILES/DATABASES_MPI
#cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*external*.bin CMTs_adj/run0062/OUTPUT_FILES/DATABASES_MPI
#cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin CMTs_adj/run0001/OUTPUT_FILES/DATABASES_MPI
#cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin CMTs_adj/run0062/OUTPUT_FILES/DATABASES_MPI

#mv $BEST_STEP CMTs
cd CMTs
pwd

echo "Launching controller"
ipcontroller --ip='*' & > tmp.log
sleep 10

date

echo "Launching engines"
srun ipengine & >> tmp.log
sleep 10

date

echo "Launching job"
#runipy process_only_data.ipynb --html processing_data.html
export CLEAN_MADJ='True'
echo $FLAG_CREATE_MSEED,$FLAG_PROCESSING_SYNT,$PROCESSING_FLEXWIN,$PROCESSING_MADJ,$CLEAN_MADJ,$CALCULATE_MISFIT
runipy processing_flexwin_madj.ipynb --html processing.html
#python test.py

date

echo "Done!"

echo 'done' > sem_OK.flag


#check_sem.py
#cd ../CMTs_adj 
#submit.sh script_2step.sh
