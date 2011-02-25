#!/usr/bin/env python
from math import *

rad=200
num=4
circle=[ (sin((2*i+1)*pi/num)*rad,cos((2*i+1)*pi/num)*rad,i*pi/6+pi/2+pi/num-pi/2) for i in range(num)]
rad=100
num=2
circle2=[ (sin((2*i+1)*pi/num)*rad,cos((2*i+1)*pi/num)*rad,i*pi/6+pi/2+pi/num-pi/2) for i in range(num)]

print """{
	nodemapfile="ib-node-names.map";
	nodelinksfile="ib_med.ibnetdiscover";
	nodecountfile="ib_med.linkcounts";
	portspeed="SDR";
	chassis=(
"""

for i in range(2):
	print """		{
			name = "S%d";
			type = "TEST040208";
			locx = %f;
			locy = %f;
			locz = %f;
			rotx = -90;
			rotz = %f;
		},
"""%(i+1,circle2[i][0],200,circle2[i][1],circle2[i][2]*180/pi);


for i in range(4):
	print """		{
			name = "C%d";
			type = "TEST040208";
			locx = %f;
			locy = %f;
			locz = %f;
			roty = %f;
		},
"""%(i+1,circle[i][0],0,circle[i][1],circle[i][2]*180/pi);


print """		);
}
"""

