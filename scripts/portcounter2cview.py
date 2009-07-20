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


from histo import *
import sys
import csv
import re

gridnames = "SymErr, LinkRecovers, LinkDowned, RcvErr, RcvRemotePhys, RcvSwitchRelay, XmtDiscards, XmtConstraint, RcvConstraint, LocalLinkInteg, ExcessBufOvrrun, VL15Dropped, XmitBytes (GB), XmitBytes Rate (MB/Sec), RcvBytes (GB), RcvBytes Rate (MB/Sec), XmitPkts, XmitPkts/Sec, RcvPkts, RcvPkts/Sec, XmitWaits".split(", ")
upgrids = dict([(i,cviewHisto(i.replace("/","_").replace(" ",".").replace("(","").replace(")",""),'None')) for i in gridnames])
#downgrids = dict([(i,cviewHisto(i.replace("/","_").replace(" ",".").replace("(","").replace(")",""),'None')) for i in gridnames])

a_node = re.compile("cu[0-9]*n[0-9]*.*")
a_spine = re.compile(".*spine.*")
a_switch = re.compile(".*ibsw.*")
a_matcher = re.compile("cu([0-9]*)([a-z]*)([0-9]*).*")

PEERNAME=49
NAME=15
LID=0
IBPORT=1
namecode=[LID,IBPORT,NAME]
namedict={}

def isup(order,row):
	if a_spine.match(row[PEERNAME]):
		return True
	if a_switch.match(row[PEERNAME]) and a_node.match(row[NAME]):
		return True
	return False


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
		print o,t,namedict[o],namedict[t]
		print msg
		return c

def main(csvs,direcory):
	for pc in csvs:
		input = open(pc,'r')
		date = input.readline().rstrip()
		order=''
		while not order:
			order=input.readline().strip()
		order=order.split(", ")

		csvreader = csv.reader(input,skipinitialspace=True)

		for row in csvreader:
			if not row: break # dump the final summary

			name="(%s,%s,%s)"%(tuple([row[i] for i in namecode]))
			namedict[name]=row[NAME]
			if isup(order,row):
				g=upgrids
				#else:
				#	g=downgrids
				for key,histo in g.items():
					try:
						histo.set(name,date,float(row[order.index(key)]))
					except ValueError,msg:
						#print msg,name,date,key,row[order.index(key)]
						pass

	#grids['XmitPkts'].printGrid()
	for key,histo in upgrids.items():
		histo.writeToFile(direcory+"/up")
	histo.setxTickSort(hostsort)
	cviewHisto.write_xTick_index(direcory+"/up")
	#for key,histo in downgrids.items():
	#	histo.writeToFile(direcory+"/down")
	#cviewHisto.write_xTick_index(direcory+"/down")


if __name__ == "__main__":
	main(sys.argv[1:],'/tmp/pc')
