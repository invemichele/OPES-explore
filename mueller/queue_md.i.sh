#!/bin/bash

[ $# -eq 1 ] || echo "rep missing!"
[ $# -eq 1 ] || exit
rep=$1

# Job Settings
jname=${PWD: -7}
ncore=1
max_t=12:00 #h:min
outfile=log.out
host=$HOSTNAME

# Commands
mpi_cmd="plumed ves_md_linearexpansion ../../inputs/input_md.${rep}.dat"
#extra_cmd="../analyze_single.sh"
extra_cmd=""

# Prepare Submission
../../../bck.meup.sh -i $outfile
#bck.meup.sh -v $logfile |& tee -a $outfile
### if euler ###
if [ ${host:0:3} == "eu-" ]
then
  cmd="mpirun ${mpi_cmd}; ${extra_cmd}"
  submit="bsub -o $outfile -J $jname -n $ncore -W $max_t $cmd"
  echo -e " euler submission:\n$submit" |tee -a $outfile
### if workstation ###
else
  if [ $ncore -gt 8 ]
  then
    ncore=8
  fi
  submit="time mpirun -np $ncore ${mpi_cmd}"
  echo -e " workstation submission:\n$submit\n$extra_cmd" |tee -a $outfile
  eval "$submit &>> $outfile"
  submit="$extra_cmd" # &>> $outfile"
fi

# Actual Submission
$submit
#eval $submit
