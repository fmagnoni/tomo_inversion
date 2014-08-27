#!/bin/bash
#PBS -S /bin/bash

## job name and output file
#PBS -N go_sol_adj
#PBS -j oe
#PBS -o in_out_files/OUTPUT_FILES/job.o

###########################################################
# USER PARAMETERS

#PBS -l select=256:ncpus=1,walltime=96:00:00

###########################################################
CURRDIR='/lscratch/users/magnoni/SPECFEM3D/trunk_update'

cd $CURRDIR

INDIR=$CURRDIR'/in_data_files'
CMTDIR=$INDIR'/CMTSOLUTIONS_DIR'
STDIR=$INDIR'/STATIONS_DIR'
STDIR_ADJ=$INDIR'/STATIONS_ADJOINT_DIR'

OUTDIR=$CURRDIR'/in_out_files/OUTPUT_FILES'
OUTDIR_MESH=$CURRDIR'/in_out_files/DATABASES_MPI'
OUTDIR_SEM=$CURRDIR'/in_out_files/SEM'

model='m05_02_pre'

OUTDIR_MESH_FILES=${OUTDIR_MESH}'/mesh_files_'${model}
echo ${OUTDIR_MESH_FILES}

# get the needed binary files
cp ${OUTDIR_MESH_FILES}/proc*external_mesh.bin ${OUTDIR_MESH}

cd $CMTDIR
echo $CMTDIR

for FILE in CMTSOLUTION_UTM_tdmt_*_usv
do
	echo $FILE > $FILE.cmt
	echo $FILE.cmt
	
	OTIME=$(awk '{ print substr($0, 22, 19) }' ${FILE}.cmt)
	echo $OTIME
	echo $OTIME > otime
	cat otime
	YEAR=$(awk -F_ '{ print $1 }' otime)
	echo $YEAR
	MONTH=$(awk -F_ '{ print $2 }' otime)
	echo $MONTH
	DAY=$(awk -F_ '{ print $3 }' otime)
	echo $DAY
	awk -F_ '{ print $4 }' otime > hours
	cat hours
	HOUR=$(awk -F. '{ print $1 }' hours)
	echo $HOUR
	MIN=$(awk -F. '{ print $2 }' hours)
	echo $MIN
	
	SUFFIX=${YEAR}${MONTH}${DAY}"_"${HOUR}${MIN}
	echo $SUFFIX

	echo 'dir CMTSOLUTIONS_DIR'
	ls ${CMTDIR}
	rm ${CMTDIR}/*.cmt ${CMTDIR}/otime ${CMTDIR}/hours

	cd ${CURRDIR}
	pwd

	#change Par_file for the FORWARD SIMULATION
	change_simulation_type.pl -F
	grep SIMULATION_TYPE in_data_files/Par_file
	grep SAVE_FORWARD in_data_files/Par_file
	
	# script to run the solver
	# read Par_file to get information about the run
	# compute total number of nodes needed
	NPROC=`grep NPROC in_data_files/Par_file | cut -d = -f 2 `
	
	# total number of nodes is the product of the values read
	numnodes=$NPROC
		
	#create output directories
	mkdir -p ${OUTDIR}/after_${SUFFIX}_adj_2_20_6_20_${model}/timestamps
	mkdir -p ${OUTDIR}/after_${SUFFIX}_adj_2_20_6_20_${model}/ascii_seismograms/velocimetri_perm
	mkdir -p ${OUTDIR}/after_${SUFFIX}_adj_2_20_6_20_${model}/ascii_seismograms/velocimetri_temp
	mkdir -p ${OUTDIR}/after_${SUFFIX}_adj_2_20_6_20_${model}/ascii_seismograms/accelerometri
	mkdir -p ${OUTDIR_MESH}/after_${SUFFIX}_adj_2_20_6_20_${model}
		
	#obtain STATIONS, STATIONS_ADJOINT and CMTSOLUTION for the given ev
	cp ${STDIR}/STATIONS_UTM_completo_*_${OTIME} ${INDIR}/STATIONS
	cp ${STDIR_ADJ}/STATIONS_ADJOINT_UTM_${OTIME} ${INDIR}/STATIONS_ADJOINT
	cp ${CMTDIR}/${FILE} ${INDIR}/CMTSOLUTION
	
	#prepare adjoint sources
	mv ${OUTDIR_SEM}/${OTIME}/*.adj ${OUTDIR_SEM}
	
	# backup files used for this simulation
	cp in_data_files/Par_file in_out_files/OUTPUT_FILES/Par_file_forw
	cp in_data_files/STATIONS in_out_files/OUTPUT_FILES/
	cp in_data_files/CMTSOLUTION in_out_files/OUTPUT_FILES/
		
	# obtain lsf job information
	cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES/compute_nodes
	echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES/jobid
	
	echo starting run in current directory $PWD
	echo " "
	
	sleep 2
	cd bin/
	mpirun -n $numnodes ./xspecfem3D
	
	echo "finished successfully"
	
	cd $CURRDIR
	
	#change Par_file for the ADJOINT SIMULATION
	change_simulation_type.pl -b
	grep SIMULATION_TYPE in_data_files/Par_file
	grep SAVE_FORWARD in_data_files/Par_file
	
	# compute total number of nodes needed
	NPROC=`grep NPROC in_data_files/Par_file | cut -d = -f 2 `
	
	# total number of nodes is the product of the values read
	numnodes=$NPROC
	
	# backup files used for this simulation
	cp in_data_files/Par_file in_out_files/OUTPUT_FILES/Par_file_adj
	cp in_data_files/STATIONS_ADJOINT in_out_files/OUTPUT_FILES/
	
	# obtain lsf job information
	cat $PBS_NODEFILE > in_out_files/OUTPUT_FILES/compute_nodes
	echo "$PBS_JOBID" > in_out_files/OUTPUT_FILES/jobid
	
	echo starting run in current directory $PWD
	echo " "
	
	sleep 2
	cd bin/
	mpirun -n $numnodes ./xspecfem3D
	
	echo "finished successfully"
	
	cd ${OUTDIR}
	
	mv CMTSOLUTION compute_nodes job* starttimeloop.txt output_list_stations.txt output_solver.txt Par_file* STATIONS* *.vtk ./after_${SUFFIX}_adj_2_20_6_20_${model}/
	cp output_mesher.txt *.h ./after_${SUFFIX}_adj_2_20_6_20_${model}/
	mv timestamp0* ./after_${SUFFIX}_adj_2_20_6_20_${model}/timestamps
	mv *.IT.*.sem? ./after_${SUFFIX}_adj_2_20_6_20_${model}/ascii_seismograms/velocimetri_temp
	mv *.SSN.*.sem? ./after_${SUFFIX}_adj_2_20_6_20_${model}/ascii_seismograms/accelerometri
	mv *.sem? ./after_${SUFFIX}_adj_2_20_6_20_${model}/ascii_seismograms/velocimetri_perm
	
	cd ${OUTDIR_MESH}
	rm *absorb_field.bin *save_forward_arrays.bin
	mv *kernel.bin ./after_${SUFFIX}_adj_2_20_6_20_${model}
	
	rm ${INDIR}/CMTSOLUTION ${INDIR}/STATIONS ${INDIR}/STATIONS_ADJOINT 
	
	mv ${OUTDIR_SEM}/*.adj ${OUTDIR_SEM}/${OTIME}
	
	cd $CMTDIR
	
done

