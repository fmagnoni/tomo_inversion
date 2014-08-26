#!/bin/bash
#PBS -S /bin/bash

## job name and output file
#PBS -N smooth_kern
#PBS -j oe
#PBS -o in_out_files/OUTPUT_FILES_SMOOTH/job.o

###########################################################
# USER PARAMETERS

#PBS -l select=256:ncpus=1,walltime=8:00:00

numnodes=256

###########################################################

echo `date`

CURRDIR="/lscratch/users/magnoni/SPECFEM3D/trunk_update"
cd $CURRDIR
pwd

slice_file="slice_list"
sum_kernel_dir_in="/lscratch/users/magnoni/SPECFEM3D/sum_kernel/OUTPUT_SUM"
sum_kernel_dir_out="/lscratch/users/magnoni/SPECFEM3D/sum_kernel/OUTPUT_SUM_SMOOTH"
model="m03_03_pre"
dir_a="alpha"
dir_a_pre="alpha_precon"
dir_b="beta"
dir_b_pre="beta_precon"
dir_r="rho"
dir_r_pre="rho_precon"
sigma_h_1="5000"
sigma_h_2="5000"
sigma_v="1000"

filename_a="alpha_kernel"
filename_a_s="alpha_kernel_smooth"
input_dir_a_1=${sum_kernel_dir_in}"/"${model}"/"${dir_a}"/"
echo $input_dir_a_1
input_dir_a_2=${sum_kernel_dir_in}"/"${model}"/"${dir_a_pre}"/"
echo $input_dir_a_2
output_dir_a_1=${sum_kernel_dir_out}"/"${model}"/"${dir_a}"/"${sigma_h_1}"_"${sigma_v}"/"
echo $output_dir_a_1
output_dir_a_2=${sum_kernel_dir_out}"/"${model}"/"${dir_a_pre}"/"${sigma_h_2}"_"${sigma_v}"/"
echo $output_dir_a_2

filename_b="beta_kernel"
filename_b_s="beta_kernel_smooth"
input_dir_b_1=${sum_kernel_dir_in}"/"${model}"/"${dir_b}"/"
input_dir_b_2=${sum_kernel_dir_in}"/"${model}"/"${dir_b_pre}"/"
output_dir_b_1=${sum_kernel_dir_out}"/"${model}"/"${dir_b}"/"${sigma_h_1}"_"${sigma_v}"/"
output_dir_b_2=${sum_kernel_dir_out}"/"${model}"/"${dir_b_pre}"/"${sigma_h_2}"_"${sigma_v}"/"

filename_r="rho_kernel"
filename_r_s="rho_kernel_smooth"
input_dir_r_1=${sum_kernel_dir_in}"/"${model}"/"${dir_r}"/"
input_dir_r_2=${sum_kernel_dir_in}"/"${model}"/"${dir_r_pre}"/"
output_dir_r_1=${sum_kernel_dir_out}"/"${model}"/"${dir_r}"/"${sigma_h_1}"_"${sigma_v}"/"
output_dir_r_2=${sum_kernel_dir_out}"/"${model}"/"${dir_r_pre}"/"${sigma_h_2}"_"${sigma_v}"/"


####### alpha_kern 5000_1000

# obtain lsf job information
cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES_SMOOTH/compute_nodes_a_${sigma_h_1}_${sigma_v}
echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES_SMOOTH/jobid_a_${sigma_h_1}_${sigma_v}

mkdir -p ${output_dir_a_1}

cd bin/
#esempio:
# mpirun -n nprocs ./xsmooth_vol_data filename input_dir output_dir sigma_h sigma_v
echo mpirun -n $numnodes ./xsmooth_vol_data ${filename_a} ${input_dir_a_1} ${output_dir_a_1} ${sigma_h_1} ${sigma_v}
mpirun -n $numnodes ./xsmooth_vol_data ${filename_a} ${input_dir_a_1} ${output_dir_a_1} ${sigma_h_1} ${sigma_v}
cd ..

./bin/xcombine_vol_data ${slice_file} ${filename_a_s} ${output_dir_a_1} ${output_dir_a_1} 1


####### alpha_kern_precon 5000_1000

# obtain lsf job information
cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES_SMOOTH/compute_nodes_a_pre_${sigma_h_2}_${sigma_v}
echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES_SMOOTH/jobid_a_pre_${sigma_h_2}_${sigma_v}

