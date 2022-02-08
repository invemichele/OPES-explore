#!/bin/bash

#bck='bck.0.'
bck=''
for i in `seq 0 24`
do
  echo "replica $i"
  cd $i
  bck.meup.sh -i fes_running
  mkdir fes_running
  ../../../postprocessing/FES_from_State.py --kt 1 --all_stored -f ${bck}STATE --min -1.3 --max 1 -o fes_running/
  bck.meup.sh -i rew_running
  mkdir rew_running
  ../../../postprocessing/FES_from_Reweighting.py --kt 1 -s 0.01 --min -1.3 --max 1 --stride 1000 -f ${bck}COLVAR -o rew_running/
#  bck.meup.sh -i Rev-rew_running
#  mkdir Rev-rew_running
#  ../../../postprocessing/FES_from_Reweighting.py --kt 1 -s 0.01 --min -1.3 --max 1 --stride 1000 -f ${bck}COLVAR --reverse -o Rev-rew_running/
  cd ..
done

../get_deltaF.py

# to get the FES from the instantaneous bias, the STATE file is needed
# add the following keywords to opes:
#  STATE_WFILE=STATE STATE_WSTRIDE=500*1000 STORE_STATES
