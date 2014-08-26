#!/bin/bash
#PBS -S /bin/bash

## job name and output file
#PBS -N sum_k
#PBS -j oe
#PBS -o OUTPUT_FILES/job.o

###########################################################
# USER PARAMETERS

#PBS -l select=256:ncpus=1,walltime=8:00:00

numnodes=256
model="m05_02_pre"
kernel="rho"

###########################################################

#(takes about 10 minutes...)

echo `date`

cd $PBS_O_WORKDIR
pwd

# obtain lsf job information
cat $PBS_NODEFILE > OUTPUT_FILES/compute_nodes
echo "$PBS_JOBID" > OUTPUT_FILES/jobid

mpirun -n $numnodes $PWD/src/sum_preconditioning_event_kernels

cd ./OUTPUT_FILES
mkdir -p ${model}/${kernel}
mv job* compute_nodes ${model}/${kernel}
cd ..

cd ./OUTPUT_SUM
mkdir -p ${model}/${kernel}
mv *kernel.bin ${model}/${kernel}
cd ..
