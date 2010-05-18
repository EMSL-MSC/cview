#!/usr/bin/env python
# -*- coding: latin-1 -*-

# This file utilizes the CVIEW graphics system, which is goverened by the following License
#
# Copyright © 2008,2009, Battelle Memorial Institute
# All rights reserved.
#
# 1.    Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
#       to any person or entity lawfully obtaining a copy of this software and
#       associated documentation files (hereinafter âe Softwareâ  
#       and use the Software in source and binary forms, with or without
#       modification.  Such person or entity may use, copy, modify, merge, publish,
#       distribute, sublicense, and/or sell copies of the Software, and may permit
#       others to do so, subject to the following conditions:
#
#       â      Redistributions of source code must retain the above copyright
#               notice, this list of conditions and the following disclaimers.
#       â      Redistributions in binary form must reproduce the above copyright
#               notice, this list of conditions and the following disclaimer in the
#               documentation and/or other materials provided with the distribution.
#       â      Other than as used herein, neither the name Battelle Memorial
#               Institute or Battelle may be used in any form whatsoever without the
#               express written consent of Battelle.
#       â      Redistributions of the software in any form, and publications based
#               on work performed using the software should include the following
#               citation as a reference:
#
#                       (A portion of) The research was performed using EMSL, a
#                       national scientific user facility sponsored by the
#                       Department of Energy's Office of Biological and
#                       Environmental Research and located at Pacific Northwest
#                       National Laboratory.
#
# 2.    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#       AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#       IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#       ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE OR CONTRIBUTORS BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#       THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# 3.    The Software was produced by Battelle under Contract No. DE-AC05-76RL01830
#       with the Department of Energy.  The U.S. Government is granted for itself
#       and others acting on its behalf a nonexclusive, paid-up, irrevocable
#       worldwide license in this data to reproduce, prepare derivative works,
#       distribute copies to the public, perform publicly and display publicly, and
#       to permit others to do so.  The specific term of the license can be
#       identified by inquiry made to Battelle or DOE.  Neither the United States
#       nor the United States Department of Energy, nor any of their employees,
#       makes any warranty, express or implied, or assumes any legal liability or
#       responsibility for the accuracy, completeness or usefulness of any data,
#       apparatus, product or process disclosed, or represents that its use would
#       not infringe privately owned rights.

# Author: Chris Simmons <christopher.simmons@pnl.gov>

import subprocess
import sys
import os
import string
import re
from histo import cviewHisto
import time
from datetime import date
from datetime import timedelta

def sort(x1, x2):
	"""Sort cview histograms according to chinook node name schema.
	The sorting algorithm sorts node names of the format cu[1-12]n[1-194].  The
	sorting is numerical with the first number group having precedence of the 
	second group.
	"""

	x1list = x1[2:].split("n")
	x2list = x2[2:].split("n")
	x1zero = int(x1list[0])
	x1one = int(x1list[1])
	x2zero = int(x2list[0])
	x2one = int(x2list[1])

	if x1zero > x2zero:
		return 1
	elif x1zero == x2zero:
		if x1one > x2one:
			return 1
		elif x1one == x2one:
			return 0
		else:
			return -1
	else:
		return -1

