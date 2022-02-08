#!/bin/bash

#bck='bck.0.'
bck=''
for i in `seq 0 24`
do
  echo "replica $i"
  cd $i
  bck.meup.sh -i fes_running
  mkdir fes_running
  plumed sum_hills --mintozero --hills ${bck}HILLS --min -1.3 --max 1 --bin 100 --stride 1000 > log.sum_hills
  for n in `seq 0 399`
  do
    mv fes_$n.dat fes_running/fes_$[n+1].dat
  done
  rm fes_400.dat
  bck.meup.sh -i rew_running
  mkdir rew_running
  ../../../postprocessing/FES_from_Reweighting.py --kt 1 -s 0.01 --bias metad.rbias --min -1.3 --max 1 --stride 1000 -f ${bck}COLVAR -o rew_running/
#  bck.meup.sh -i Rev-rew_running
#  mkdir Rev-rew_running
#  ../../../postprocessing/FES_from_Reweighting.py --kt 1 -s 0.01 --bias metad.rbias --min -1.3 --max 1 --stride 1000 -f ${bck}COLVAR --reverse -o Rev-rew_running/
  bck.meup.sh -i Last-rew_running
  mkdir Last-rew_running
  ../../Last_Bias_Reweighting.py --kt 1 -s 0.01 --bias NO --min -1.3 --max 1 --stride 1000 -f ${bck}COLVAR -o Last-rew_running/ --last-file auto
  cd ..
done

../get_deltaF.py
