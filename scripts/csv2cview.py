#!/usr/bin/env python



# This file is port of the CVIEW graphics system, which is goverened by the following License
#
# Copyright 2008,2009, Battelle Memorial Institute
# All rights reserved.
#
# 1.    Battelle Memorial Institute (hereinafter Battelle) hereby grants permission
#       to any person or entity lawfully obtaining a copy of this software and
#       associated documentation files (hereinafter "the Software") to redistribute
#       and use the Software in source and binary forms, with or without
#       modification.  Such person or entity may use, copy, modify, merge, publish,
#       distribute, sublicense, and/or sell copies of the Software, and may permit
#       others to do so, subject to the following conditions:
#
#       *       Redistributions of source code must retain the above copyright
#               notice, this list of conditions and the following disclaimers.
#       *       Redistributions in binary form must reproduce the above copyright
#               notice, this list of conditions and the following disclaimer in the
#               documentation and/or other materials provided with the distribution.
#       *       Other than as used herein, neither the name Battelle Memorial
#               Institute or Battelle may be used in any form whatsoever without the
#               express written consent of Battelle.
#       *       Redistributions of the software in any form, and publications based
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

import sys
import os
import os.path
import errno
import csv

from histo import cviewHisto
from optparse import OptionParser

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

parser = OptionParser()
parser.add_option("-i", "--input", dest="input_csv",
                  help="read csv from file", metavar="FILE")
parser.add_option("-o", "--output", dest="output_dir",
                  help="write cview data to dir", metavar="DIRECTORY")
parser.add_option("-q", "--quiet",
                  action="store_false", dest="verbose", default=True,
                  help="don't print status messages to stdout")

(options, args) = parser.parse_args()

######
#
# Create output directory
#
######
mkdir_p(options.output_dir)

######
#
# Create histo object
#
# The format of the csv is the following:
#
# Time,n0,n1,n2,n3
# 00:00,1,2,3,4
# 00:01,2,3,4,5
# 00:02,3,4,5,6
#
######
histo_desc = os.path.splitext(os.path.basename(options.input_csv))[0]
histo = cviewHisto(options.output_dir, histo_desc, 'CSV', False, True)
histodata = []
with open(options.input_csv, 'rb') as csvfile:
    for row in csv.reader(csvfile):
        histodata.append(row)
headers = histodata[0]
if options.verbose:
    print headers
for row in histodata[1:]:
    for xtick_offset in range(0, len(headers[1:])):
        if not row[xtick_offset+1]:
            row[xtick_offset+1] = "0.0"
        histo.set(headers[xtick_offset+1], row[0], float(row[xtick_offset+1]))
histo.writeToFiles()