mkdir -p ${output_dir_a_2}

cd bin/
echo mpirun -n $numnodes ./xsmooth_vol_data ${filename_a} ${input_dir_a_2} ${output_dir_a_2} ${sigma_h_2} ${sigma_v}
mpirun -n $numnodes ./xsmooth_vol_data ${filename_a} ${input_dir_a_2} ${output_dir_a_2} ${sigma_h_2} ${sigma_v}
cd ..

./bin/xcombine_vol_data ${slice_file} ${filename_a_s} ${output_dir_a_2} ${output_dir_a_2} 1


####### beta_kern 5000_1000

# obtain lsf job information
cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES_SMOOTH/compute_nodes_b_${sigma_h_1}_${sigma_v}
echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES_SMOOTH/jobid_b_${sigma_h_1}_${sigma_v}

mkdir -p ${output_dir_b_1}

cd bin/
echo mpirun -n $numnodes ./xsmooth_vol_data ${filename_b} ${input_dir_b_1} ${output_dir_b_1} ${sigma_h_1} ${sigma_v}
mpirun -n $numnodes ./xsmooth_vol_data ${filename_b} ${input_dir_b_1} ${output_dir_b_1} ${sigma_h_1} ${sigma_v}
cd ..

./bin/xcombine_vol_data ${slice_file} ${filename_b_s} ${output_dir_b_1} ${output_dir_b_1} 1


####### beta_kern_precon 5000_1000

# obtain lsf job information
cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES_SMOOTH/compute_nodes_b_pre_${sigma_h_2}_${sigma_v}
echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES_SMOOTH/jobid_b_pre_${sigma_h_2}_${sigma_v}

mkdir -p ${output_dir_b_2}

cd bin/
echo mpirun -n $numnodes ./xsmooth_vol_data ${filename_b} ${input_dir_b_2} ${output_dir_b_2} ${sigma_h_2} ${sigma_v}
mpirun -n $numnodes ./xsmooth_vol_data ${filename_b} ${input_dir_b_2} ${output_dir_b_2} ${sigma_h_2} ${sigma_v}
cd ..

./bin/xcombine_vol_data ${slice_file} ${filename_b_s} ${output_dir_b_2} ${output_dir_b_2} 1


####### rho_kern 5000_1000

# obtain lsf job information
cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES_SMOOTH/compute_nodes_r_${sigma_h_1}_${sigma_v}
echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES_SMOOTH/jobid_r_${sigma_h_1}_${sigma_v}

mkdir -p ${output_dir_r_1}

cd bin/
echo mpirun -n $numnodes ./xsmooth_vol_data ${filename_r} ${input_dir_r_1} ${output_dir_r_1} ${sigma_h_1} ${sigma_v}
mpirun -n $numnodes ./xsmooth_vol_data ${filename_r} ${input_dir_r_1} ${output_dir_r_1} ${sigma_h_1} ${sigma_v}
cd ..

./bin/xcombine_vol_data ${slice_file} ${filename_r_s} ${output_dir_r_1} ${output_dir_r_1} 1


####### rho_kern_precon 5000_1000

# obtain lsf job information
cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES_SMOOTH/compute_nodes_r_pre_${sigma_h_2}_${sigma_v}
echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES_SMOOTH/jobid_r_pre_${sigma_h_2}_${sigma_v}

mkdir -p ${output_dir_r_2}

cd bin/
echo mpirun -n $numnodes ./xsmooth_vol_data ${filename_r} ${input_dir_r_2} ${output_dir_r_2} ${sigma_h_2} ${sigma_v}
mpirun -n $numnodes ./xsmooth_vol_data ${filename_r} ${input_dir_r_2} ${output_dir_r_2} ${sigma_h_2} ${sigma_v}
cd ..

./bin/xcombine_vol_data ${slice_file} ${filename_r_s} ${output_dir_r_2} ${output_dir_r_2} 1

mkdir -p in_out_files/OUTPUT_FILES_SMOOTH/${model}
mv in_out_files/OUTPUT_FILES_SMOOTH/compute_nodes_* in_out_files/OUTPUT_FILES_SMOOTH/jobid_* in_out_files/OUTPUT_FILES_SMOOTH/${model}

echo `date`

echo 'success'

