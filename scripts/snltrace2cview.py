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
import select
import os
import re
import pickle
from histo import cviewHisto

def usage():
	print '''
Usage: snltrace2cview [OPTION] ...
Transforms directory of SNL format trace data to cview files
For more information on SNL trace format:
    http://www.cs.sandia.gov/Scalable_IO/SNL_Trace_Data/index.html

Options:
--help                      Print program usage
-i /Input/Dir/FilePath      File path of input trace file
-o /Output/Dir/DirPath      Dir path to write cview files to
    If input file is not specified, the current working directory is
    searched and the first file ending in .sanitized is used.
    If output directory is not specified, cview files are written
    to the current working directory (this could be messy).
--resolution=(\d+)([m|s])
    where (\d+) == some integer and ([m|s]) == Minutes or Seconds
    This is size of the time bucket in minutes or seconds and will
    affect the way the histogram looks.
    The default resolution is 1 sec time buckets.	

Ex: ./snltrace2cview -i /home/myname/traceFilePath --resolution=30s
Ex: ./snltrace2cview -o outputDir/
'''

# Parse Command-Line arguments
try:
	optlist, xtra_args = getopt.gnu_getopt(sys.argv[1:], 'i:o:',
							 ['resolution=', 'help'])
except getopt.GetoptError, err:
	usage()
	sys.exit(err) # Exit program if invalid command-line

# Exit program if extra arguments exist
if xtra_args != []:
	usage()
	sys.exit('Invalid Command-Line Arguments: "' + xtra_args + '"')

# Setup program parameter defaults
homeDir = os.getcwd() # home directory of process
traceFilePath = '' # trace file
outDir = homeDir  # directory to write cview files to
res = 'default' # time bucket resolution set to default

# if command-line args exist, store in program parameters
for option, arg in optlist:
	if option == '-i':
		traceFilePath = arg
	elif option == '-o':
		outDir = arg
	elif option == '--resolution':
		res = arg
	elif option == '--help':
		usage()
		sys.exit(0)

# if trace file specified, check exists
if traceFilePath:
	if not os.path.exists(traceFilePath):
		sys.exit('Specified input path does not exist: ' + traceFilePath)
else: # else trace file not specified, search for 1st .sanitized file in cwd
	for path in os.listdir('.'):
		if path.endswith('.sanitized'):
			traceFilePath = path
			break
if traceFilePath: # check again to make sure we have a traceFilePath
	if not os.path.isfile(traceFilePath):
		sys.exit('Specified path is not a file: ' + traceFilePath)
	if not os.access(traceFilePath, os.R_OK):
		sys.exit('Specified path is not a readable file: ' + traceFilePath)
else: # still no traceFilePath so exit w/ errors
	usage()
	sys.exit('Could not find an input File!')

# Make sure output directory exists and is writable
if not os.path.isdir(outDir):
	sys.exit('Directory does not exit: "' + outDir + '"')
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


def doHeader(traceFile):
	line = traceFile.readline()
	m = node_pid_RE.match(line)
	if not m:
		sys.stderr.write('node_pid_RE no match\n')
		return
	xtick = m.group(1)
	return xtick

def doEnterExitPair(traceFile):
	pair = []
	for i in range(2):
		line = traceFile.readline()
		if line.startswith('header') or line == '' or line == '\n':
			return # reached next header or eof so finished
		m = time_syscall_RE.match(line)
		if not m:
			off = traceFile.tell()
			sys.stderr.write('time_syscall_RE no match @ offset %d\n'%off)
			return
		action = m.group(1)
		sec = float(m.group(2))
		usec = float(m.group(3))
		syscall = m.group(4)
		if i == 1 and syscall != pair[0][0]:
			sys.stderr.write('ENTER/EXIT pair mismatch\n')
			return
		time = sec + usec/1E6 # usec -> sec
		pair.append((syscall, time))
	return pair

def doSection(offset):
	traceFile = open(traceFilePath, 'r')
	traceFile.seek(offset) # go to header line
	xtick = doHeader(traceFile)
	if not xtick:
		return

	# initialize time variables
	totalElapsedTime = 0.0
	off = traceFile.tell()
	line = traceFile.readline()
	m = time_syscall_RE.match(line)
	if not m:
		print off
		sys.exit(1)
	prevTime = float(m.group(2)) + float(m.group(3))/1E6 # usec -> sec
	traceFile.seek(off)

	# process ENTER/EXIT pairs until next header is reached
	pair = doEnterExitPair(traceFile)
	while pair != None: # while we have another ENTER/EXIT pair to process
		(syscall, currentTime) = pair[0] # not using pair[1] yet

		elapsedTime = currentTime - prevTime
		prevTime = currentTime

		if not histos.has_key(syscall):
			histos[syscall] = cviewHisto(outDir,
									syscall, 'Calls', False, True)

		while elapsedTime > res:
			totalElapsedTime += res
			timeBucket = int(totalElapsedTime) / res * res + res
			histos[syscall].create(xtick, timeBucket)
			elapsedTime -= res
		else:
			totalElapsedTime += elapsedTime
			timeBucket = int(totalElapsedTime) / res * res + res
			histos[syscall].incr(xtick, timeBucket)

		pair = doEnterExitPair(traceFile)



histos = {}
node_pid_RE = re.compile('^header.+headernode\((\d+\.\d+)\)')
time_syscall_RE = re.compile(
	'^tracetype\((\w+)\)time:\((\d+)\)time:\((\d+)\)str\((\w+)\)')

# find all offsets to header lines
offsets = []
f = open(traceFilePath, 'r')
line = f.readline()
while line:
	if line.startswith('header'):
		offsets.append(f.tell() - len(line))
	line = f.readline()
f.close()

# create children
numChildren = 8
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
		offset = childIn.readline().rstrip()
		while offset:
			doSection(int(offset))
			offset = childIn.readline().rstrip()
		p = pickle.dumps(histos)
		os.write(childOut, p)
		os.close(childOut)
		sys.exit(0)

# give out work(section of traceFile to parse) to children
i = 0
for offset in offsets:
	outputPipeList[i].write(str(offset) + '\n')
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
		print 'Child pid ' + str(cpid) + ' finished with status ' + str(status)

# write all histos to files
os.chdir(homeDir)
cviewHisto.writeToFiles()
