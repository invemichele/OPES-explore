#! /usr/bin/env python3

import sys
import numpy as np
import pandas as pd
import subprocess

#bck='bck.0.'
bck=''
ts=0
steps=400
replicas=25
endtime=1e6
kbt=1
time=np.linspace(endtime/steps,endtime,steps)
deltaF=np.zeros((replicas,steps))

def get_deltaF(fes_file,deltaF_file,av_deltaF_file):
  for i in range(replicas):
    print('   working...   {:.0%}'.format(i/replicas),end='\r')
    for n in range(steps):
      data=pd.read_table(fes_file%(i,n+1),dtype=float,sep='\s+',comment='#',header=None,usecols=[0,1])
      cv=np.array(data.iloc[:,0])
      fes=np.array(data.iloc[:,1])
      deltaF[i,n]=-kbt*(np.logaddexp.reduce(-fes[cv>ts]/kbt)-np.logaddexp.reduce(-fes[cv<ts]/kbt))
    np.savetxt(deltaF_file%i,np.c_[time,deltaF[i,:]],header='time  DeltaF',fmt='%g')
  av_deltaF=np.average(deltaF,axis=0)
  std_deltaF=np.std(deltaF,axis=0)
  np.savetxt(av_deltaF_file,np.c_[time,av_deltaF,std_deltaF],header='time  av_DeltaF  std_DeltaF',fmt='%g')

cmd=subprocess.Popen('bck.meup.sh -i */deltaF_fes.dat av-deltaF_fes.dat',shell=True)
cmd.wait()
get_deltaF('%d/'+bck+'fes_running/fes_%d.dat','%d/deltaF_fes.dat','av-deltaF_fes.dat')

cmd=subprocess.Popen('bck.meup.sh -i */deltaF_rew.dat av-deltaF_rew.dat',shell=True)
cmd.wait()
get_deltaF('%d/'+bck+'rew_running/fes-rew_%d.dat','%d/deltaF_rew.dat','av-deltaF_rew.dat')

# cmd=subprocess.Popen('bck.meup.sh -i */deltaF_Rev-rew.dat av-deltaF_Rev-rew.dat',shell=True)
# cmd.wait()
# time=time[::-1]
# get_deltaF('%d/'+bck+'Rev-rew_running/fes-rew_%d.dat','%d/deltaF_Rev-rew.dat','av-deltaF_Rev-rew.dat')

# cmd=subprocess.Popen('bck.meup.sh -i */deltaF_Last-rew.dat av-deltaF_Last-rew.dat',shell=True)
# cmd.wait()
# get_deltaF('%d/'+bck+'Last-rew_running/fes-rew_%d.dat','%d/deltaF_Last-rew.dat','av-deltaF_Last-rew.dat')

