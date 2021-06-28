#!/usr/bin/env python

import glob,os,obspy,sys
v=sys.argv[1]
try:
    v=str(int(v)).zfill(4)
except:
    v='*'
print v
dirs=glob.glob('CMTs/run'+v+'_mseed_processed')
for d in dirs:
    print d
    sacs=glob.glob(os.path.join(d,'*SAC*.synt'))
    traces=[]
    for s in sacs:
        f=obspy.read(s)
        traces.append(f[0])
    st=obspy.Stream(traces)
    st.write(d+'.mseed',format='MSEED')
    print d+'.mseed'

