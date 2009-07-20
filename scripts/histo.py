#!/usr/bin/env python
# -*- coding: latin-1 -*-



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

import numpy
import struct

class cviewHisto:
	"""The cviewHisto class is a data structure that python script writers
can use to dump 3d histogram data into.  It encapsulates the details of
a cview histogram.  After data collection, the class can output the 
.cview files necessary for viewing a dataset with cview.
	"""
	groups = {}
		# dict of groups of histograms
		# A group shares xticks and output directory.
		# The index into the dictionary is the 'outputDirectoryString'.
		# Each dictionary entry is a list containing references to all histos
		# in that group.

	def __init__(self, group='.', desc='None', rate='None', 
										isCumul=False, isSharedY=False):
		"""

		"""
		self.group = group # the group this histo instance belongs to
		if not cviewHisto.groups.has_key(group):
			cviewHisto.groups[group] = []
		cviewHisto.groups[group].append(self) # add self to group

		self.desc = desc # desc is the title of the histogram
		self.rate = rate # rate is the quantity label for the z-axis values
		self.xTicksList = []
		self.yTicksList = []
		self.xTickSort = cmp
		self.yTickSort = cmp # default sort function is 'cmp'
		self.isSharedY = isSharedY # we don't share yTicks by default
		self.datapoints = {} # dict of datapoints indexed by tuple (xTick,yTick)
		self.isCumulative = isCumul # default histo is not cumulative
		self.c_datapoints = {} # dict for storing cumulative data

	def __sync__(self):
		# synchronize xticks and yticks w/ group 
		for histo in cviewHisto.groups[self.group]:
			for xTick in histo.xTicksList:
				if not xTick in self.xTicksList:
					self.xTicksList.append(xTick)
			if self.isSharedY:
				for yTick in histo.yTicksList:
					if not yTick in self.yTicksList:
						self.yTicksList.append(yTick)

		# sort ticks
		self.xTicksList.sort(self.xTickSort)
		self.yTicksList.sort(self.yTickSort)

		# fill in holes in datapoints dictionary with zeros
		for xTick in self.xTicksList:
			for yTick in self.yTicksList:
				if not self.datapoints.has_key((xTick, yTick)):
					self.datapoints[(xTick, yTick)] = 0

		# create cumulative data
		if self.isCumulative:
			self.c_datapoints = {}
			for xTick in self.xTicksList:
				cumul = 0
				for yTick in self.yTicksList:
					if self.datapoints[(xTick, yTick)] != 0:
						cumul += self.datapoints[(xTick, yTick)]
					self.c_datapoints[(xTick, yTick)] = cumul


	def __str__(self): 
		self.__sync__()
		if self.isCumulative:
			dp = self.c_datapoints
		else:
			dp = self.datapoints

		strRep = ''
		for yTick in self.yTicksList:
			for xTick in self.xTicksList:
				strRep += str(dp[(xTick, yTick)]) + ' '
			strRep += '\n'

		return strRep

	def __initialize__(self, xTick, yTick):
		if not xTick in self.xTicksList:
			self.xTicksList.append(xTick)
		if not yTick in self.yTicksList:
			self.yTicksList.append(yTick)
		if not self.datapoints.has_key((xTick, yTick)):
			self.datapoints[(xTick, yTick)] = 0

	def setxTickSort(self, callable):
		"""Change the sort method used for the x-axis
		"""
		self.xTickSort = callable

	def setyTickSort(self, callable):
		"""Change the sort method used for the y-axis
		"""
		self.yTickSort = callable

	def merge(self, otherHisto):
		"""Merge another histo object with self.  The data of both
histograms is combined into the caller.
		"""
		for key in otherHisto.datapoints.keys():
			xTick = key[0]
			yTick = key[1]
			if not xTick in self.xTicksList:
				self.xTicksList.append(xTick)
			if not yTick in self.yTicksList:
				self.yTicksList.append(yTick)
			if not self.datapoints.has_key(key):
				self.datapoints[key] = 0
			self.datapoints[key] += otherHisto.datapoints[key]

	def writeToFiles():
		"""Write all cview histograms out to .cview files
		"""
		
		for dir, histos in cviewHisto.groups.items():
			# sync all histos in group and create index list
			indexList = []
			for histo in histos:
				histo.__sync__()
				indexList.append(histo.desc)

			# index and xtick files need written only once per dir of histos
			indexList.sort()
			f = open(dir + '/index', 'w')
			for index in indexList:
				f.write(index + '\n')
			f.close()

			xTicksList = histos[0].xTicksList
			f = open(dir + '/xtick', 'w')
			for xTick in xTicksList:
				f.write(struct.pack('32s', str(xTick)))
			f.close()

			# must write out all histos for a given directory group
			for histo in histos:
				pathPrefix = dir + '/' + histo.desc
				open(pathPrefix + '.rate', 'w').write(histo.rate)
				open(pathPrefix + '.desc', 'w').write(histo.desc)

				f = open(pathPrefix + '.ytick', 'w')
				for yTick in histo.yTicksList:
					f.write(struct.pack('32s', str(yTick)))
				f.close()

				if histo.isCumulative:
					dp = histo.c_datapoints
				else:
					dp = histo.datapoints
				f = open(pathPrefix + '.data', 'w')
				for xTick in histo.xTicksList:
					for yTick in histo.yTicksList:
						f.write(struct.pack('f', dp[(xTick, yTick)]))
				f.close()
	writeToFiles = staticmethod(writeToFiles) # creates static method

	def getZ(self, xTick, yTick):
		"""Return the Z-value for the specified x,y datapoint.
		"""
		try:
			return self.datapoints[(xTick, yTick)]
		except:
			return None

	def incr(self, xTick, yTick, zValue = 1):
		"""Increment the datapoint located at (xTick, yTick) by zValue.
		"""
		self.__initialize__(xTick, yTick) # make sure datapoint is initialized
		self.datapoints[(xTick, yTick)] += zValue

	def set(self, xTick, yTick, zValue):
		"""Set the datapoint to a specific Z-value.
		"""
		self.__initialize__(xTick, yTick) # make sure datapoint is initialized
		self.datapoints[(xTick, yTick)] = zValue


