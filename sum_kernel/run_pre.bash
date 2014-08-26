#!/bin/bash

###########################################################
# USER PARAMETERS

# set this to your directory which contains all event kernel directories
outputs_kernel_directory="/lscratch/users/magnoni/SPECFEM3D/trunk_update/in_out_files/DATABASES_MPI"
# set the model num and optionally the step factor
model="m01_04_pre"

###########################################################


# update kernel links
cd INPUT_KERNELS/
rm -rf ./*_*
ln -s ${outputs_kernel_directory}/after_*_${model} ./
cd ..
# 
# # update input kernel list
ls -1 INPUT_KERNELS/ > kernels_run_italy

# # link proc*external_mesh.bin
cd INPUT_KERNELS/
ln -s ${outputs_kernel_directory}/proc*external_mesh.bin .
cd ..

# compiles
cd src/
make -f Makefile_all clean
make -f Makefile_all sum_preconditioning_event_kernels
cd ..

# runs job
date
qsub go_pbs_pre.bash

