#!/bin/bash

##################################
# Generate a genders file from a 
# list of aisle offsets
# 
# this is not very efficient, but oh well!
##################################

# This is a file that has a list of nodes in it
NODELIST="nodelist"

STANDARD_RACK_WIDTH=24
STANDARD_RACK_DEPTH=39.691
STANDARD_RACK_HEIGHT=78.89


#Bottom of rack (start of nodes)
BOTTOM=`echo "$STANDARD_RACK_HEIGHT / -2 + 1.75" | bc`


AISLE_SPACING=10

# Aisle offsets

offsets=(0 2.5 -0.2 1 0 1 3.8 11 11 11 11 11 11 11 10 10 10)

# The isle index is facing direction ${isle[$((index+1))]}

cat floor

#face=(E W E W E W W E W E W E W E W E)
./gen_racks.sh # run the other script to generate rack info

echo "# See genders_HowTo for instructions

#Node definitions

"
while read line; do
    x=0; y=0; z=0
    FIRSTQUOTE=0
    while [ $x -lt ${#line} ]; do # read a line at a time
#        echo -n ${line:${x}:1};
        char=${line:${x}:1}
        if [ "$char" = "\"" ]; then # " ]
            if [ $FIRSTQUOTE -eq "1" ]; then
                # got our second quote
                token=${line:$(( ${y}+1 )):$(( $x - $y - 1 ))} 
                if [ $z -eq "0" ]; then
#                    aisle=`echo $token | sed 's/C.*$//g' | cut -c 2-`
#                    column=`echo $token | sed 's/^.*C//g'`
                    rack=$token
                elif [ $z -eq "1" ]; then
                    node=$token
               #     echo -n "gridy=$(( ${offsets[${aisle}]} )) "
                fi
                y=$x; z=$(( $z + 1 ))
                FIRSTQUOTE=0
            else
                y=$x
                FIRSTQUOTE=1
            fi
        fi
        # print out the results

        x=$(( x + 1 ))     
    done

    node=`echo $node | sed -e 's/ /_/g' -e 's/#//g' -e 's/(/_/g' -e 's/)/_/g' -e 's/-/_/g'`

    if [ "x${!node}" = "x" ]; then
        eval $node=0
    else
        eval $node=$(( ${!node} + 1 ))
        node=${node}${!node}
    fi

    if [ "x$rack" = "x" ]; then
        eval $rack=0    # initialize this variable to zero 
    fi
    eval $rack=$(( ${!rack} + 1 )) #increment the variable that rack points to
    vpos=`echo "$BOTTOM + ${!rack} * 1.75 * 2" | bc`
    echo "$node rack=$rack,nodetype=REG,vposition=${vpos}"

#    echo -n "rack=$rack,aisle=$aisle,column=$column,"
#    echo -n "gridx=$(( ${AISLE_SPACING}*${aisle})),"
#    echo -n "gridz=`echo "${offsets[${aisle}]}+$(( ${column}*${STANDARD_RACK_WIDTH}))" | bc`,"
#    echo face=${face[aisle-1]}

    l=$((l+1)); # move on to the next line

#    echo $l $line;
done < ${NODELIST}

