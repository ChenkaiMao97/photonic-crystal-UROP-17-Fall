'''
This script runs MEEP simulations in parallel.

To run this script with n processors, change parallelnum to the corresponding number. Each k point and parameter value will be run successively with a wide f scan to find roughly where the mode is and a more careful scan to find the Q's and more detailed information
'''

import subprocess, os, sys
import numpy as np
from auxfuncs import *
from pdb import set_trace as bp
import time
# to call command line operations

starttime = time.time()

#kxlist = [0.3]
#kylist = [0,0.1]
kxlist = np.arange(0,0.55,0.05)
kylist = np.arange(0,0.55,0.05)
#kylist = [-0.05]

kz = 0

makefig = 0				# whether to make .gif figures of results
run1name = 'widef'             # first scan to find frequencies at k points
run2name = 'narrowf'
outname = 'datalog'
freqendname = 'freq_h1d2_hz' # file name to save frequency results from wide scan
endname = 'h1d2_hz'
nummodes = 3                           # number of modes to find
freqvals = [0,1,2]                            # frequency numbers to run within these modes
# temporarily set later on
parname = "test"
parval = 0
parallelnum = 30                 # number of simulations to run in parallel

runpoints = []                  # list to store points to run
pids = []                       # list to store process PIDs and info
for i in range(parallelnum):
    pids.append([0])

for kx in kxlist:
    for ky in kylist:
        runpoints.append({'kx':kx,'ky':ky})

f = []
for i in range(parallelnum):
    f.append(open(outname+str(i)+'.out','w'))

