#!/bin/bash
#PBS -S /bin/bash

## job name and output file
#PBS -N model_upd
#PBS -j oe
#PBS -o in_out_files/OUTPUT_FILES_MODEL_UPD/job.o

###########################################################
# USER PARAMETERS

#PBS -l select=256:ncpus=1,walltime=8:00:00

numnodes=256

###########################################################

echo `date`

CURRDIR="/lscratch/users/magnoni/SPECFEM3D/trunk_update"
cd $CURRDIR
pwd

step_fac=0.04
model="m02"
model_dir="m02_04"

# obtain lsf job information
cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES_MODEL_UPD/compute_nodes
echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES_MODEL_UPD/jobid

cd bin/
echo mpirun -n $numnodes ./xmodel_update ${step_fac}
mpirun -n $numnodes ./xmodel_update ${step_fac}
cd ..

echo "success"

mv in_out_files/OUTPUT_FILES/output_solver.txt in_out_files/OUTPUT_FILES_MODEL_UPD/

cd in_out_files/OUTPUT_FILES_MODEL_UPD/
mkdir ${model_dir}
mv compute_nodes jobid *minmax* output_solver.txt *vs_vp* scaled_gradients step_fac ${model_dir}
cd $CURRDIR

cd in_out_files/DATABASES_MPI
mv mesh_files_${model} mesh_files_${model_dir}
mv proc*vb.bin proc*poisson.bin mesh_files_${model_dir}
mkdir mesh_files_${model}
cd $CURRDIR


echo `date`
