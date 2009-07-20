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



import sys
import readline
import urllib
import string
import fcntl
import struct
import termios
import os

header=""" {
    height = <*I600>;
    name = "%(name)s";
    width = <*I1200>;
    worlds = (
        {
            col = <*I0>;
            colp = <*I50>;
            name = TL;
            row = <*I0>;
            rowp = <*I50>;
            world = {
                eye = {
                    hangle = <*R-4.72>;
                    vangle = <*R-2.45>;
                    x = <*R514>;
                    y = <*R2585>;
                    z = <*R1617>;
                };
                scene = {
                    objects = (
					"""
oneobj="""    
					{
                            object = {
                                dataSet = {
                                    baseURL = "%(url)s";
                                    key = %(key)s;
                                };
                                dataSetClass = WebDataSet;
                                fontScale = <*R1>;
                                isVisible = <*BY>;
                                xTicks = <*I50>;
                                yTicks = <*I32>;
                            };
                            objectclass = GLGrid;
                            x = <*R%(x)d>;
                            y = <*R0>;
                            z = <*R%(y)d>;
                        },
					"""
                       
footer="""
                    );
                };
            };
        }
    );
}
"""

histfile = os.path.join(os.environ["HOME"], ".cviewhist")
try:
    readline.read_history_file(histfile)
except IOError:
    pass
import atexit
atexit.register(readline.write_history_file, histfile)
del os, histfile


(rows,cols,_d,_d) = struct.unpack("HHHH",fcntl.ioctl(sys.stdout.fileno(), termios.TIOCGWINSZ, struct.pack("HHHH", 0, 0, 0, 0)))



def select_metrics(metrics):
	global default
	metrics.sort()
	maxlen=reduce(max,[len(i) for i in metrics])
	print maxlen
	numcols=cols/(maxlen+2);
	numrows=rows - 5
	print numcols
	
	sel="cpu_user"
	pages=len(metrics)/(numrows*numcols)+1;
	perpage=len(metrics)/pages;
	print perpage,pages
	for page in range(pages):
		for row in range(numrows):
			for col in range(numcols):
				if page*perpage+row*numcols+col < len(metrics):
					print "%*s"%(maxlen,metrics[page*perpage+row*numcols+col]),
			print 
		default=sel
		sel=raw_input("Enter Metrics(, separated) [page %d of %d]: "%(page+1,pages))

	mets=sel.split(",")
	ret=[]
	for m in mets:
		if m in metrics:
			ret.append(m);
		else:
			print "bad metric:",m
	return ret

def p():
	global default
	readline.insert_text(default)
	readline.redisplay()
	default=""

def main():
	global default
	readline.set_pre_input_hook(p)
	name=raw_input("Enter Name: ")
	
	default="http://chumbucket.emsl.pnl.gov/cluster/chinook"
	url=raw_input("Enter URL: ")
	
	if url[-1] != '/':
		url+='/'
	
	data=urllib.urlopen(url+"index")
	index=map(string.rstrip,data.readlines())
	tic=urllib.urlopen(url+"xtick");
	gwidth=len(tic.read())/32
	print len(index),"Data types found. Width:",gwidth
	gwidth+=150
	
	metrics=select_metrics(index);

	print "Selected ",len(metrics),"metrics: ",`metrics`
	
	w=max(1,len(metrics)/5);
	default=str(w);
	width=raw_input("Grid Width: ")

	ylenmax = 0
	for met in metrics:
		ytick = urllib.urlopen(url+met+".ytick")
		ylength = len(ytick.read())/32
		ylenmax = max(ylenmax, ylength) # max y-axis length of all histos
	ylenmax += 150 # add some padding

	
	default = name.replace(" ","_")+".cview"
	filename = raw_input("Filename: ");
	
	file=open(filename,"w");
	file.write(header%(locals()))
	x=0
	y=0
	for key in metrics:
		if x>=int(width)*gwidth:
			x=0
			y += ylenmax # take into consideration max yaxis length
		file.write(oneobj%(locals()))
		x+=gwidth
	
	file.write(footer%(locals()))
	
	
if __name__ == '__main__':
	main()
