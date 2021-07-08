tomo_inversion
==============

Steps to perform a tomographic inversion iteration (so far steepest descent, no attenuation, no anisotropy)

------------------


1. execute_iteration_from_templ.sh

prepares inversion structure and creates dir
iteration_*/
based on template dir template_structure/

then launches:

	1.1 create_tar.sh

	1.2 iteration_*/execute_forward_adjoint.sh
		
		which launches:
	
		1.2.1 iteration_*/adv_start.sh
		
		1.2.2 xspecfem3D for forward simulations
		
		1.2.3 iteration_*/CMTs*/launch_processing.ipy.sh
			which launches:
		
			1.2.3.1 iteration_*/CMTs*/processing_flexwin_madj.ipynb
				processes data and synt
				executes flexwin
				executes measadj
			
		1.2.4 iteration_*/get_best_steplength.py
		
		1.2.5 iteration_*/execute_adjoint.sh
			which launches:
		
			1.2.5.1 iteration_*/CMTs*/processing_flexwin_madj.ipynb
				executes measadj to create adj sources for chosen model update
			
		1.2.6 iteration_*/check_sem.py
		
		1.2.7 xspecfem3D for forward simulations saving fwd field
		
		1.2.8 xspecfem3D for adjoint simulations 
		
		1.2.9 iteration_*/CMTs_adj/kernel.sh
			which launches:
		
			1.2.9.1 xsum_preconditioned_kernels
			
			1.2.9.2 xsmooth_sem
			
			1.2.9.3 xmodel_update
				(so far steepest descent)
				
			1.2.9.4 xcombine_vol_data
				creates vtk for kernels (smoothed and unsmoothed) and for possible model updates
				
			1.2.9.5 iteration_*/create_mseed.py








