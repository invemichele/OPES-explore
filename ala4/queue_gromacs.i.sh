#!/bin/bash

[ $# -eq 1 ] || echo "rep missing!"
[ $# -eq 1 ] || exit
rep=$1

# Job Settings
jname=${PWD##*/}-${rep}
ncore=1
max_t=4:00 #h:min
host=$HOSTNAME

# Commands
nsteps="-nsteps $[500*1000*20]"
exe="`which gmx_mpi` mdrun"
Filename=alanine
Inputname=input
Project=${Filename}
Run_file=../../inputs/${Inputname}.$rep.tpr
outfile=${Filename}.out
max_h=`python <<< "print('%g'%(${max_t%:*}+${max_t#*:}/60-0.05))"`

# Prepare Submission
bck.meup.sh -i $outfile
bck.meup.sh -i ${Project}* > $outfile

mpi_cmd="$exe -plumed ../plumed.dat -maxh $max_h -s $Run_file -deffnm $Project $optWalkers $nsteps -ntomp 1"
extra_cmd="../../get_ala4_basin.sh"

### if euler ###
if [ ${host:0:3} == "eu-" ]
then
  cmd="mpirun ${mpi_cmd}"
  if [ ! -z "$extra_cmd" ]
  then
    cmd="${cmd}; bsub -w \"done(${jname})\" -J after$jname -o $outfile $extra_cmd"
  fi
  submit="bsub -o $outfile -J $jname -n $ncore -W $max_t $cmd"
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
