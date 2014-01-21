#!/bin/bash

count=$1

declare -a avgLat
declare -a avgLon
declare -a avgAlt
declare -a avgEPX
declare -a avgEPY

#function to calculate distance in meters between two poins
function distance() { #parameters LatA LonA LatB LonB
  local RAD=6378137 #Earth radii in meters
  local LatA=$1
  local LonA=$2
  local LatB=$3
  local LonB=$4
  local dst=0
  local pi=$(echo "22 / 7" |bc -l)

  #using haversine formula
  local dLat=$(echo "$pi * ($LatB - $LatA) / 180" |bc -l)
  local dLon=$(echo "$pi * ($LonB - $LonA) / 180" |bc -l)

  LatA=$(echo "$pi * $LatA / 180" |bc -l)
  LatB=$(echo "$pi * $LatB / 180" |bc -l)

  local a=$(echo "(s($dLat/2))^2 + (s($dLon/2))^2 * c($LatA) * c($LatB)" |bc -l)

  local c=$(echo $a | awk '{ printf "%.20f", 2*atan2(sqrt($1),sqrt(1-$1)) }')
  local dst=$(echo "$RAD * $c" |bc -l)
  echo $dst
}

#to avoid first missread
gpspipe -w -n 5 >> /dev/null

for i in $(seq 1 $count)
do
  tpv=$(gpspipe -w -n 5 | grep -m 1 TPV | cut -d, -f4,6-10,13)

  avgLat[$i]=$(echo $tpv | cut -d, -f3 | cut -d: -f2)
  avgLon[$i]=$(echo $tpv | cut -d, -f4 | cut -d: -f2)
  avgAlt[$i]=$(echo $tpv | cut -d, -f5 | cut -d: -f2)
  avgEPX[$i]=$(echo $tpv | cut -d, -f6 | cut -d: -f2)
  avgEPY[$i]=$(echo $tpv | cut -d, -f7 | cut -d: -f2)

  echo "Measuring no.$i"
  echo "LAT: ${avgLat[$i]}"
  echo "LON: ${avgLon[$i]}"
  echo "ALT: ${avgAlt[$i]}"
  echo "EPX: ${avgEPX[$i]}"
  echo "EPY: ${avgEPY[$i]}"
done


echo ""
echo "Averaged position"

#averaging of each parameter
for name in "Lat" "Lon" "Alt" "EPX" "EPY"
do
  avg=0
  for i in $(seq 1 $count)
  do
    dsc=$(echo "avg${name}[$i]")
    avg=$(echo "$avg + ${!dsc}" |bc -l)
  done
  avg=$(echo "scale=9; $avg / $count" |bc -l)
  #values stored in variables Latavg, Lonavg, Altavg ...
  dsc=$(echo "${name}avg")
  declare $dsc=$avg
  echo "$(echo $name |tr [:lower:] [:upper:]): $avg"

  #standart deviation for each parameter
  for i in $(seq 1 $count)
  do
    dsc=$(echo "avg${name}[$i]")
    declare $dsc=$(echo "(${!dsc} - $avg)^2" |bc -l)

  done

  stddev=0

  for i in $(seq 1 $count)
  do
    dsc=$(echo "avg${name}[$i]")
    stddev=$(echo "$stddev + ${!dsc}" |bc -l)
  done
  #values stored in variables Latstd, Lonstd, Altstd ...
  eval dsc=$(echo "${name}std")
  declare $dsc=$(echo "sqrt((1/($count-1))*$stddev)" |bc -l)
done

LatA=$Latavg
LonA=$Lonavg
LatB=$(echo "$Latavg+$Latstd" |bc -l)
LonB=$(echo "$Lonavg+$Lonstd" |bc -l)
echo "IMPROVED: +/- $(distance $LatA $LonA $LatB $LonB) m"

