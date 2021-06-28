#!/usr/bin/env python

import sys,os

nameit=os.path.basename(os.getcwd())
summaryfile=open(nameit+'_summary_steplengthext.txt','w')


files=sorted(sys.argv[1:])
if len(files)==0:
    print 'usage:\n'+sys.argv[0]+' [window_chi files]'
    sys.exit(1)
values=[]
for f in files:
    g=open(f,'r')
    line=g.readline()
    summaryfile.write(f+' '+line+'\n')
    values.append(float(line.split()[0]))

summaryfile.close()

ind=values.index(min(values))
#dirs=['CMTs_2','CMTs_3','CMTs_4','CMTs_5']
dirs=[x.split('/')[0] for x in files]
dir_best=dirs[ind]
print dir_best

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
fig=plt.figure()
plt.plot(values,label='all')
plt.legend()
plt.savefig(nameit+'_summary_steplengthext.png')




