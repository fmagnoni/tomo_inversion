#!/bin/bash
#PBS -S /bin/bash

## job name and output file
#PBS -N go_sol
#PBS -j oe
#PBS -o in_out_files/OUTPUT_FILES/job.o

###########################################################
# USER PARAMETERS

#PBS -l select=256:ncpus=1,walltime=96:00:00

###########################################################

CURRDIR='/lscratch/users/magnoni/SPECFEM3D/trunk_update'

cd $CURRDIR

echo `date`

INDIR=$CURRDIR'/in_data_files'
CMTDIR=$INDIR'/CMTSOLUTIONS_DIR'
STDIR=$INDIR'/STATIONS_DIR'

OUTDIR=$CURRDIR'/in_out_files/OUTPUT_FILES'
OUTDIR_MESH=$CURRDIR'/in_out_files/DATABASES_MPI'

model='m05'
step_fac='02_pre'

OUTDIR_MESH_FILES=${OUTDIR_MESH}'/mesh_files_'${model}'_'${step_fac}
echo ${OUTDIR_MESH_FILES}

# get the needed binary files
cp ${OUTDIR_MESH_FILES}/proc*external_mesh.bin ${OUTDIR_MESH_FILES}/proc*attenuation.bin ${OUTDIR_MESH}


cd $CMTDIR
echo $CMTDIR

for FILE in CMTSOLUTION_UTM_tdmt_*_usv
do
	echo $FILE > $FILE.cmt
	echo $FILE.cmt
	
	OTIME=$(awk '{ print substr($0, 22, 19) }' ${FILE}.cmt)
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

# script to run the solver
# read Par_file to get information about the run
# compute total number of nodes needed
	NPROC=`grep NPROC in_data_files/Par_file | cut -d = -f 2 `

# total number of nodes is the product of the values read
	numnodes=$NPROC

#create output directories
	mkdir ${OUTDIR}/output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}
	mkdir ${OUTDIR}/output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/timestamps
	mkdir -p ${OUTDIR}/output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/ascii_seismograms/accelerometri
	mkdir -p ${OUTDIR}/output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/ascii_seismograms/velocimetri_perm
	mkdir -p ${OUTDIR}/output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/ascii_seismograms/velocimetri_temp

#obtain STATIONS and CMTSOLUTION for the given ev
	cp ${STDIR}/STATIONS_UTM_*_${OTIME} ${INDIR}/STATIONS
	cp ${CMTDIR}/${FILE} ${INDIR}/CMTSOLUTION

# backup files used for this simulation
	cp ${INDIR}/Par_file ${OUTDIR}
	cp ${INDIR}/CMTSOLUTION ${OUTDIR}
	cp ${INDIR}/STATIONS ${OUTDIR}

# obtain lsf job information
	cat $PBS_NODEFILE > ${OUTDIR}/compute_nodes
	echo "$PBS_JOBID" > ${OUTDIR}/jobid

	echo starting run in current directory $PWD
	echo " "

	sleep 2
	cd bin/

	mpirun -n $numnodes ./xspecfem3D

	echo "finished successfully"

	cd ${OUTDIR}

	mv CMTSOLUTION compute_nodes job* output_solver.txt output_list_stations.txt starttimeloop.txt Par_file STATIONS sr.vtk ./output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/
	mv timestamp0* ./output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/timestamps
	mv *.SSN.*.sem? ./output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/ascii_seismograms/accelerometri
	mv *.IT.*.sem? ./output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/ascii_seismograms/velocimetri_temp
	mv *.sem? ./output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac}/ascii_seismograms/velocimetri_perm
    cp output_mesher.txt *.h ./output_subev3Dlrvv_${SUFFIX}_${model}_${step_fac} 


	rm ${INDIR}/CMTSOLUTION ${INDIR}/STATIONS 
	
	cd $CMTDIR

done

rm ${OUTDIR_MESH}/proc*external_mesh.bin ${OUTDIR_MESH}/proc*attenuation.bin

echo `date`

