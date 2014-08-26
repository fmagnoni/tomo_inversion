#!/bin/bash

echo `date`

CURRDIR="/lscratch/users/magnoni/SPECFEM3D/trunk_update"
cd $CURRDIR
pwd

slice_file="slice_list"
sum_kernel_dir="/lscratch/users/magnoni/SPECFEM3D/sum_kernel/OUTPUT_SUM"
model="m03_03_pre"
dir_a="alpha"
dir_a_pre="alpha_precon"
dir_b="beta"
dir_b_pre="beta_precon"
dir_r="rho"
dir_r_pre="rho_precon"
output_files_dir=${CURRDIR}"/in_out_files/OUTPUT_FILES_COMBINE"


filename_a="alpha_kernel"
input_dir_a_1=${sum_kernel_dir}"/"${model}"/"${dir_a}"/"
input_dir_a_2=${sum_kernel_dir}"/"${model}"/"${dir_a_pre}"/"
output_dir_a_1=${sum_kernel_dir}"/"${model}"/"${dir_a}"/"
output_dir_a_2=${sum_kernel_dir}"/"${model}"/"${dir_a_pre}"/"

filename_b="beta_kernel"
input_dir_b_1=${sum_kernel_dir}"/"${model}"/"${dir_b}"/"
input_dir_b_2=${sum_kernel_dir}"/"${model}"/"${dir_b_pre}"/"
output_dir_b_1=${sum_kernel_dir}"/"${model}"/"${dir_b}"/"
output_dir_b_2=${sum_kernel_dir}"/"${model}"/"${dir_b_pre}"/"

filename_r="rho_kernel"
input_dir_r_1=${sum_kernel_dir}"/"${model}"/"${dir_r}"/"
input_dir_r_2=${sum_kernel_dir}"/"${model}"/"${dir_r_pre}"/"
output_dir_r_1=${sum_kernel_dir}"/"${model}"/"${dir_r}"/"
output_dir_r_2=${sum_kernel_dir}"/"${model}"/"${dir_r_pre}"/"


####### alpha_kern

echo ./bin/xcombine_vol_data ${slice_file} ${filename_a} ${input_dir_a_1} ${output_dir_a_1} 1
./bin/xcombine_vol_data ${slice_file} ${filename_a} ${input_dir_a_1} ${output_dir_a_1} 1 > ${output_files_dir}/out_comb_${dir_a}

####### beta_kern 

./bin/xcombine_vol_data ${slice_file} ${filename_b} ${input_dir_b_1} ${output_dir_b_1} 1 > ${output_files_dir}/out_comb_${dir_b}

####### rho_kern 

./bin/xcombine_vol_data ${slice_file} ${filename_r} ${input_dir_r_1} ${output_dir_r_1} 1 > ${output_files_dir}/out_comb_${dir_r}

####### alpha_kern_precon

./bin/xcombine_vol_data ${slice_file} ${filename_a} ${input_dir_a_2} ${output_dir_a_2} 1 > ${output_files_dir}/out_comb_${dir_a_pre}

####### beta_kern_precon

./bin/xcombine_vol_data ${slice_file} ${filename_b} ${input_dir_b_2} ${output_dir_b_2} 1 > ${output_files_dir}/out_comb_${dir_b_pre}

####### rho_kern_precon

./bin/xcombine_vol_data ${slice_file} ${filename_r} ${input_dir_r_2} ${output_dir_r_2} 1 > ${output_files_dir}/out_comb_${dir_r_pre}

mkdir -p ${output_files_dir}/${model}
mv ${output_files_dir}/out_comb_* ${output_files_dir}/${model}

echo `date`

echo 'success'

