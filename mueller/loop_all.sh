#!/bin/bash

for i in `seq 0 24`
do
  mkdir $i
  cd $i
  ../../queue_md.i.sh $i &
  cd ..
done
