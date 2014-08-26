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
   ./run.bash
   
   To obtain summed and preconditioned kernels launch
   ./run_pre.bash