class numpyHisto:
	"""The numpyHisto class behaves the same and has the same interface as
cviewHisto but has a different implementation that uses the
numpy module.  The numpy module uses C-arrays for storing the
histogram data and consequently uses about a third less memory.
The trade-off is that numpyHisto is just a touch slower because
of the overhead in translating strings to integer indices.
	"""
	groups = {}

	def __init__(self, group = '.', desc='None', rate='None',
										isCumul=False, isSharedY=False):
		self.group = group # the group this histo instance belongs to
		if not cviewHisto.groups.has_key(group):
			cviewHisto.groups[group] = []
		cviewHisto.groups[group].append(self) # add self to group

		self.desc = desc # desc is the title of the histogram
		self.rate = rate # rate is the quantity label for the z-axis values
		self.xTicks = {} # tick => numpy index
		self.yTicks = {}
		self.xTickSort = cmp
		self.yTickSort = cmp # default sort function is 'cmp'
		self.isSharedY = isSharedY # don't share yTicks by default
		self.isCumulative = isCumul # default histo is not cumulative

		self.datapoints = numpy.zeros((10, 10), float)
		self.c_datapoints = None # gets set to a numpy array if isCumul

	def __sync__(self):
		# make sure number of data rows/columns are synced with
		#  other histos from group

		# synchronize xticks and yticks w/ group
		for histo in cviewHisto.groups[self.group]:
			for xTick in histo.xTicks.keys():
				if not self.xTicks.has_key(xTick):
					self.xTicks[xTick] = len(self.xTicks)
					if len(self.xTicks) > self.datapoints.shape[1]:
						self.__extendColumns__()

			if self.isSharedY:
				for yTick in histo.yTicks.keys():
					if not self.yTicks.has_key(yTick):
						self.yTicks[yTick] = len(self.yTicks)
						if len(self.yTicks) > self.datapoints.shape[0]:
							self.__extendRows__()

		# create array for storing cumulative data
		if self.isCumulative:
			self.c_datapoints = numpy.array(self.datapoints)
			for (t, col) in sorted(self.xTicks.items(), self.xTickSort):
				cumul = 0
				for (t, row) in sorted(self.yTicks.items(), self.yTickSort):
					cumul += self.datapoints[(row, col)]
					self.c_datapoints[(row, col)] = cumul

	def __str__(self): # print out histogram data
		self.__sync__()
		if self.isCumulative:
			dp = self.c_datapoints
		else:
			dp = self.datapoints
		return dp.__str__()

	def __getIndex__(self, xTick, yTick):
		# remember x-axis runs horizontally and so spans across columns
		# of the numpy array, y-axis spans across the rows of the array
		(rowIndex, colIndex) = (None, None)
		try:
			colIndex = self.xTicks[xTick]
		except:
			pass
		try:
			rowIndex = self.yTicks[yTick]
		except:
			pass

		return (rowIndex, colIndex)

	def __extendColumns__(self):
		numRows = self.datapoints.shape[0]
		colsToAdd = self.datapoints.shape[1] # double number of columns
		newColumns = numpy.zeros((numRows, colsToAdd), int)
		self.datapoints = numpy.hstack((self.datapoints, newColumns))

	def __extendRows__(self):
		numColumns = self.datapoints.shape[1]
		rowsToAdd = self.datapoints.shape[0] # double number of rows
		newRows = numpy.zeros((rowsToAdd, numColumns), int)
		self.datapoints = numpy.vstack((self.datapoints, newRows))

	def __addTick__(self, xTick, yTick):
		if xTick != None:
			self.xTicks[xTick] = len(self.xTicks)
			if len(self.xTicks) > self.datapoints.shape[1]:
				self.__extendColumns__()
		if yTick != None:
			self.yTicks[yTick] = len(self.yTicks)
			if len(self.yTicks) > self.datapoints.shape[0]:
				self.__extendRows__()

	def __initialize__(self, xTick, yTick):
		(rowIndex, colIndex) = self.__getIndex__(xTick, yTick)
		if rowIndex == None and colIndex == None:
			self.__addTick__(xTick, yTick)
			# since tick was just appended, index = list.len - 1
			rowIndex = len(self.yTicks) - 1
			colIndex = len(self.xTicks) - 1
		elif rowIndex == None:
			self.__addTick__(None, yTick)
			rowIndex = len(self.yTicks) - 1
		elif colIndex == None:
			self.__addTick__(xTick, None)
			colIndex = len(self.xTicks) - 1
		return (rowIndex, colIndex)

	def setxTickSort(self, callable):
		self.xTickSort = callable # accessed through class name

	def setyTickSort(self, callable):
		self.yTickSort = callable

	def writeToFiles():
		for dir, histos in cviewHisto.groups.items():
			# sync all histos in group and create index list
			indexList = []
			for histo in histos:
				histo.__sync__()
				indexList.append(histo.desc)

			# index and xtick files need written only once per dir of histos
			indexList.sort()
			f = open(dir + '/index', 'w')
			for index in indexList:
				f.write(index + '\n')
			f.close()

			xTicksList = sorted(histos[0].xTicks.keys(), histos[0].xTickSort)
			f = open(dir + '/xtick', 'w')
			for xTick in xTicksList:
				f.write(struct.pack('32s', str(xTick)))
			f.close()

			# must write out all histos for a given directory group
			for histo in histos:
				pathPrefix = dir + '/' + histo.desc
				open(pathPrefix + '.rate', 'w').write(histo.rate)
				open(pathPrefix + '.desc', 'w').write(histo.desc)

				yTickItems = sorted(histo.yTicks.items(), histo.yTickSort)

				f = open(pathPrefix + '.ytick', 'w')
				for (yTick, index) in yTickItems:
					f.write(struct.pack('32s', str(yTick)))
				f.close()

				if histo.isCumulative:
					dp = histo.c_datapoints
				else:
					dp = histo.datapoints

				f = open(pathPrefix + '.data', 'w')
				for (x, col) in sorted(histo.xTicks.items(), histo.xTickSort):
					for (y, row) in yTickItems:
						f.write(struct.pack('f', dp[(row, col)]))
				f.close()

	writeToFiles = staticmethod(writeToFiles) # creates static method

	def getZ(self, xTick, yTick):
		index = self.__getIndex__(xTick, yTick)
		if index[0] == None or index[1] == None:
			return None
		else:
			return self.datapoints[index]

	def merge(self, otherHisto): # will merge another histo object w/ current
		for (x, col) in otherHisto.xTicks.items():
			for (y, row) in otherHisto.yTicks.items():
				(rowIndex, colIndex) = self.__getIndex__(x, y)
				if colIndex == None:
					colIndex = self.xTicks[x] = len(self.xTicks)
					xTicksCount = len(self.xTicks)
					if xTicksCount > self.datapoints.shape[1]:
						self.__extendColumns__()
				if rowIndex == None:
					rowIndex = self.yTicks[y] = len(self.yTicks)
					yTicksCount = len(self.yTicks)
					if yTicksCount > self.datapoints.shape[0]:
						self.__extendRows__()

				index = (rowIndex, colIndex)
				self.datapoints[index] += otherHisto.datapoints[(row, col)]

	def incr(self, xTick, yTick, zValue = 1):
		index = self.__initialize__(xTick, yTick)
		self.datapoints[index] += zValue

	def set(self, xTick, yTick, zValue):
		index = self.__initialize__(xTick, yTick)
		self.datapoints[index] = zValue


if __name__ == '__main__':
	print 'histo module'
	c = cviewHisto('output', 'c', 'f/sec') # directory 'output' must exist
	c.set('x0','y0', 1)
	c.set('x1','y0', 2)
	c.set('x0','y1', 2)
	c.set('x1','y1', 3)
	print c

	# d is a cumulative copy of c
	d = cviewHisto('output', 'd', 'rate', True, False)
	d.merge(c)
	print d

	cviewHisto.writeToFiles()
