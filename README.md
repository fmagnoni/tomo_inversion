tomo_inversion
==============

Routines to update the initial model and process the sensitivity kernels
(based on the code downloaded in 2011)


Sum Kernels
-----------

In a subdirectory sum_kernel/

1. copy file SPECFEM3D/trunk_update/src/shared/constants.h 
   over to:  src/constants.h

   copy file SPECFEM3D/trunk_update/src/shared/precision.h 
   over to:  src/precision.h

   copy file SPECFEM3D/trunk_update/config.h 
   over to:  src/config.h

2. set the user parameters in go_pbs.bash or go_pbs_pre.bash

3. set the user parameters in run.bash or run_pre.bash

4. set the name of the considered kernel in a file called ftags

5. set THRESHOLD_HESS and USE_HESS_SUM = true in src/sum_preconditioning_event_kernels.f90

6. To obtain summed kernels launch
   > ./run.bash
   
   To obtain summed and preconditioned kernels launch
   > ./run_pre.bash
   
NB. The hessian kernels used as preconditioner are calculated during the adjoint simulation together with the other kernels if APPROXIMATE_HESS_KL = .true. in constants.h.
   
   

Combine summed kernels (w and w/o preconditioning) into .mesh files
-----------------------------------------------------------------

Check that in an input dir (e.g., sum_kernel/OUPUT_SUM/$model/$kernel_name) the kernel files *_kernel.bin are present

In the directory of specfem3d

1. in the Par_file set LOCAL_PATH at the path where the proc*external_mesh.bin of the considered model are

2. create a file slice_list with the list of the processor ids (e.g. for 256 cores write a list from 0 to 255)

3. set some user parameters in go_combine_all.bash (for high resolution kernels)

4. compile combine_vol_data.f90 
   > make combine_vol_data

5. launch
   > ./go_combine_all.bash
   
(to combine low resolution kernels just write 0 istead of 1 as fifth argument passed to xcombine_vol_data in go_combine_all.bash)
   
   
   
Smooth summed kernels (w and w/o preconditioning) and combine them into .mesh files
-----------------------------------------------------------------------------------

Check that in an input dir (e.g., sum_kernel/OUPUT_SUM/$model/$kernel_name) the kernel files *_kernel.bin are present and create an output dir for the smoothed kernels (e.g., sum_kernel/OUTPUT_SUM_SMOOTH) 

In the directory of specfem3d

1. in the Par_file set LOCAL_PATH at the path where the proc*external_mesh.bin of the considered model are

2. check that smooth_vol_data.f90 is in src/shared and that Makefile contain the lines to compile it

3. set some user parameters in go_smooth_all.bash (for high resolution kernels)

4. compile smooth_vol_data.f90
   > make smooth_vol_data
   
5. create a file slice_list with the list of the processor ids (e.g. for 256 cores write a list from 0 to 255)

6. compile combine_vol_data.f90 
   > make combine_vol_data

7. launch
   > qsub go_smooth_all.bash
   (a Gaussian smoothing is applied)

(to combine low resolution smoothed kernels just write 0 istead of 1 as fifth argument passed to xcombine_vol_data in go_smooth_all.bash)


Model Update
------------

Takes isotropic model and isotropic kernels and makes a steepest descent model update
The new models vp, vs, rho and the new *external_mesh.bin are then computed from the old ones, assuming that the gradients/kernels relate relative model perturbations dln(m/m0) to traveltime/multitaper measurements.

In the directory of specfem3d

1. setup in go_model_update.bash  :
    numnodes
    working directories 
    step_fac (e.g., 0.04) 
    model (e.g., m02)
    model_dir  (e.g., m02_04)
    
2. setup in src/specfem3D/model_update.f90 :
    LOCAL_PATH_NEW
    OUTPUT_MODEL_UPD
    INPUT_KERNELS  
    USE_ALPHA_BETA_RHO
    USE_RHO_SCALING
    RHO_SCALING
    PRINT_OUT_FILES
    if you want to threshold the model
      MINMAX_THRESHOLD_OLD=true 
      MINMAX_THRESHOLD_NEW=true
      and set VS_MIN, VS_MAX, VP_MIN, VP_MAX,RHO_MIN, RHO_MAX

3. in the Par_file set : 
    NPROC
    LOCAL_PATH to the directory where the proc000***_external_mesh.bin and proc000***_attenuation.vtk (if attenuation is on) for the OLD model are (usually in_out_files/DATABASES_MPI)
    SAVE_MESH_FILES=true if you want *vp_new.bin *vs_new.bin…and the corresponding *.vtk, otherwise set to false (proc000***_external_mesh.bin and proc000***_attenuation.bin will be written anyway)

4. check that the proc000***_external_mesh.bin and proc000***_attenuation.vtk for the OLD model are in in_out_files/DATABASES_MPI/

5. create symbolic link 'DATABASES_MPI/sum_smooth_kern/ ' to alpha, beta and rho summed smoothed kernel 
    > cd DATABASES_MPI/sum_smooth_kern/
    > ln -s /my_summed_smoothed_event_kernel_directory/*kernel_smooth.bin ./
    where 
    my_summed_smoothed_event_kernel_directory =…..SPECFEM3D/sum_kernel/OUTPUT_SUM_SMOOTH/m??/kernel_name/smooth_fac/*smooth.bin  
    m??/  directory of the considered model number
    kernel_name/  directory of the considered kernel type (e.g., alpha_kern or beta_kern or rho_kern)
    smooth_fac/  directory of the considered smoothing

    Same thing for preconditioned summed kernels that must be in DATABASES_MPI/sum_smooth_kern_pre/

6. check that in the Makefile in the maindir and in src/specfem3D there are the rules to compile model_update.f90

7. check that there are the directories
    in_out_files/DATABASES_MPI/mesh_files_m??/   where the mesh files for the NEW model will be written
    in_out_files/OUTPUT_FILES_MODEL_UPD/    where the output files of model_update will be written 

8. compile from the maindir 
    > make model_update

9. lauch 
    > qsub go_model_update.bash









