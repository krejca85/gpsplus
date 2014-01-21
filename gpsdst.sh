#!/bin/bash
LatA=$1
LonA=$2
LatB=$3
LonB=$4

function distance() { #parameters LatA LonA LatB LonB
  local RAD=6378137 #Earth radii in meters
  local LatA=$1
  local LonA=$2
  local LatB=$3
  local LonB=$4
  local dst=0
  local pi=$(echo "22 / 7" |bc -l)

  local dLat=$(echo "$pi * ($LatB - $LatA) / 180" |bc -l)
  local dLon=$(echo "$pi * ($LonB - $LonA) / 180" |bc -l)

  LatA=$(echo "$pi * $LatA / 180" |bc -l)
  LatB=$(echo "$pi * $LatB / 180" |bc -l)

  local a=$(echo "(s($dLat/2))^2 + (s($dLon/2))^2 * c($LatA) * c($LatB)" |bc -l)

  local c=$(echo $a | awk '{ print "%.20f" 2*atan2(sqrt($1),sqrt(1-$1)) }')
  local dst=$(echo "$RAD * $c" |bc -l)
  echo $dst
}

distance $LatA $LonA $LatB $LonB


