#!/usr/bin/env python



# This file is port of the CVIEW graphics system, which is goverened by the following License
# 
# Copyright © 2008,2009, Battelle Memorial Institute
# All rights reserved.
# 
# 1.	Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
# 	to any person or entity lawfully obtaining a copy of this software and
# 	associated documentation files (hereinafter “the Software”) to redistribute
# 	and use the Software in source and binary forms, with or without
# 	modification.  Such person or entity may use, copy, modify, merge, publish,
# 	distribute, sublicense, and/or sell copies of the Software, and may permit
# 	others to do so, subject to the following conditions:
# 
# 	•	Redistributions of source code must retain the above copyright
# 		notice, this list of conditions and the following disclaimers. 
# 	•	Redistributions in binary form must reproduce the above copyright
# 		notice, this list of conditions and the following disclaimer in the
# 		documentation and/or other materials provided with the distribution.
# 	•	Other than as used herein, neither the name Battelle Memorial
# 		Institute or Battelle may be used in any form whatsoever without the
# 		express written consent of Battelle.  
# 	•	Redistributions of the software in any form, and publications based
# 		on work performed using the software should include the following
# 		citation as a reference:
# 
# 			(A portion of) The research was performed using EMSL, a
# 			national scientific user facility sponsored by the
# 			Department of Energy's Office of Biological and
# 			Environmental Research and located at Pacific Northwest
# 			National Laboratory.
# 
# 2.	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# 	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# 	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# 	ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE OR CONTRIBUTORS BE LIABLE FOR ANY
# 	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# 	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# 	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# 	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# 	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# 	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# 3.	The Software was produced by Battelle under Contract No. DE-AC05-76RL01830
# 	with the Department of Energy.  The U.S. Government is granted for itself
# 	and others acting on its behalf a nonexclusive, paid-up, irrevocable
# 	worldwide license in this data to reproduce, prepare derivative works,
# 	distribute copies to the public, perform publicly and display publicly, and
# 	to permit others to do so.  The specific term of the license can be
# 	identified by inquiry made to Battelle or DOE.  Neither the United States
# 	nor the United States Department of Energy, nor any of their employees,
# 	makes any warranty, express or implied, or assumes any legal liability or
# 	responsibility for the accuracy, completeness or usefulness of any data,
# 	apparatus, product or process disclosed, or represents that its use would
# 	not infringe privately owned rights.  


from numpy import *
import sys
import csv
import re
import struct
import os
import string
import time

gridnames = "SymErr, LinkRecovers, LinkDowned, RcvErr, RcvRemotePhys, RcvSwitchRelay, XmtDiscards, XmtConstraint, RcvConstraint, LocalLinkInteg, ExcessBufOvrrun, VL15Dropped, XmitBytes (GB), XmitBytes Rate (MB/Sec), RcvBytes (GB), RcvBytes Rate (MB/Sec), XmitPkts, XmitPkts/Sec, RcvPkts, RcvPkts/Sec, XmitWaits".split(", ")

a_node = re.compile("cu[0-9]*n[0-9]*.*")
a_spine = re.compile(".*spine.*")
a_switch = re.compile(".*ibsw.*")
a_matcher = re.compile("cu([0-9]*)([a-z]*)([0-9]*).*")

PEERNAME=49
NAME=15
LID=0
IBPORT=1
namecode=[LID,IBPORT]
namedict={}

_trans=string.maketrans("/ ","_.")
def cleanname(name):
	return name.translate(_trans,"()")

def isup(row):
	try:
		if a_spine.match(row[PEERNAME]):
			return True
		if a_switch.match(row[PEERNAME]) and a_node.match(row[NAME]):
			return True
		return False
	except IndexError:
		print "isup confused:",row,PEERNAME,NAME

def datesort(o,t):
	one = time.strptime(o)
	two = time.strptime(t)
	return cmp(one,two)


def hostsort(o,t):
	c=0
	try:
		one=namedict[o]
		two=namedict[t]
		og=a_matcher.match(one).groups()
		tg=a_matcher.match(two).groups()

		c=cmp(og[1],tg[1])
		if c: return c
		c=cmp(int(og[0]),int(tg[0]))
		if c: return c
		return cmp(int(og[2]),int(tg[2]))
	except Exception,msg:
		#print o,t,namedict[o],namedict[t]
		#print one,two
		#print msg
		return cmp(one,two)

