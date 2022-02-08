#!/bin/bash

for dir in opes explore
do
  echo $dir 
  cd $dir
  mkdir running_fes
  ../../postprocessing/FES_from_State.py --temp 300 --all_stored -f STATE -o running_fes/
  cd ..
done
