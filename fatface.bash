#!/bin/bash

# FatFace by Bill Schuller
# Takes photos with mdw-rg Area information and makes a copy cropped photo of each region.
# Really bad bash scripting...embrace constraints!

CF=.fatface.exifcache
finalResolution=640x640
fontSize=72
units=standard
#set -x
#for P in IMG_2831.jpg; do
for P in `ls *.jpg`; do
	echo "Processing $P..."
	unset names
	exiftool $P > $CF
	rDH=`grep 'Region Applied To Dimensions H' $CF | cut -d: -f2`
	rDW=`grep 'Region Applied To Dimensions W' $CF | cut -d: -f2`
	rawCreateDate=`grep -m 1 'Create Date' $CF | cut -d: -f2-4 | cut -d' ' -f2 | tr ':' ','`
	#echo "   rawCreateDate is $rawCreateDate"
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
		#echo "    dateComponent is $dateComponent"
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
	#echo "   Create date is ${createDate[0]}-${createDate[1]}-${createDate[2]}"
	createDate[1]=`echo ${createDate[1]} | sed 's/^0*//'`
	createDate[2]=`echo ${createDate[2]} | sed 's/^0*//'`
	# createDate 0=year, 1=month 2=day
	grepDate=${createDate[1]}\/${createDate[2]}\/${createDate[0]}
	egrepDate="$createDate[1]"
	#echo "   grepDate is $grepDate"
	
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
		carrot='^'
		#echo "      $fH$m$fW$a$fX$a$fY"
		if [ -f ${names[idx]}.csv ];then
			#echo `grep -m 1 $grepDate ${names[idx]}.csv`
			currentWeightKG=`grep -m 1 $grepDate ${names[idx]}.csv | cut -d, -f3 | tr -d '"'`
			if [ -z "$currentWeightKG" ]
			then
			  currentWeightKG=0
			fi
			### Need to add a conditional here in case there is no weight for that date.
			if [ "$units" == "standard" ]; then
				currentWeight=$(echo "$currentWeightKG*2.20462" | bc | cut -d. -f1)
			fi
			if [ "$currentWeight" == "0" ]; then
				currentWeight="NULL"
			fi

			# round them corners!
			
			#convert -size 213x160 -stroke none -fill white -draw \"roundRectangle 50,50 167,110 10,10 \" label.png
			convert $P -crop $fH$m$fW$a$fX$a$fY -resize $finalResolution$carrot -extent $finalResolution $P$u${names[idx]}$u$c.jpg
			convert $P$u${names[idx]}$u$c.jpg \
				-pointsize $fontSize \
					-fill white \
					-undercolor '#00000080'  \
				-gravity SouthWest -annotate +0+5 "$currentWeight" \
				-gravity SouthEast -annotate +0+5 "$grepDate"\
				$currentWeight$P$u${names[idx]}$u$c.jpg
			rm $P$u${names[idx]}$u$c.jpg
		else
			convert $P -crop $fH$m$fW$a$fX$a$fY -resize $finalResolution$carrot -extent $finalResolution $P$u${names[idx]}$u$c.jpg
		fi
		unset currentWeight 
		((idx++))
	done
	unset createDate grepDate
done


#rm $CF
