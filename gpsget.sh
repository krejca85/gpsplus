#!/bin/bash
#read input from gpsd through gpspipe (client) and write selected values on stdout

count=$1
gpspipe -w -n 5 >> /dev/null

for i in $(seq 1 $count)
do
  tpv=$(gpspipe -w -n 5 | grep -m 1 TPV | cut -d, -f4,6-10,13)

  Lat=$(echo $tpv | cut -d, -f3 | cut -d: -f2)
  Lon=$(echo $tpv | cut -d, -f4 | cut -d: -f2)
  Alt=$(echo $tpv | cut -d, -f5 | cut -d: -f2)
  EPX=$(echo $tpv | cut -d, -f6 | cut -d: -f2)
  EPY=$(echo $tpv | cut -d, -f7 | cut -d: -f2)

  echo "$Lat $Lon"
done

