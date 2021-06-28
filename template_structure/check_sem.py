#!/usr/bin/env python

import glob,os

east_adria=["run0002", "run0005", "run0009", "run0013", "run0020", "run0022", "run0023", "run0027", "run0028", "run0030", "run0031", "run0034", "run0036", "run0037", "run0040", "run0044", "run0047", "run0059", "run0062", "run0063", "run0065", "run0068", "run0071", "run0072", "run0079", "run0080", "run0100", "run0115", "run0117", "run0123", "run0132"]
for e in east_adria:
    z='CMTs_adj/'+e
    if os.system("mv "+z+' '+z+'_eastadria') == 0: os.system("cp -rf CMTs_adj/run0001 "+z)







d='CMTs_adj'
runs=glob.glob(d+'/run????')
zero=[]
for r in runs:
    v=len(glob.glob(r+'/SEM/*adj'))
    if  v==0: zero.append(r)
print zero



if len(zero)!=0:
    for z in zero:
        if os.system("mv "+z+' '+z+'_zerosem') == 0: os.system("cp -rf CMTs_adj/run0001 "+z)



for r in runs:
    stationsfile=os.path.join(r,'DATA','STATIONS_ADJOINT')
    f=open(stationsfile,'r')
    st=f.readlines()
    f.close
    f=open(stationsfile,'w')
    for s in st:
        station=s.split()[0]
        adj=glob.glob(r+'/SEM/'+station+'.*.HX?.adj')
        if len(adj)==3: 
            f.write(s)
        else:
            print r,s
    f.close()
