#!/bin/bash

##################################
# Generate a genders file from a 
# list of aisle offsets
# 
##################################

STANDARD_RACK_WIDTH=24
STANDARD_RACK_DEPTH=39.691
STANDARD_RACK_HEIGHT=78.89

#Bottom of rack (start of nodes)
BOTTOM=`echo "$STANDARD_RACK_HEIGHT / -2 + 1.75 / 2" | bc`

WIDE_RACK_WIDTH=`echo "$STANDARD_RACK_WIDTH * 4 / 3" | bc`

AISLE_SPACING=48

# Aisle offsets
#offsets=(0 2.5 -0.2 1 0 1 3.8 11 11 11 11 11 11 11 10 10 10)
#         1    2   3   4   5   6  7    8   9    10  11  12    13  14  15  16
offsets=(-21 -21 -21 -21 -21 -21  0  -15 -14.2 -15 -19 -17.7 -19 -22 -20 -22)

# The isle index is facing direction ${aisle[$((index+1))]}
#     1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6
face=(E W E W E W E W E W E W E W E W)

#   1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
R1=(0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0)
R2=(0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0)
R3=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
R4=(0 0 0 0 0 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0)
R5=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
R6=(0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0)
# what happened to R7 ????????
R8=(0 0 0 0)
R9=(0 1 0)
R10=(0 0 0 0)
R11=(0 0 0 0 0 0 0 0)
R12=(0 1 0 0 1 0)
R13=(0 0 0 0 0 0 0 0)
R14=(0 0 0 0 0 0 0 0 0 0 0 0)
R15=(0 1 0 0 1 0 0 1 0)
R16=(0 0 0 0 0 0 0 0 0 0 0 0)

S=$AISLE_SPACING


echo "# racktype definitions

# HP 10642 G2 Rack (42U) http://h18000.www1.hp.com/products/quickspecs/12402_div/12402_div.html#Technical%20Specifications
rack-HP width=24,depth=39.691,height=78.89

# nodetype definitions
node-REG width=23,depth=35,height=1.75

# rack definitions
R1C[1-18]   racktype=HP,face=E
R2C[1-21]   racktype=HP,face=W
R3C[1-21]   racktype=HP,face=E
R4C[1-20]   racktype=HP,face=W
R5C[1-20]   racktype=HP,face=E
R6C[1-8,10-16]   racktype=HP,face=W
# there is no R7
R8C[1-4]   racktype=HP,face=W
R9C[1-3]   racktype=HP,face=E
R10C[1-4]  racktype=HP,face=W
R11C[1-8]  racktype=HP,face=E
R12C[1-6]  racktype=HP,face=W
R13C[1-8]  racktype=HP,face=E
R14C[1-12]  racktype=HP,face=W
R15C[1-9]  racktype=HP,face=E
R16C[1-12]  racktype=HP,face=W

"



z=0;
for R in `seq 1 16`; do 
    x=`eval "echo \${offsets[$(($R-1))]}"`
    x=`echo "$x * 24" | bc`
    eval last=\${#R${R}[*]}
    for C in `seq 1 $last`; do
        echo "R${R}C${C} gridx=$x,gridy=0,gridz=$z" #,face=`eval "echo \${face[$(($R - 1))]}"`"
        eval wide=\${R$R[$C]}
        if [ "$wide" = "1" ]; then
            x=`echo "$x + $WIDE_RACK_WIDTH" | bc`
        else
            x=`echo "$x + $STANDARD_RACK_WIDTH" | bc`
        fi
    done
    if [ "$R" = "6" ]; then
        z=`echo "$z + 25.2 * 24 + $STANDARD_RACK_DEPTH" | bc` # big gap here
    else
        z=`echo "$z + $AISLE_SPACING + $STANDARD_RACK_DEPTH" | bc`
    fi
done
