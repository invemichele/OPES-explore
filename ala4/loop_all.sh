#!/bin/bash

totrep=`ls ../inputs/input.* |wc -l`
echo "found $totrep input files"

for i in `seq 0 $[totrep-1]`
do
  mkdir $i
  cd $i
  echo "../../queue_md.i.sh $i &"
  cd ..
done
