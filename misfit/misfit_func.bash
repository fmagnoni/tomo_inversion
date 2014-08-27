#!/bin/bash

WORK_DIR="/Users/magnoni/Documents/ADJOINT_TOMO/RUNS_m??_??"

model="m02"
T1="T002_T020"
T2="T006_T020"
nev="11"
# nev="63"  # number of events
nc="6"    # number of categories 

cd ${WORK_DIR}
pwd

# loop over the 2 period bands
for period in ${T1} ${T2}
do
	echo $period
	
	# loop over the events
	for DIR in 20??_??_??_*
	do
	
		cd ${DIR}/${model}/MEASURE_${period}	
		pwd
	
		##################
		# radial component
	
		grep FXR ${DIR}_${period}_${model}_window_chi > ${DIR}_${period}_${model}_window_chi_R
		nwin_R=`grep FXR ${DIR}_${period}_${model}_window_chi | wc -l`
		echo ${nwin_R}
	
		i=1
		while [ $i -le "$nwin_R" ]
		do
			echo $DIR >> evid_R       #file with event ids
			echo $nwin_R >> fnorm_R	  #file with normalization factor=num_win for this event, this component, this period band	
		    i=$(($i+1))
		done
	 
	    # 'reduced' window_chi file
		# the traveltime and amplitude misfit functions are multiplied by 2 to remove (1/2) from the meas code
		# mt_sub.f90 877-880
		awk '{print $1, $6, $13, $14, $15, $16, 2.0*$29, 2.0*$30}' ${DIR}_${period}_${model}_window_chi_R > window_chi_R
	
		# columns content:
		# 1: event_id, 2: sta.net.comp, 3: imeas, 4: MT-TT meas, 5: MT-dlnA meas, 6: XC-TT meas, 7: XC-dlnA meas 
		# 8: TT misfit function (chi) (MT o XC depending on imeas), 9: AM chi, 10: norm_factor
		paste evid_R window_chi_R fnorm_R > R_${period}_${DIR}_${model}_window_chi
		
		# create a file as R_${period}_${DIR}_${model}_window_chi
		# but with all the events for the given component and given period 
		# NOTE: for each event the printed normaliz. factor must be the same
		cat R_${period}_${DIR}_${model}_window_chi >> ${WORK_DIR}/R_${period}_${model}_window_chi
		
	
		# sum the TT chi over the windows for the given event, component, period 
		# and write a file with columns 1: ev_id, 2: chi normalized over windows (i.e. misfit per event per category) 

		awk '{print $8}' R_${period}_${DIR}_${model}_window_chi > R_TTchi
	
		i=1
		misfit="0"
		while [ $i -le "$nwin_R" ]
		do
			sed -n -e "${i}p" R_TTchi > tmp1
			misfit=$(cat tmp1 | awk '{printf "%f", $0+m}' m=$misfit)
			echo $misfit > tmp2
		 	i=$(($i+1))            	
		done
	
		echo $misfit
	
		if [ "$nwin_R" -ne 0 ]
		then
			misfit_norm=$(echo "$misfit / $nwin_R" |bc -l)
			echo $misfit_norm > tmp3
		fi
	
		awk '{printf "%.14f", $0}' tmp3 > tmp4
	
		echo $DIR > tmp5

	    # Misfit per event per category	
		paste tmp5 tmp4 > R_${period}_${DIR}_${model}_chi_norm_win
		
		# create a file as R_${period}_${DIR}_${model}_chi_norm_win
		# but with all the events for the given component and given period 
		cat R_${period}_${DIR}_${model}_chi_norm_win >> ${WORK_DIR}/R_${period}_${model}_chi_norm_win	
	
		rm evid_R fnorm_R window_chi_R tmp1 tmp2 tmp3 tmp4 tmp5
		# mv evid_R fnorm_R window_chi_R tmp1 tmp2 tmp3 tmp4 tmp5 R/
	
	
		######################
	    # transverse component
	
		grep FXT ${DIR}_${period}_${model}_window_chi > ${DIR}_${period}_${model}_window_chi_T
		nwin_T=`grep FXT ${DIR}_${period}_${model}_window_chi | wc -l`
		echo ${nwin_T}
	
		i=1
		while [ $i -le "$nwin_T" ]
		do
			echo $DIR >> evid_T       #file with event ids
			echo $nwin_T >> fnorm_T	  #file with normalization factor=num win for this event, this component, this period band	
		    i=$(($i+1))
		done
	 
		# the traveltime and amplitude misfit functions are multiplied by 2 to remove (1/2) from the meas code
		# mt_sub.f90 877-880
		awk '{print $1, $6, $13, $14, $15, $16, 2.0*$29, 2.0*$30}' ${DIR}_${period}_${model}_window_chi_T > window_chi_T
	
		# columns content:
		# 1: event_id, 2: sta.net.comp, 3: imeas, 4: MT-TT meas, 5: MT-dlnA meas, 6: XC-TT meas, 7: XC-dlnA meas 
		# 8: TT misfit function (chi) (MT o XC depending on imeas), 9: AM chi, 10: norm_factor
		paste evid_T window_chi_T fnorm_T > T_${period}_${DIR}_${model}_window_chi
		
		# create a file as T_${period}_${DIR}_${model}_window_chi
		# but with all the events for the given component and given period 
		# NOTE: for each event the printed normaliz. factor must be the same
		cat T_${period}_${DIR}_${model}_window_chi >> ${WORK_DIR}/T_${period}_${model}_window_chi
		
	
		# sum the TT chi over the windows for the given event, component, period 
		# and write a file with columns 1: ev_id, 2: chi normalized over windows (i.e. misfit per event per category)
		
		awk '{print $8}' T_${period}_${DIR}_${model}_window_chi > T_TTchi
	
		i=1
		misfit="0"
		while [ $i -le "$nwin_T" ]
		do
			sed -n -e "${i}p" T_TTchi > tmp1
			misfit=$(cat tmp1 | awk '{printf "%f", $0+m}' m=$misfit)
			echo $misfit > tmp2
		 	i=$(($i+1))            	
		done
	
		echo $misfit
	
		if [ "$nwin_T" -ne 0 ]
		then
			misfit_norm=$(echo "$misfit / $nwin_T" |bc -l)
			echo $misfit_norm > tmp3
		fi
	
		awk '{printf "%.14f", $0}' tmp3 > tmp4
	
		echo $DIR > tmp5
	
	    # Misfit per event per category 
		paste tmp5 tmp4 > T_${period}_${DIR}_${model}_chi_norm_win
	
		# create a file as T_${period}_${DIR}_${model}_chi_norm_win
		# but with all the events for the given component and given period 
		cat T_${period}_${DIR}_${model}_chi_norm_win >> ${WORK_DIR}/T_${period}_${model}_chi_norm_win	
	
		rm evid_T fnorm_T window_chi_T tmp1 tmp2 tmp3 tmp4 tmp5
		# mv evid_T fnorm_T window_chi_T tmp1 tmp2 tmp3 tmp4 tmp5 T/	
	
		
		####################
		# vertical component
	 
		grep FXZ ${DIR}_${period}_${model}_window_chi > ${DIR}_${period}_${model}_window_chi_Z
		nwin_Z=`grep FXZ ${DIR}_${period}_${model}_window_chi | wc -l`
		echo ${nwin_Z}
	
		i=1
		while [ $i -le "$nwin_Z" ]
		do
			echo $DIR >> evid_Z       #file with event ids
			echo $nwin_Z >> fnorm_Z	  #file with normalization factor=num win for this event, this component, this period band	
		    i=$(($i+1))
		done
	 
		# the traveltime and amplitude misfit functions are multiplied by 2 to remove (1/2) from the meas code
		# mt_sub.f90 877-880
		awk '{print $1, $6, $13, $14, $15, $16, 2.0*$29, 2.0*$30}' ${DIR}_${period}_${model}_window_chi_Z > window_chi_Z
	
		# columns content:
		# 1: event_id, 2: sta.net.comp, 3: imeas, 4: MT-TT meas, 5: MT-dlnA meas, 6: XC-TT meas, 7: XC-dlnA meas 
		# 8: TT misfit function (chi) (MT o XC depending on imeas), 9: AM chi, 10: norm_factor
		paste evid_Z window_chi_Z fnorm_Z > Z_${period}_${DIR}_${model}_window_chi
		
		# create a file as Z_${period}_${DIR}_${model}_window_chi
		# but with all the events for the given component and given period 
		# NOTE: for each event the printed normaliz. factor must be the same
		cat Z_${period}_${DIR}_${model}_window_chi >> ${WORK_DIR}/Z_${period}_${model}_window_chi
		
	
		# sum the TT chi over the windows for the given event, component, period 
		# and write a file with columns 1: ev_id, 2: chi normalized over windows (i.e. misfit per event per category)
		
		awk '{print $8}' Z_${period}_${DIR}_${model}_window_chi > Z_TTchi
	
		i=1
		misfit="0"
		while [ $i -le "$nwin_Z" ]
		do
			sed -n -e "${i}p" Z_TTchi > tmp1
			misfit=$(cat tmp1 | awk '{printf "%f", $0+m}' m=$misfit)
			echo $misfit > tmp2
		 	i=$(($i+1))            	
		done
	
		echo $misfit
	
		if [ "$nwin_Z" -ne 0 ]
		then
			misfit_norm=$(echo "$misfit / $nwin_Z" |bc -l)
			echo $misfit_norm > tmp3
		fi
	
		awk '{printf "%.14f", $0}' tmp3 > tmp4
	
		echo $DIR > tmp5

	    # Misfit per event per category	
		paste tmp5 tmp4 > Z_${period}_${DIR}_${model}_chi_norm_win
	
		# create a file as Z_${period}_${DIR}_${model}_chi_norm_win
		# but with all the events for the given component and given period 
		cat Z_${period}_${DIR}_${model}_chi_norm_win >> ${WORK_DIR}/Z_${period}_${model}_chi_norm_win	
	
		rm evid_Z fnorm_Z window_chi_Z tmp1 tmp2 tmp3 tmp4 tmp5
		# mv evid_Z fnorm_Z window_chi_Z tmp1 tmp2 tmp3 tmp4 tmp5	Z/
			
		
		cd ${WORK_DIR}
	
	done  # end of loop over the events

	pwd
	
	#-----------
	# Misfit per category
	
	echo ${nev}

	# sum the TT chi over the events for the given component and period
	# and normalize with respect to the number of events 
	# then write a file with column 1: chi normalized over events

	#loop over components
	for compon in R Z T
	do
		awk '{print $2}' ${compon}_${period}_${model}_chi_norm_win > ${compon}_${period}_${model}_TTchi_norm_win
	
		i=1
		misfit="0"
		while [ $i -le "$nev" ]
		do
			sed -n -e "${i}p" ${compon}_${period}_${model}_TTchi_norm_win > tmp1
			misfit=$(cat tmp1 | awk '{printf "%f", $0+m}' m=$misfit)
			echo $misfit > tmp2
		 	i=$(($i+1))            	
		done
	
		echo $misfit
	
		misfit_norm=$(echo "$misfit / $nev" |bc -l)
		echo $misfit_norm > tmp3
		awk '{printf "%.14f", $0}' tmp3 > ${compon}_${period}_${model}_TTchi_norm_src

		rm tmp1 tmp2 tmp3
		# mv tmp1 tmp2 tmp3 ${compon}_${period}/
		
	done #end loop over components


