#!/bin/bash

for dir in opes explore
do
  echo $dir 
  cd $dir
  mkdir running_fes
  ../../postprocessing/FES_from_State.py --temp 300 --all_stored -f STATE -o running_fes/
  cd ..
done

# to get the FES from the instantaneous bias, the STATE file is needed
# add the following keywords before running opes:
#  STATE_WFILE=STATE STATE_WSTRIDE=500*1000 STORE_STATES
# or use the State_from_Kernels.py script on a properly shortened KERNELS file
