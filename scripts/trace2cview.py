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

# Author: Arthur J. Wanner, Jr. <arthur.wanner@pnl.gov>

import sys
import getopt
import os
import re
import math
import pickle
import select
from histo import cviewHisto

def timeToSec(hour, min, sec):
	# all params can be str so convert to flt
	hoursToSec = float(hour) * 3600
	minToSec = float(min) * 60
	return hoursToSec + minToSec + float(sec)

def usage():
	print '''
Usage: trace2cview [OPTION] ...
Transforms directory of strace or ltrace data to cview files

Options:
--help                      Print program usage
-i /Input/Dir/Path          Location of input directory
-o /Output/Dir/Path         Location to write cview files
    If input and output directories are not specified, they default
    to the current working directory.
-c numChildren
    The number of worker children to fork.  Default is 8.
    Can be set to 0 to use no subprocesses.
--mode=(pid)|(node)
    Group the xticks by node or by process id, the default is by pid
--resolution=(\d+)([m|s])
    where (\d+) == some integer and ([m|s]) == Minutes or Seconds
    This is size of the time bucket in minutes or seconds and will
    affect the way the histogram looks.
    The default resolution is 1 sec time buckets.	
--rate=(B|KB|MB|GB)
    This setting determines how the z-values for the read/write rate
    histograms will be calculated.  The default value is KB.  If the
    user specifies a resolution of 30 seconds and 5000 Bytes have been
	read over that time interval, this gives a default read rate of
	rate = (5KB / 30s) = 0.1666 KB/s for that 30s bucket.

Ex: ./trace2cview -i /home/myname/input/ --resolution=30s
Ex: ./trace2cview --rate=MB
Ex: ./trace2cview -o outputDir/ --mode=node
'''

# Parse Command-Line arguments
try:
	optlist, xtra_args = getopt.gnu_getopt(sys.argv[1:], 'i:o:c:',
							 ['resolution=', 'mode=', 'rate=', 'help'])
except getopt.GetoptError, err:
	usage()
	sys.exit(err) # Exit program if invalid command-line

# Exit program if extra arguments exist
if xtra_args != []:
	usage()
	sys.exit('Invalid Command-Line Arguments!')

# Setup program parameter defaults
homeDir = os.getcwd() # home directory of process
scanDir = os.getcwd() # directory to get strace data from
outDir = os.getcwd()  # directory to write cview files to
numChildren = 8 # number of child process workers to fork
res = 'default' # time bucket resolution set to default
mode = 'pid'	# default mode is to group xticks by process id
rateConversion = 1000 # default rate is in KB, 1000B/KB
rateUnit = 'KB'

# if command-line args exist, store in program parameters
for option, arg in optlist:
	if option == '-i':
		scanDir = arg
	elif option == '-o':
		outDir = arg
	elif option == '-c':
		numChildren = int(arg)
	elif option == '--resolution':
		res = arg
	elif option == '--mode':
		mode = arg
	elif option == '--rate':
		if arg != 'B' and arg != 'KB' and arg != 'MB' and arg != 'GB':
			usage()
			sys.exit('Invalid rate argument: "' + arg + '"')
		else:
			if arg == 'B':
				rateConversion = 1
				rateUnit = 'B'
			elif arg == 'MB':
				rateConversion = 1000000
				rateUnit = 'MB'
			elif arg == 'GB':
				rateConversion = 1000000000
				rateUnit = 'GB'
	elif option == '--help':
		usage()
		sys.exit(0)

# Make sure I/O directories exist, check directory readable writable
for dir in (scanDir, outDir):
	if not os.path.isdir(dir):
		sys.exit('Directory does not exit: "' + dir + '"')
if not os.access(scanDir, os.R_OK):
	sys.exit('Read access denied: "' + scanDir + '"')
if not os.access(outDir, os.W_OK):
	sys.exit('Write access denied: "' + outDir + '"')

# Validate resolution given via command-line
if res != 'default':
	r = re.compile('^(\d+)([sm])$') # integer followed by 's' or 'm'
	m = r.match(res)
	if m != None:
		if m.group(2) == 's':
			res = int(m.group(1))
		else: # resolution in minutes
			res = int(m.group(1)) * 60
	else:
		usage()
		sys.exit('Invalid resolution: "' + res + '"')
else:
	res = 1 # default resolution is 1 sec

histos = {}
node_pid_RE = re.compile('^(\w+)\.(\d+)$')
time_syscall_RE = re.compile('^(?:\d+ +)?(\d\d):(\d\d):(\d\d\.\d{6}) (?:<\.\.\. )?(\w+)')
bytes_latency_RE = re.compile('^.+ (\d+) <((?:[\d\.])+)>$')

