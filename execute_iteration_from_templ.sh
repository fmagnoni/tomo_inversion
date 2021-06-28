#!/bin/bash

if [ $# -eq 0 ]; then
echo "Usage: $0 -p [previous iteration] -n [next iteration]";
echo "";
echo "[previous iteration] = directory with previous iteration";
echo "[next iteration] = directory with next iteration";
echo "";
exit 1;
fi

prevflag=false
nextflag=false
execonly=false


while getopts ':h:p:n:e' option; do
  case "$option" in
    h) echo "Usage: $0 -p [previous iteration] -n [next iteration]";
       echo "";
       echo "[previous iteration] = directory with previous iteration";
       echo "[next iteration] = directory with next iteration";
       echo "";
       exit 1
       ;;
    p) echo "previous" $OPTARG
       PREV_DIR_F=$OPTARG/CMTs;
       PREV_DIR_A=$OPTARG/CMTs_adj
       IT_PREV=$OPTARG
       prevflag=true
       ;;
    n) echo "next" $OPTARG
       RUN_DIR_F=$OPTARG/CMTs;
       RUN_DIR_A=$OPTARG/CMTs_adj
       IT_RUN=$OPTARG
       nextflag=true
       ;;
    e) echo "execute only"
       execonly=true
       ;;
  esac
done
shift $((OPTIND-1))


echo $execonly

if ! $nextflag 
then
    echo "-n must be included when a directory is specified" >&2
    exit 1
fi
if ! $prevflag 
then
    echo "-p must be included when a directory is specified" >&2
    exit 1
fi

if ! $execonly
then 

echo "from... "
echo $PREV_DIR_F
echo $PREV_DIR_A

echo "to... "
echo $RUN_DIR_F
echo $RUN_DIR_A

BASE=$PWD

TEMPL="template_structure"
TEMPL_F=${TEMPL}"/CMTs"
TEMPL_A=${TEMPL}"/CMTs_adj"

