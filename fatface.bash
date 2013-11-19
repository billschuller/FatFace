#!/bin/bash

# FatFace by Bill Schuller
# Takes photos with mdw-rg Area information and makes a copy cropped photo of each region.
# Really bad bash scripting...embrace constraints!

CF=.fatface.exifcache
finalResolution=640x640
fontSize=72

#for P in IMG_2972.jpg IMG_2584.jpg IMG_2006.jpg; do
for P in `ls *.jpg`; do
	echo "Processing $P..."
	unset names
	exiftool $P > $CF
	rDH=`grep 'Region Applied To Dimensions H' $CF | cut -d: -f2`
	rDW=`grep 'Region Applied To Dimensions W' $CF | cut -d: -f2`
	rawCreateDate=`grep 'Create Date' $CF | cut -d: -f2-4 | cut -d' ' -f2 | tr ':' ','`
	rH=`grep 'Region Area H' $CF | cut -d: -f2 | tr -d ' '`
	rW=`grep 'Region Area W' $CF | cut -d: -f2 | tr -d ' '`
	rX=`grep 'Region Area X' $CF | cut -d: -f2 | tr -d ' '`
	rY=`grep 'Region Area Y' $CF | cut -d: -f2 | tr -d ' '`
	rN=`grep 'Region Name' $CF | cut -d: -f2 | tr -d ' '`
	
	# How many regions are we dealing with here?
	set -f
	IFS=,
	idx=0
	for dateComponent in $rawCreateDate; do
		createDate[idx]=$dateComponent
		((idx++))
	done
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
	#echo "Create date is ${createDate[0]}-${createDate[1]}-${createDate[2]}"
	createDate[1]=`echo ${createDate[1]} | sed 's/^0*//'`
	createDate[2]=`echo ${createDate[2]} | sed 's/^0*//'`
	grepDate=${createDate[1]}\/${createDate[2]}\/${createDate[0]}
	
	#echo "grepDate is $grepDate"
	#echo Names Index looks like this \"${!names[@]}\"
	for idx in "${!names[@]}"; do
		#echo index is $idx
		#echo "   Processing ${names[idx]} Region..."
		fH=$(echo "($rDH*${rHa[$idx]})*2" | bc | cut -d. -f1)
		fW=$(echo "($rDW*${rWa[$idx]})*2" | bc | cut -d. -f1)
		fX=$(echo "($rDW*${rXa[$idx]})-($fW/2)" | bc | cut -d. -f1)
		fY=$(echo "($rDH*${rYa[$idx]})-($fH/2)" | bc | cut -d. -f1)
		# Make concatinated strings with variable construction easier...
		# hackish, hard to read and not the right way
		m=x
		a=+
		u=_
		c=cropped
		#echo "      $fH$m$fW$a$fX$a$fY"
		if [ ${names[idx]}=="BillSchuller" ];then
			echo `grep $grepDate ${names[idx]}.csv`
			currentWeightKG=`grep $grepDate ${names[idx]}.csv | cut -d, -f3 | tr -d '"'`
			### Need to add a conditional here in case there is no weight for that date.
			curretnWeightLBS=$(echo "$currentWeightKG*2.20462" | bc | cut -d. -f1)
			convert $P -crop $fH$m$fW$a$fX$a$fY -resize $finalResolution $P$u${names[idx]}$u$c.jpg
			convert $P$u${names[idx]}$u$c.jpg -pointsize $fontSize -fill white  -undercolor '#00000080'  -gravity South -annotate +0+5 "$curretnWeightLBS" $curretnWeightLBS$P$u${names[idx]}$u$c.jpg
			rm $P$u${names[idx]}$u$c.jpg
		else
			convert $P -crop $fH$m$fW$a$fX$a$fY -resize $finalResolution $P$u${names[idx]}$u$c.jpg
		fi
		((idx++))
	done
done


#rm $CF