def processFile(filename):
	m = node_pid_RE.match(filename) # Extract Node name & pid from filename
	if not m:	# filename doesn't match don't process file
		sys.stderr.write('node_pid no match on file: "' + filename + '"\n')
		return
	node = m.group(1)
	pid = m.group(2)
	if mode == 'node':
		xtick = node
	else: # else mode=='pid'
		xtick = node + '.' + pid

	try:
		f = open(filename, 'r')
	except:
		sys.stderr.write('could not open file: "' + filename + '"\n')
		return;

	m = None
	while not m:
		try:
			m = time_syscall_RE.match(f.next())
		except:
			sys.stderr.write('no matching lines in file: "' + filename + '"\n')
			return

	prevTime = timeToSec(m.group(1), m.group(2), m.group(3))
	prevHour = m.group(1)
	totalElapsedTime = 0.0

	for line in f:
		m = time_syscall_RE.match(line)
		if not m:
			continue # skipping line that did not match
		currentTime = timeToSec(m.group(1), m.group(2), m.group(3))
		currentHour = m.group(1)
		syscall = m.group(4)
		if not histos.has_key(syscall):
			# create new cviewHisto object
			histos[syscall] = cviewHisto(outDir, syscall, 'Calls', False, True)

		m = bytes_latency_RE.match(line)
		latencyTag = 'ave_' + syscall + '_latency'
		if m:
			bytes = int(m.group(1))
			latency = float(m.group(2)) * 1E6
		else:
			bytes = 0
			latency = 0.0
		if not histos.has_key(latencyTag):
			histos[latencyTag] = cviewHisto(outDir,latencyTag,'usec',False,True)

		if syscall == 'read' or syscall == 'write':
			bTag = syscall + '_cumulative'
			rateTag = syscall + '_rate'
			if not histos.has_key(bTag):
				histos[bTag] = cviewHisto(outDir, bTag, 'Bytes', True, True)
			if not histos.has_key(rateTag):
				histos[rateTag] = cviewHisto(outDir, rateTag,
									rateUnit + '/s', False, True)

		# time rolled over
		if currentTime < prevTime and currentHour < prevHour:
			# add (24Hr * 3600sec/Hr = 86400.0sec)
			elapsedTime = (currentTime + 86400.0) - prevTime
		elif currentTime > prevTime:
			elapsedTime = currentTime - prevTime
		else:
			elapsedTime = 0

		prevTime = currentTime; prevHour = currentHour

		while elapsedTime > res:
			totalElapsedTime += res
			timeBucket = int(totalElapsedTime) / res * res + res

			histos[syscall].set(xtick, timeBucket, 0)
			histos[latencyTag].set(xtick, timeBucket, 0)
			if syscall == 'read' or syscall == 'write':
				histos[bTag].set(xtick, timeBucket, 0)
				histos[rateTag].set(xtick, timeBucket, 0)

			elapsedTime -= res
		else:
			totalElapsedTime += elapsedTime
			timeBucket = int(totalElapsedTime) / res * res + res

			histos[syscall].incr(xtick, timeBucket)

			prevAve = histos[latencyTag].getZ(xtick, timeBucket)
			if not prevAve: # might be None if datapoint doesn't exist
				prevAve = 0.0
			count = histos[syscall].getZ(xtick, timeBucket)
			latencyAve = (latency + (count - 1)*prevAve)/count
			histos[latencyTag].set(xtick, timeBucket, latencyAve)

			if syscall == 'read' or syscall == 'write':
				histos[bTag].incr(xtick, timeBucket, bytes)
				bytesRate = float(bytes) / rateConversion / res
				histos[rateTag].incr(xtick, timeBucket, bytesRate)


# create children
os.chdir(scanDir)
inputPipeList = []
outputPipeList = []
for c in range(numChildren):
	parentIn, childOut = os.pipe()
	childIn, parentOut = os.pipe()

	pid = os.fork()
	if pid:
		os.close(childOut) # in parent after fork, so close child pipe ends
		os.close(childIn)
		parentIn = os.fdopen(parentIn, 'r', 0) # wrap fd with stdio object
		parentOut = os.fdopen(parentOut, 'w', 0)
		inputPipeList.append(parentIn)
		outputPipeList.append(parentOut)
	else:
		os.close(parentIn) # in child after fork, close parent pipe ends
		os.close(parentOut)
		childIn = os.fdopen(childIn, 'r', 0)
		filename = childIn.readline().rstrip()
		while filename:
			processFile(filename)
			filename = childIn.readline().rstrip()
		p = pickle.dumps(histos)
		os.write(childOut, p)
		os.close(childOut)
		sys.exit(0)


# give out work(files to parse) to children
filesList = os.listdir('.')
i = 0
for f in filesList:
	if numChildren == 0:
		processFile(f)
	else:
		outputPipeList[i].write(f + '\n')
		i += 1
		i %= numChildren

for i in range(numChildren):
	outputPipeList[i].write('\n') # send xtra '\n' to avoid deadlocks
	outputPipeList[i].close()

# wait for results to be sent back from children
while inputPipeList != []:
	(readable, wL, xL) = select.select(inputPipeList, [], [])
	for reader in readable:
		childHistos = pickle.loads(reader.read())
		for h in childHistos.keys():
			if not histos.has_key(h):
				histos[h] = cviewHisto(childHistos[h].group,
					childHistos[h].desc, childHistos[h].rate,
					childHistos[h].isCumulative, childHistos[h].isSharedY)
			histos[h].merge(childHistos[h])

		# clean up the child that just finished
		reader.close()
		inputPipeList.remove(reader)
		(cpid, status) = os.wait()
		if status != 0:
			errMssg = 'Child pid ' + str(cpid) + ' exit status = ' + str(status)
			sys.stderr.write(errMssg + '\n')



# write all histos to files
os.chdir(homeDir)
cviewHisto.writeToFiles()
