#!/bin/bash

#/bin/rm -f output_night*.o output_night*.e core.* seismo*txt

#/bin/rm -f -r DATABASES_MPI
#/bin/rm -f -r OUTPUT_FILES

#mkdir -p DATABASES_MPI OUTPUT_FILES
#mkdir -p OUTPUT_FILES/DATABASES_MPI

# leave this, it is crucial for large runs
ulimit -S -s unlimited

# here you can change "standard" to another queue if you want
ccc_msub -q standard $1

