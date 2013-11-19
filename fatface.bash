#!/bin/bash

# FatFace by Bill Schuller
# Takes photos with mdw-rg Area information and makes a copy cropped photo of each region.
# Really bad bash scripting...embrace constraints!

CF=.fatface.exifcache

#for P in IMG_2972.jpg IMG_2584.jpg IMG_2006.jpg; do
for P in `ls *.jpg`; do
	echo "Processing $P..."
	unset names
	exiftool $P > $CF
	rDH=`grep 'Region Applied To Dimensions H' $CF | cut -d: -f2`
	rDW=`grep 'Region Applied To Dimensions W' $CF | cut -d: -f2`
	rH=`grep 'Region Area H' $CF | cut -d: -f2 | tr -d ' '`
	rW=`grep 'Region Area W' $CF | cut -d: -f2 | tr -d ' '`
	rX=`grep 'Region Area X' $CF | cut -d: -f2 | tr -d ' '`
	rY=`grep 'Region Area Y' $CF | cut -d: -f2 | tr -d ' '`
	rN=`grep 'Region Name' $CF | cut -d: -f2 | tr -d ' '`
	
	# How many regions are we dealing with here?
	set -f
	IFS=,
	idx=0
	for name in $rN; do
		names[idx]=$name
		#echo adding region $name...
		((idx++))
	done
	idx=0
        for size in $rH; do
                rHa[idx]=$size
                ((idx++))
        done
	idx=0
        for size in $rW; do
                rWa[idx]=$size
                ((idx++))
        done
	idx=0
        for size in $rX; do
                rXa[idx]=$size
                ((idx++))
        done
	idx=0
        for size in $rY; do
                rYa[idx]=$size
                ((idx++))
        done
	
	set +f
	unset IFS

	idx=0
	#echo Names Index looks like this \"${!names[@]}\"
	for idx in "${!names[@]}"; do
		echo index is $idx
		echo "   Processing ${names[idx]} Region..."
		fH=$(echo "($rDH*${rHa[$idx]})*2" | bc | cut -d. -f1)
		fW=$(echo "($rDW*${rWa[$idx]})*2" | bc | cut -d. -f1)
		fX=$(echo "($rDW*${rXa[$idx]})-($fW/2)" | bc | cut -d. -f1)
		fY=$(echo "($rDH*${rYa[$idx]})-($fH/2)" | bc | cut -d. -f1)
		m=x
		a=+
		u=_
		c=cropped
		echo "      $fH$m$fW$a$fX$a$fY"
		if [ ${names[idx]}=="BillSchuller" ];then
			convert $P -crop $fH$m$fW$a$fX$a$fY +repage 240x240 -pointsize 16 -fill black -gravity southeast -annotate +10+5 "230"   $P$u${names[idx]}$u$c.jpg
		else
			convert $P -crop $fH$m$fW$a$fX$a$fY +repage 240x240 $P$u${names[idx]}$u$c.jpg
		fi
		((idx++))
	done
done

#rm $CF