#FORWARD RUNS
mkdir -p                  ${RUN_DIR_F}_2/DATA
mkdir -p                  ${RUN_DIR_F}_2/bin
mkdir -p                  ${RUN_DIR_F}_2/OUTPUT_FILES/DATABASE_MPI
cp -p $TEMPL_F/bin/*   ${RUN_DIR_F}_2/bin
cp -p $TEMPL_F/rotate* ${RUN_DIR_F}_2/
cp -p $TEMPL_F/*.pl    ${RUN_DIR_F}_2/
cp -p $TEMPL_F/iasp*   ${RUN_DIR_F}_2/
cp -p $TEMPL_F/*.ipynb ${RUN_DIR_F}_2/
cp -p $TEMPL_F/MEA*    ${RUN_DIR_F}_2/
cp -p $TEMPL_F/PAR*    ${RUN_DIR_F}_2/
cp -p $TEMPL_F/measur* ${RUN_DIR_F}_2/
cp -p $TEMPL_F/*adria* ${RUN_DIR_F}_2/
export CLEAN_MADJ='False'
cp $TEMPL_F/*.sh ${RUN_DIR_F}_2/
export CLEAN_MADJ='False'
cp $TEMPL_F/DATA/* ${RUN_DIR_F}_2/DATA/


mkdir -p                  ${RUN_DIR_F}_3/DATA
mkdir -p                  ${RUN_DIR_F}_3/bin
mkdir -p                  ${RUN_DIR_F}_3/OUTPUT_FILES/DATABASE_MPI
cp -p $TEMPL_F/bin/*   ${RUN_DIR_F}_3/bin
cp -p $TEMPL_F/rotate* ${RUN_DIR_F}_3/
cp -p $TEMPL_F/*.pl    ${RUN_DIR_F}_3/
cp -p $TEMPL_F/iasp*   ${RUN_DIR_F}_3/
cp -p $TEMPL_F/*.ipynb ${RUN_DIR_F}_3/
cp -p $TEMPL_F/MEA*    ${RUN_DIR_F}_3/
cp -p $TEMPL_F/PAR*    ${RUN_DIR_F}_3/
cp -p $TEMPL_F/measur* ${RUN_DIR_F}_3/
cp $TEMPL_F/*.sh       ${RUN_DIR_F}_3/
cp $TEMPL_F/DATA/*     ${RUN_DIR_F}_3/DATA/
cp -p $TEMPL_F/*adria* ${RUN_DIR_F}_3/

mkdir -p                  ${RUN_DIR_F}_4/DATA
mkdir -p                  ${RUN_DIR_F}_4/bin
mkdir -p                  ${RUN_DIR_F}_4/OUTPUT_FILES/DATABASE_MPI
cp -p $TEMPL_F/bin/*   ${RUN_DIR_F}_4/bin
cp -p $TEMPL_F/rotate* ${RUN_DIR_F}_4/
cp -p $TEMPL_F/*.pl    ${RUN_DIR_F}_4/
cp -p $TEMPL_F/iasp*   ${RUN_DIR_F}_4/
cp -p $TEMPL_F/*.ipynb ${RUN_DIR_F}_4/
cp -p $TEMPL_F/MEA*    ${RUN_DIR_F}_4/
cp -p $TEMPL_F/PAR*    ${RUN_DIR_F}_4/
cp -p $TEMPL_F/measur* ${RUN_DIR_F}_4/
cp $TEMPL_F/*.sh       ${RUN_DIR_F}_4/
cp $TEMPL_F/DATA/*     ${RUN_DIR_F}_4/DATA/
cp -p $TEMPL_F/*adria* ${RUN_DIR_F}_4/

mkdir -p                  ${RUN_DIR_F}_5/DATA
mkdir -p                  ${RUN_DIR_F}_5/bin
mkdir -p                  ${RUN_DIR_F}_5/OUTPUT_FILES/DATABASE_MPI
cp -p $TEMPL_F/bin/*   ${RUN_DIR_F}_5/bin
cp -p $TEMPL_F/rotate* ${RUN_DIR_F}_5/
cp -p $TEMPL_F/*.pl    ${RUN_DIR_F}_5/
cp -p $TEMPL_F/iasp*   ${RUN_DIR_F}_5/
cp -p $TEMPL_F/*.ipynb ${RUN_DIR_F}_5/
cp -p $TEMPL_F/MEA*    ${RUN_DIR_F}_5/
cp -p $TEMPL_F/PAR*    ${RUN_DIR_F}_5/
cp -p $TEMPL_F/measur* ${RUN_DIR_F}_5/
cp $TEMPL_F/*.sh       ${RUN_DIR_F}_5/
cp $TEMPL_F/DATA/*     ${RUN_DIR_F}_5/DATA/
cp -p $TEMPL_F/*adria* ${RUN_DIR_F}_5/

for i in {1..163}
do

tmp="$(printf "%04d" $i)"
echo "${tmp}"

mkdir -p                                ${RUN_DIR_F}_2/run$tmp/DATA
cp $TEMPL_F/run$tmp/DATA/*           ${RUN_DIR_F}_2/run$tmp/DATA/
mkdir -p                                ${RUN_DIR_F}_2/run$tmp/OUTPUT_FILES/DATABASES_MPI
cp $TEMPL_F/run$tmp/OUTPUT_FILES/*.h ${RUN_DIR_F}_2/run$tmp/OUTPUT_FILES/

mkdir -p                                ${RUN_DIR_F}_3/run$tmp/DATA
cp $TEMPL_F/run$tmp/DATA/*           ${RUN_DIR_F}_3/run$tmp/DATA/
mkdir -p                                ${RUN_DIR_F}_3/run$tmp/OUTPUT_FILES/DATABASES_MPI
cp $TEMPL_F/run$tmp/OUTPUT_FILES/*.h ${RUN_DIR_F}_3/run$tmp/OUTPUT_FILES/

mkdir -p                                ${RUN_DIR_F}_4/run$tmp/DATA
cp $TEMPL_F/run$tmp/DATA/*           ${RUN_DIR_F}_4/run$tmp/DATA/
mkdir -p                                ${RUN_DIR_F}_4/run$tmp/OUTPUT_FILES/DATABASES_MPI
cp $TEMPL_F/run$tmp/OUTPUT_FILES/*.h ${RUN_DIR_F}_4/run$tmp/OUTPUT_FILES/

mkdir -p                                ${RUN_DIR_F}_5/run$tmp/DATA
cp $TEMPL_F/run$tmp/DATA/*           ${RUN_DIR_F}_5/run$tmp/DATA/
mkdir -p                                ${RUN_DIR_F}_5/run$tmp/OUTPUT_FILES/DATABASES_MPI
cp $TEMPL_F/run$tmp/OUTPUT_FILES/*.h ${RUN_DIR_F}_5/run$tmp/OUTPUT_FILES/

done

echo 'copying ',$PREV_DIR_A/OUTPUT_MODEL_2/proc*external_mesh*.bin, "->",${RUN_DIR_F}_2/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/OUTPUT_MODEL_2/proc*external_mesh*.bin                    ${RUN_DIR_F}_2/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin  ${RUN_DIR_F}_2/run0001/OUTPUT_FILES/DATABASES_MPI/

echo 'copying ',$PREV_DIR_A/OUTPUT_MODEL_3/proc*external_mesh*.bin, "->",${RUN_DIR_F}_3/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/OUTPUT_MODEL_3/proc*external_mesh*.bin                    ${RUN_DIR_F}_3/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin  ${RUN_DIR_F}_3/run0001/OUTPUT_FILES/DATABASES_MPI/

echo 'copying ',$PREV_DIR_A/OUTPUT_MODEL_4/proc*external_mesh*.bin, "->",${RUN_DIR_F}_4/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/OUTPUT_MODEL_4/proc*external_mesh*.bin                    ${RUN_DIR_F}_4/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin  ${RUN_DIR_F}_4/run0001/OUTPUT_FILES/DATABASES_MPI/

echo 'copying ',$PREV_DIR_A/OUTPUT_MODEL_5/proc*external_mesh*.bin, "->",${RUN_DIR_F}_5/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/OUTPUT_MODEL_5/proc*external_mesh*.bin                    ${RUN_DIR_F}_5/run0001/OUTPUT_FILES/DATABASES_MPI/
cp $PREV_DIR_A/run0001/OUTPUT_FILES/DATABASES_MPI/proc*attenuation*.bin  ${RUN_DIR_F}_5/run0001/OUTPUT_FILES/DATABASES_MPI/


#adjoint

mkdir -p $RUN_DIR_A/DATA
mkdir -p $RUN_DIR_A/OUTPUT_FILES/DATABASE_MPI
mkdir -p $RUN_DIR_A/INPUT_KERNELS
mkdir -p $RUN_DIR_A/bin

cp -p $TEMPL_A/bin/* $RUN_DIR_A/bin
cp -p $TEMPL_A/x* $RUN_DIR_A
cp $TEMPL_A/*.sh $RUN_DIR_A/
cp $TEMPL_A/DATA/* $RUN_DIR_A/DATA/
cp $TEMPL_A/kernels_list.txt $RUN_DIR_A/

for i in {1..163}
do

tmp="$(printf "%04d" $i)"
echo "${tmp}"
mkdir -p $RUN_DIR_A/run$tmp/DATA
cp $TEMPL_A/run$tmp/DATA/* $RUN_DIR_A/run$tmp/DATA/
mkdir -p $RUN_DIR_A/run$tmp/OUTPUT_FILES/DATABASES_MPI
mkdir -p $RUN_DIR_A/run$tmp/SEM
cp $TEMPL_A/run$tmp/OUTPUT_FILES/*.h $RUN_DIR_A/run$tmp/OUTPUT_FILES/

done

fi


cp $TEMPL/*.sh ${IT_RUN}/
cp $TEMPL/*.py ${IT_RUN}/
mv $PREV_DIR_A/VTKFILES ${IT_RUN}/VTKFILES


tar cvf $CCCSTOREDIR/Backup/ITALY_5k/winchi_$IT_PREV.tar $IT_PREV/CMTs/run*_mseed_processed/madj/window_chi 
##more period bands
##tar cvf $CCCSTOREDIR/Backup/ITALY_5k/winchi_$IT_PREV.tar $IT_PREV/CMTs/run*_mseed_processed/madj_*/window_chi
submit_create_tar.sh $IT_PREV $IT_PREV

cd $IT_RUN
submit.sh execute_forward_adjoint.sh