def reversehostsort(o,t):
	return -hostsort(o,t)

def dumpdata(key,data,yticks,dirname):
	open("%s/%s.rate"%(dirname, key),"w").write("?")
	open("%s/%s.desc"%(dirname, key),"w").write(key)

	f = open("%s/%s.ytick"%(dirname, key),"w")
	for yTick in yticks:
		f.write(struct.pack('32s', str(yTick)))
	f.close()

	print data.shape
	f = open('%s/%s.data' % (dirname, key), 'w')
	f.write(data.tostring())
	f.close()

	

def main(csvs,direcory):
	up_xTicks=set()
	down_xTicks=set()
	dates=set()
	ctmp = csvs[:]
	for pc in ctmp:
		input = open(pc,'r')
		date = input.readline().rstrip()
		if date in dates:
			csvs.remove(pc)
			continue
		dates.add(date)
		order=''
		while not order:
			order=input.readline().strip()
		order=order.split(", ")

		csvreader = csv.reader(input,skipinitialspace=True)

		for row in csvreader:
			if not row: break # dump the final summary
			thename=row[NAME].replace(" HCA-1","")
			name="(%s,%s,%s)"%(tuple([row[i] for i in namecode]+[thename]))
			namedict[name]=thename
			if isup(row):			
				up_xTicks.add(name)
			else:
				down_xTicks.add(name)

		input.close()

	upsize=(len(up_xTicks),len(csvs))
	downsize=(len(down_xTicks),len(csvs))
	print "Size:",upsize,downsize
	print "Lens",len(dates),len(csvs),len(up_xTicks),len(down_xTicks)

	upgrids   = dict([(cleanname(i),zeros(upsize,'f')) for i in gridnames])
	downgrids = dict([(cleanname(i),zeros(downsize,'f')) for i in gridnames])
	
	up_xTicks = list(up_xTicks)
	up_xTicks.sort(hostsort)
	down_xTicks = list(down_xTicks)
	down_xTicks.sort(reversehostsort)
	yTicks = list(dates)
	yTicks.sort(datesort)

	#print up_xTicks

	for pc in csvs:
		print pc
		input = open(pc,'r')
		date = input.readline().rstrip()
		y=yTicks.index(date)

		order=False
		while not order:
			order=input.readline().strip()
		order=order.split(", ")
		order=[cleanname(i) for i in order]
		csvreader = csv.reader(input,skipinitialspace=True)

		for row in csvreader:
			if not row: break # dump the final summary
			thename=row[NAME].replace(" HCA-1","")
			name="(%s,%s,%s)"%(tuple([row[i] for i in namecode]+[thename]))
			if isup(row):
				g=upgrids
				x=up_xTicks.index(name)
			else:
				g=downgrids
				x=down_xTicks.index(name)
			for key,data in g.items():
				try:
					#print order
					#print row
					#print x,y,order.index(key),row[order.index(key)],key		
					data[x,y]=float(row[order.index(key)])
				except ValueError,msg:
					if row[order.index(key)]=='N/A' or row[order.index(key)]=='Overflow':
						pass
					else:
						print "Data err:",row
						print x,y,key
						print order
						print msg
						pass

		input.close()
	
	#output
	print len(yTicks)
	index=open(direcory+"/up/index","w")
	for key,data in upgrids.items():
		index.write("%s\n"%(key))
		dumpdata(key,data,yTicks,direcory+"/up")
	index.close()

	index=open(direcory+"/down/index","w")
	for key,data in downgrids.items():
		index.write("%s\n"%(key))
		dumpdata(key,data,yTicks,direcory+"/down")
	index.close()


	print len(up_xTicks),len(down_xTicks)
	f = open(direcory+'/up/xtick', 'w')
	for tick in up_xTicks:
		f.write(struct.pack('32s', str(tick)))
	f.close()

	f = open(direcory+'/down/xtick', 'w')
	for tick in down_xTicks:
		f.write(struct.pack('32s', str(tick)))
	f.close()

	open("/tmp/tickfile","w").write(`yTicks`)

if __name__ == "__main__":
	main(sys.argv[1:],'/tmp/pc')
