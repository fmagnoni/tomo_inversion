#!/bin/sh
#MSUB -n 176   
#MSUB -N 11           
#MSUB -A ra2410
#MSUB -r FLEXWIN_MADJ_SEM     
#MSUB -x        
#MSUB -o FMS_patch_sol_%I.o     
#MSUB -e FMS_patch_sol_%I.e     
#MSUB -@ federica.magnoni@ingv.it :begin,end
##MSUB -Q test
##MSUB -T 1800
#MSUB -q standard


cd ${BRIDGE_MSUB_PWD}
date
submit.sh ../adv_start.sh
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
export FLAG_CREATE_MSEED='True'
export FLAG_PROCESSING_SYNT='True'
export PROCESSING_FLEXWIN='True'
export PROCESSING_MADJ='True'
export CLEAN_MADJ='False'
export CALCULATE_MISFIT='True'
echo $FLAG_CREATE_MSEED,$FLAG_PROCESSING_SYNT,$PROCESSING_FLEXWIN,$PROCESSING_MADJ,$CLEAN_MADJ,$CALCULATE_MISFIT
runipy processing_flexwin_madj.ipynb --html processing.html
#python test.py

date

echo "Done!"