done  # end of loop over the 2 period bands

pwd

#----------
# Overall misfit

echo ${nc}

paste *TTchi_norm_src > chi4categories

# sum the TT chi over the 6 categories R_2_20, R_6_20, T_2_20, T_6_20, Z_2_20, Z_6_20 
total_chi=$(awk '{printf "%f", $1+$2+$3+$4+$5+$6}' chi4categories)

# calculate the final misfit function normalized by the nuber of categories
total_chi_norm=$(echo "$total_chi / $nc" |bc -l)
echo $total_chi_norm > tmp1
awk '{printf "%.14f", $0}' tmp1 > total_chi_norm_${model}		

rm tmp1

exit

	#################
	# T=6-20 s

	# cd ${DIR}/${model}/MEASURE_${T2}	
	# pwd
	# 
	# grep FXR ${DIR}_${T2}_${model}_window_chi > ${DIR}_${T2}_${model}_window_chi_R
	# nwin_R=`grep FXR ${DIR}_${T2}_${model}_window_chi | wc -l`
	# echo ${nwin_R}
	# 
	# grep FXT ${DIR}_${T2}_${model}_window_chi > ${DIR}_${T2}_${model}_window_chi_T
	# nwin_T=`grep FXT ${DIR}_${T2}_${model}_window_chi | wc -l`
	# echo ${nwin_T}
	# 
	# grep FXZ ${DIR}_${T2}_${model}_window_chi > ${DIR}_${T2}_${model}_window_chi_Z
	# nwin_Z=`grep FXZ ${DIR}_${T2}_${model}_window_chi | wc -l`
	# echo ${nwin_Z}
	
