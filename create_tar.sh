#!/bin/bash

#MSUB -r tar
#MSUB -n 4    
#MSUB -N 1         
#MSUB -o output_tar_%I.o     
#MSUB -e output_tar_%I.e
#MSUB -q standard
#MSUB -A ra2410
#MSUB -x        
##MSUB -Q test
##MSUB -T1000

# number of processes
export NPROC=4

##########################

# ${BRIDGE_MSUB_PWD} is an environment variable that represents the directory from which the job is submitted

##########################

echo "clean"
rm ${RUN_DIR}/CMTs_adj/run*/OUTPUT_FILES/*.semv
rm ${RUN_DIR}/CMTs_adj/run*/OUTPUT_FILES/DATABASES_MPI/proc000*_*.vtk 
rm ${RUN_DIR}/CMTs/run*/OUTPUT_FILES/*.semv
rm ${RUN_DIR}/CMTs_adj/run*/OUTPUT_FILES/DATABASES_MPI/proc000*_save*
rm ${RUN_DIR}/CMTs/run*_mseed/*.S.SAC

echo "tar cvf - ${RUN_DIR} | pigz -p ${NPROC} > ${OUTNAME}.tar.gz"
tar cf - ${RUN_DIR} | pigz -p ${NPROC} > ${OUTNAME}.tar.gz
mv ${OUTNAME}.tar.gz $CCCSTOREDIR/Backup/ITALY_5k/${OUTNAME}.tar.gz

sleep 60

#rm -rf ${RUN_DIR}

