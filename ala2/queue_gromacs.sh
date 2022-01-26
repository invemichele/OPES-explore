#!/bin/bash

# Job Settings
jname=${PWD##*/}
ncore=1
max_t=1:00 #h:min

#to run locally
host=$HOSTNAME
[ $# -eq 1 ] && host=$1

# Commands
nsteps="-nsteps 5000000"
#nsteps=""
exe="`which gmx_mpi` mdrun"
Filename=alanine
NumWalkers=$ncore
if [ $ncore -eq -1 ]
then
  NumWalkers=`ls input*.tpr |wc -l`
  ncore=$NumWalkers
fi
WalkerPrefix="."
optWalkers="-multi $NumWalkers"
if [ $NumWalkers -eq 1 ]
then
  WalkerPrefix=""
  optWalkers=""
fi
Project=${Filename}${WalkerPrefix}
Run_file=../input${WalkerPrefix}.tpr
outfile=${Filename}.out
max_h=`python <<< "print('%g'%(${max_t%:*}+${max_t#*:}/60))"`

mpi_cmd="$exe -plumed plumed.dat -maxh $max_h -s $Run_file -deffnm $Project $optWalkers $nsteps"
#extra_cmd="./get_fes_all.sh"
extra_cmd=""

# Prepare Submission
../../bck.meup.sh -i $outfile
../../bck.meup.sh -i ${Filename}* > $outfile
### if euler ###
if [ ${host:0:3} == "eu-" ]
then
  cmd="mpirun ${mpi_cmd}"
  if [ ! -z "$extra_cmd" ]
  then
    cmd="${cmd}; bsub -w \"done(${jname})\" -J after$jname -o $outfile $extra_cmd"
  fi
  submit="bsub -o $outfile -J $jname -n $ncore -W $max_t $part $cmd"
  echo -e " euler submission:\n$submit" |tee -a $outfile
### if workstation ###
else
  if [ $ncore -gt 8 ]
  then
    ncore=8
  fi
  submit="time mpirun -np $ncore ${mpi_cmd} -pin off"
  echo -e " workstation submission:\n$submit\n$extra_cmd" |tee -a $outfile
  eval "$submit &>> $outfile"
  submit="$extra_cmd" # &>> $outfile"
fi

# Actual Submission
eval $submit
