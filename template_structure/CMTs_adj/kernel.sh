#!/bin/bash

#MSUB -n 160    
#MSUB -N 10     
#MSUB -c 1     

#MSUB -A ra2410
#MSUB -r KERNEL    
#MSUB -x        
#MSUB -o kernel_%I.o     
#MSUB -e kernel_%I.e     
#MSUB -@ federica.magnoni@ingv.it :begin,end

# ${BRIDGE_MSUB_PWD} is an environment variable that represents the directory from which the job is submitted
cd ${BRIDGE_MSUB_PWD}

##########################

mkdir INPUT_KERNELS
mkdir OUTPUT_SUM
mkdir OUTPUT_MODEL_2
mkdir OUTPUT_MODEL_3
mkdir OUTPUT_MODEL_4
mkdir OUTPUT_MODEL_5
rm kernels_list.txt

touch kernels_list.txt
 
for r in run????
do

if [ -d ${r}_zerosem ]
then

  rm -r ${r}

elif [ -d ${r}_eastadria ]
then

  rm -r ${r}

else

 cd INPUT_KERNELS
 ln -s ../$r/OUTPUT_FILES/DATABASES_MPI $r
 cd ..
 echo $r >> kernels_list.txt

fi

done

mkdir OUTPUT_FILES
cd OUTPUT_FILES
ln -s ../run0001/OUTPUT_FILES/DATABASES_MPI DATABASES_MPI
cd ..

#
ccc_mprun -n 150 ./xsum_preconditioned_kernels
#
ccc_mprun -n 150 ./xsmooth_sem 10000 3000 alpha_kernel OUTPUT_SUM/ OUTPUT_SUM/
ccc_mprun -n 150 ./xsmooth_sem 10000 3000 beta_kernel OUTPUT_SUM/ OUTPUT_SUM/
ccc_mprun -n 150 ./xsmooth_sem 10000 3000 rho_kernel OUTPUT_SUM/ OUTPUT_SUM/
ccc_mprun -n 150 ./xmodel_update 0.03 OUTPUT_SUM/ OUTPUT_MODEL_3/
ccc_mprun -n 150 ./xmodel_update 0.02 OUTPUT_SUM/ OUTPUT_MODEL_2/
ccc_mprun -n 150 ./xmodel_update 0.04 OUTPUT_SUM/ OUTPUT_MODEL_4/
ccc_mprun -n 150 ./xmodel_update 0.05 OUTPUT_SUM/ OUTPUT_MODEL_5/

mkdir VTKFILES
mkdir VTKFILES/F2
mkdir VTKFILES/F3
mkdir VTKFILES/F4
mkdir VTKFILES/F5

xcombine_vol_data 0 149 beta_kernel OUTPUT_SUM/ VTKFILES 0 & 
xcombine_vol_data 0 149 alpha_kernel OUTPUT_SUM/ VTKFILES 0 &
xcombine_vol_data 0 149 rho_kernel OUTPUT_SUM/ VTKFILES 0 &
xcombine_vol_data 0 149 beta_kernel_smooth OUTPUT_SUM/ VTKFILES 0 &
xcombine_vol_data 0 149 alpha_kernel_smooth OUTPUT_SUM/ VTKFILES 0 &
xcombine_vol_data 0 149 rho_kernel_smooth OUTPUT_SUM/ VTKFILES 0 &

for FAC in {2,3,4,5}
do
echo 'model update ' $FAC
xcombine_vol_data 0 149 drhorho OUTPUT_MODEL_${FAC}/ VTKFILES/F${FAC}/ 0 &
xcombine_vol_data 0 149 dvsvs OUTPUT_MODEL_${FAC}/ VTKFILES/F${FAC}/ 0 &
xcombine_vol_data 0 149 dvpvp OUTPUT_MODEL_${FAC}/ VTKFILES/F${FAC}/ 0 &
xcombine_vol_data 0 149 vp_new OUTPUT_MODEL_${FAC}/ VTKFILES/F${FAC}/ 0 &
xcombine_vol_data 0 149 vs_new OUTPUT_MODEL_${FAC}/ VTKFILES/F${FAC}/ 0 &
xcombine_vol_data 0 149 rho_new OUTPUT_MODEL_${FAC}/ VTKFILES/F${FAC}/ 0 &

done

cd ..
iteration_id=`basename "${PWD}"`
echo ${iteration_id}
create_mseed.py *
tar cfv $CCCSTOREDIR/Backup/ITALY_5k/mseed_${iteration_id}.tar CMTs/run*_proce*.mseed 