class nstatHistos:
	"""Creates nstat Histograms for use by Cview.
	The histograms created are:
        
        reboots_per_day: A per day accumulation of reboot logs.
        reboot_total: An accumulation of reboot logs over life of system.
        reboot_frequency: Frequency of reboots calculated by 
           'Accumulation of total reboots thus far / days past since inception'
        hdd_failures: An accumulation of hdd failures over life of system.  This
            algorithm takes special care to avoid counting hdd swaps (hdd's swapped
            for speed performance purposes, not failure). 

        **Required:  Must have 'nstat' directory present in the current directory**
	"""
	def __init__(self, startDate = '2009,01,01', nameTest = 'cu(?P<cuname>[0-9]+)n(?P<nodename>[0-9]+):$', 
		     command = 'master -w cu[1-12]n[1-194] -p -f', sortFunction = sort):
		"""Initialize nstatHisto with default values set to work with Chinook.
		@param startDate String: Date to start collecting data. Format = 'YYYY,MM,DD'
		@param nameTest String: Regular Expression used to test log file for node names.
		@param command String: Master command to use for collection (MUST INCLUDE 'master').
		@param sortFunction Callable: Function to sort X ticks of Histo.
		"""
		self.nodeBootHisto = cviewHisto('nstat', 'reboots_per_day', 'Reboots', False, True) 
	        self.nodeBootTotalHisto = cviewHisto('nstat', 'reboot_total', 'Reboots', True, True)
       		self.nodeBootFreqHisto = cviewHisto('nstat', 'reboot_frequency', 'Reboots/Time', False, True)
        	self.nodeHDDFailureHisto = cviewHisto('nstat', 'hdd_failures', 'HDD_Changed', True, True)

		self.nodeBootHisto.setxTickSort(sort)
		self.nodeBootTotalHisto.setxTickSort(sort)
		self.nodeBootFreqHisto.setxTickSort(sort)
		self.nodeHDDFailureHisto.setxTickSort(sort)

		dateList = startDate.split(',');
		self.startDate = date(int(dateList[0]), int(dateList[1]), int(dateList[2]))
		self.nameTest = re.compile(nameTest)

		self.command = command
		
	def gather(self):
		"""Collect information from master and generate Histograms.
		"""
		bootNum = 0
        	bootTotal = 0.0
        	daysPast = 1.0
        	hddList = []
        	hddBadHash = {}
        	hddCount = 0
		currentDate = self.startDate

        	Masterpipe = subprocess.Popen((str(self.command)), bufsize=1,
                	                        stdout=subprocess.PIPE,
                        	                close_fds=True, shell=True,
                                	        executable="/bin/bash")

        	for line in Masterpipe.stdout.readlines():
                	if line != "":
                        	#First line of new node log
                        	if self.nameTest.match(line):
                                	nodeName = line[:-2]
                                	currentDate = date(2009,01,01)          #Boot logging wasn't present until 2009-01-01
                                	bootTotal = 0.0                         #Total cumulative boots per node
                                	bootNum = 0                             #Total cumulative boots for a single day on one node
                                	daysPast = 1.0                          #Day counter for frequency calculation
                                	self.nodeBootHisto.set(nodeName, currentDate.isoformat(), bootNum)
                                	self.nodeBootFreqHisto.set(nodeName, currentDate.isoformat(), bootTotal/daysPast)
                        	#Correct gap in dates of reboots (protect graph uniformity among nodes)
                        	elif currentDate.timetuple() < time.strptime(line[2:12], "%Y-%m-%d"):
                                	while (currentDate.timetuple() < time.strptime(line[2:12], "%Y-%m-%d")):
                                        	currentDate = currentDate + timedelta(days=1)
                                        	daysPast = daysPast + 1.0
                                        	bootNum = 0
                                        	self.nodeBootHisto.set(nodeName, currentDate.isoformat(), bootNum)
                                        	self.nodeBootFreqHisto.set(nodeName, currentDate.isoformat(), bootTotal/daysPast)
                        	if currentDate.isoformat() in line:
                                	#Found a boot_time?
                                	if "boot_time" in line:
                                        	bootTotal = bootTotal + 1.0
                                        	bootNum = bootNum + 1
                                	self.nodeBootHisto.set(nodeName, currentDate.isoformat(), bootNum)
                                	self.nodeBootFreqHisto.set(nodeName, currentDate.isoformat(), bootTotal/daysPast)

                        	#If HDD serial present, append to appropriate list/dictionary
                        	if re.search(":[1-8].serial", line):
                                	if daysPast == 1:
                                        	hddList.append(line.split().pop())
                                	else:
                                        	hddBadHash[(nodeName, currentDate.isoformat())] = line.split().pop()

        	for test in hddBadHash:
                	if hddBadHash[test] not in hddList:
                        	self.nodeHDDFailureHisto.set(test[0], test[1], 1)

        	Masterpipe.stdout.close()
        	self.nodeBootTotalHist = self.nodeBootTotalHisto.merge(self.nodeBootHisto)

	def writeHistos(self):
		"""Write all histogram files.
		This function will write all of the histogram files into
		the nstat directory.
		**WARNING: THE 'nstat' DIRECTORY MUST BE PRESENT!
		"""
		cviewHisto.writeToFiles()

def _test():
	"""Script for creating nstat histogram files.
	The script gathers data by calling the 'master' command and then parses
	the data as necessary to create four different histograms.  

	The histograms are:
	
	reboots_per_day: A per day accumulation of reboot logs.
	reboot_total: An accumulation of reboot logs over life of system.
	reboot_frequency: Frequency of reboots calculated by 
	   'Accumulation of total reboots thus far / days past since inception'
	hdd_failures: An accumulation of hdd failures over life of system.  This
	    algorithm takes special care to avoid counting hdd swaps (hdd's swapped
	    for speed performance purposes, not failure). 
  
	**Required:  Must have 'nstat' directory present in the	current directory**
	"""

	print 'nstat script'
	command = "master -w cu[1-12]n[1-194] -p -f"
	print command
	histos = nstatHistos()
	histos.gather()
	histos.writeHistos()

if __name__ == '__main__':
	_test()
