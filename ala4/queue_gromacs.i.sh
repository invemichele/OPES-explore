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
nsteps="-nsteps 10000000"
#nsteps=""
exe="`which gmx_mpi` mdrun"
Filename=alanine
Inputname=input
#NumWalkers=`ls ${Inputname}*.tpr |wc -l`
NumWalkers=1
ncore=$[ncore*NumWalkers]
WalkerPrefix=".$rep"
#optWalkers="-multi $NumWalkers"
optWalkers=""
#if [ $NumWalkers -eq 1 ]
#then
#  WalkerPrefix=""
#  optWalkers=""
#fi
Project=${Filename}${WalkerPrefix}
Run_file=../../inputs/${Inputname}${WalkerPrefix}.tpr
outfile=${Filename}${WalkerPrefix}.out
max_h=`python <<< "print('%g'%(${max_t%:*}+${max_t#*:}/60-0.05))"`

# Prepare Submission
../bck.meup.sh -i $outfile
res=""
#cpt_files=`ls ${Project}*.cpt |wc -l`
#if [ $cpt_files -gt 0 ]
#then
#  res="-cpi ${Project}.cpt -append"
#  bck.meup.sh -i ${Project}*.gro > $outfile
#else
#  bck.meup.sh -i ${Project}* > $outfile
#fi
../bck.meup.sh -i ${Project}* > $outfile
#sed "s/__REP__/$rep/g" plumed.dat > plumed.$rep.dat

mpi_cmd="$exe -plumed ../plumed.dat -maxh $max_h -s $Run_file -deffnm $Project $optWalkers $nsteps -ntomp 1 $res"
extra_cmd="../../get_ala4_state.sh"

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
