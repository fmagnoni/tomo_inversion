#!/bin/bash

#MSUB -n 24450    
#MSUB -N 1529 
##MSUB -n 300    
##MSUB -N 19         
#MSUB -c 1     

#MSUB -A ra2410
#MSUB -r SPECFEM3D    
##MSUB -T 1800 
#MSUB -x        
#MSUB -o output_sol_%I.o     
#MSUB -e output_sol_%I.e     
#MSUB -@ federica.magnoni@ingv.it :begin
#MSUB -@ federica.magnoni@ingv.it :end

#magnoni: '-q standard' does not need to be specified if it is passed to ccc_msub in submit_all_MPI_Italy.sh

set -x  #magnoni: maybe not required if -x is in the previous directives

# ${BRIDGE_MSUB_PWD} is an environment variable that represents the directory from which the job is submitted
##########################
submit.sh adv_start.sh

cd ${BRIDGE_MSUB_PWD}/CMTs_2
ccc_mprun ./bin/xspecfem3D
submit.sh launch_processing.ipy.sh

cd ${BRIDGE_MSUB_PWD}/CMTs_3
ccc_mprun ./bin/xspecfem3D
submit.sh launch_processing.ipy.sh

cd ${BRIDGE_MSUB_PWD}/CMTs_4
ccc_mprun ./bin/xspecfem3D
submit.sh launch_processing.ipy.sh

cd ${BRIDGE_MSUB_PWD}/CMTs_5
ccc_mprun ./bin/xspecfem3D
submit.sh launch_processing.ipy.sh

cd ${BRIDGE_MSUB_PWD}

while [ ! -f CMTs_5/misfit_value.txt ]
do
  sleep 60
done

while [ ! -f CMTs_4/misfit_value.txt ]
do
  sleep 60
done

while [ ! -f CMTs_3/misfit_value.txt ]
do
  sleep 60
done

while [ ! -f CMTs_2/misfit_value.txt ]
do
  sleep 60
done


cd ${BRIDGE_MSUB_PWD}
date


get_best_steplength.py CMTs_?/misfit*txt
for F in *steplengthext.*
do 
mv $F ../full_$F
done

######COMMENTED OUT, VERY SPECIFIC FOR IMAGINE_IT

# cd ${BRIDGE_MSUB_PWD}/CMTs_2
# rm misfit_value.txt
# remove_eastadria.py
# runipy misfit.ipynb
#
# cd ${BRIDGE_MSUB_PWD}/CMTs_3
# rm misfit_value.txt
# remove_eastadria.py
# runipy misfit.ipynb
#
# cd ${BRIDGE_MSUB_PWD}/CMTs_4
# rm misfit_value.txt
# remove_eastadria.py
# runipy misfit.ipynb
#
# cd ${BRIDGE_MSUB_PWD}/CMTs_5
# rm misfit_value.txt
# remove_eastadria.py
# runipy misfit.ipynb
#
# cd ${BRIDGE_MSUB_PWD}
#
# while [ ! -f CMTs_5/misfit_value.txt ]
# do
#   sleep 60
# done
#
# while [ ! -f CMTs_4/misfit_value.txt ]
# do
#   sleep 60
# done
#
# while [ ! -f CMTs_3/misfit_value.txt ]
# do
#   sleep 60
# done
#
# while [ ! -f CMTs_2/misfit_value.txt ]
# do
#   sleep 60
# done

######


BEST_STEP=`get_best_steplength.py CMTs_?/misfit*txt`
echo $BEST_STEP
mv *steplengthext.* ../
cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*external*.bin CMTs_adj/run0001/OUTPUT_FILES/DATABASES_MPI
cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*external*.bin CMTs_adj/run0082/OUTPUT_FILES/DATABASES_MPI
cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin CMTs_adj/run0001/OUTPUT_FILES/DATABASES_MPI
cp $BEST_STEP/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin CMTs_adj/run0082/OUTPUT_FILES/DATABASES_MPI

mv $BEST_STEP CMTs
echo $BEST_STEP > VTKFILES/best.txt
iteration_id=`basename "${BRIDGE_MSUB_PWD}"`
tar cfv $CCCSTOREDIR/Backup/ITALY_5k/vtkfiles_${iteration_id}.tar VTKFILES &
rm -rf CMTs_? &

cd ${BRIDGE_MSUB_PWD}/CMTs
include_eastadria.py
cd ${BRIDGE_MSUB_PWD}

submit.sh execute_adjoint.sh

while [ ! -f CMTs/sem_OK.flag ]
do
  sleep 60
done
rm CMTs/sem_OK.flag

check_sem.py

cd CMTs_adj 

for DIR in run????
do
    echo $DIR
    cp $DIR/DATA/Par_file_noatt_saveforw $DIR/DATA/Par_file
done

#SAVE_FORWARD
ccc_mprun -n 12150 ./bin/xspecfem3D_1_81

sleep 2

for DIR in run????
do
    cp $DIR/DATA/Par_file_noatt_adjoint $DIR/DATA/Par_file
done

ccc_quota

#ADJOINT
ccc_mprun -n 12150 ./bin/xspecfem3D_1_81
sleep 2

ccc_quota

rm -f run0*/OUTPUT_FILES/DATABASES_MPI/*absorb_field*

for DIR in run????
do
    echo $DIR
    cp $DIR/DATA/Par_file_noatt_saveforw $DIR/DATA/Par_file
done
ccc_quota
#SAVE_FORWARD
ccc_mprun -n 12300 ./bin/xspecfem3D_82_163
ccc_quota
sleep 2

for DIR in run????
do
    cp $DIR/DATA/Par_file_noatt_adjoint $DIR/DATA/Par_file
done


#ADJOINT
ccc_mprun -n 12300 ./bin/xspecfem3D_82_163
sleep 2
ccc_quota

rm -f run0*/OUTPUT_FILES/DATABASES_MPI/*absorb_field*

#kernel.sh
submit_kernel.sh kernel.sh