run1count = 0
run2count = 0
while run2count < len(runpoints):
    doneloc = 0
    while doneloc < parallelnum:
        time.sleep(0.1)
        if pids[doneloc][0]==0:       # placeholder for a finished run
            break
        doneloc += 1
    if doneloc < parallelnum and run1count < len(runpoints): # add fresh run to list if pids not full
        print doneloc
        commandlist = ["meep"]
        runpoint = runpoints[run1count]
        run1count += 1
        for key in runpoint:
            commandlist.append(key+"="+str(runpoint[key]))
        commandlist.append(run1name+'.ctl')
        #bp()
        pid = subprocess.Popen(commandlist,stdout=f[doneloc])
        #pid = pid.pid
        pids[doneloc] = [pid,0,runpoint]
        print pids
        # second number stores stage of this point: 0 is started wide scan, 1 is started narrow scan, 2 is converting to png and 3 is converting to gif
    else:
        #pidcur, rtflag = os.wait() # grab PID when some process returns
        #print "Returned:"+str(pidcur)
        #for k in range(len(pids)):
        #    if pids[k][0]==pidcur:
        #        break
        #print "PID position in list:"+str(k)
        k = 0
        while k < len(pids):
            if pids[k][0] == 0: # at the end of the loop, points done
                pass
            elif pids[k][0].poll() != None:
                break
            k = k+1
        if k >= len(pids):
            time.sleep(1)
            continue
        print pids
        if pids[k][1]==0:       # finished wide scan, proceed to narrow scan
            freqs = [[10.0,10.0,10.0] for counter in range(nummodes)]   # first column saves frequencies, second column saves Q, third column saves distances to reference
            kx = pids[k][2]['kx']
            ky = pids[k][2]['ky']
            reffreq = bandform(kx,ky)
            ffreq = open(freqendname+'.csv','a')
            print "Reference frequency:"+str(reffreq)
            with open(outname+str(k)+'.out','r') as tempfile:
                for line in tempfile:
                    if "harminv0:" in line:
                        try:
                            freq = float(line.split(',')[1])
                        except:
                            continue # line is first line containing basic info
                        outline = ','.join(line.split(',')[1:]).strip('\n\r')
                        outline = str(kx)+','+str(ky)+','+str(parval)+','+outline+'\n'
                        ffreq.write(outline)
                        i = 0
                        while i<nummodes:
                            if abs(reffreq-freq) < freqs[i][2]:
                                temp = [i,freq,float(line.split(',')[3]),abs(reffreq-freq)]
                                i = i+1
                                while i<nummodes:
                                    freqs[i] = freqs[i-1][:]
                                    i = i+1
                                freqs[temp[0]] = temp[1:]
                            i = i+1
                print freqs
            ffreq.close()
            f[k].close()        # clear file
            f[k] = open(outname+str(k)+'.out','w')
            # after we have found the list of frequencies, append to pids
            freqvals = [0,1,2]
            if abs(freqs[2][0]-10)<1e-6:
                freqvals = [0,1]
                if abs(freqs[1][0]-10)<1e-6:
                    freqvals = [0]
            pids[k].append([freqs[i][:] for i in freqvals])
            print pids
            # now run narrow band simulations, run first one
            print pids[k][2]
            curfreq = pids[k][3].pop()
            print "Finding mode number"+str(len(freqvals)-len(pids[k][3]))+":"
            print curfreq[0]
            commandlist = ["meep"]
            runpoint = pids[k][2]
            for key in runpoint:
                commandlist.append(key+"="+str(runpoint[key]))
            commandlist.append('fileprefix="narrowrun'+str(k)+'"')
            commandlist.append("fcen="+str(curfreq[0]))
            commandlist.append("df="+str(0.01))
            commandlist.append("modenum="+str(len(freqvals)-len(pids[k][3])))
            commandlist.append(run2name+'.ctl')
            print commandlist
            pid = subprocess.Popen(commandlist,stdout=f[k])
            #pid = pid.pid
            pids[k][0:2] = [pid,1]
        elif pids[k][1]>=1:     # finished narrow scan
            if makefig == 1:
                os.system("h5topng -S3 -y -0 -RZc dkbluered -C "+"narrowrun"+str(k)+"-eps-000000.00.h5 "+"narrowrun"+str(k)+"-ez-*.h5")
                #bp()
                gifname = run2name
                for key in pids[k][2]:
                    gifname += "_"+key+str(pids[k][2][key])
                gifname += "_"+str(len(freqvals)-len(pids[k][3]))+'-ez-fp.gif'
                print gifname
                os.system("convert narrowrun"+str(k)+"-ez-*.png "+gifname)
            # it appears that subprocess doesn't wait for a return
            print "removing previous .h5 and .png files"
            os.system("rm narrowrun"+str(k)+"*.png narrowrun"+str(k)+"*.h5")
            with open(endname+'.csv','a') as ftemp:
                outline = ''
                #bp()
                for line in open(outname+str(k)+".out"):
                    if "harminv0" in line:
                        #bp()
                        try:
                            float(line.split(',')[1])
                        except:
                            continue # line is first line containing basic info
                        #if outline:
                        #    outline = ''
                        #    break
                        outline = ','.join(line.split(',')[1:]).strip('\n\r')+','
                    if "Data point:" in line:
                        #bp()
                        if outline:
                            outline += ','.join(line.split(',')[1:])
                print outline
                if outline:
                    ftemp.write(outline)
                f[k].close()
                f[k] = open(outname+str(k)+'.out','w')
            if pids[k][3]: # more modes to run
                print pids[k][2]
                curfreq = pids[k][3].pop()
                print "Finding mode number "+str(len(freqvals)-len(pids[k][3]))+":"
                print curfreq[0]
                commandlist = ["meep"]
                runpoint = pids[k][2]
                for key in runpoint:
                    commandlist.append(key+"="+str(runpoint[key]))
                commandlist.append('fileprefix="narrowrun'+str(k)+'"')
                commandlist.append("fcen="+str(curfreq[0]))
                commandlist.append("df="+str(0.01))
                commandlist.append("modenum="+str(len(freqvals)-len(pids[k][3])))
                commandlist.append(run2name+'.ctl')
                print commandlist
                pid = subprocess.Popen(commandlist,stdout=f[k])
                #pid = pid.pid
                pids[k][0:2] = [pid,1]
            else:               # finished this k-point
                run2count += 1
                pids[k] = [0]
                print len(kxlist)*len(kylist)
                print "Running time until current point: "+str(time.time()-starttime)

print "total time is: "+str(time.time()-starttime)
os.system("rm datalog*.out")
