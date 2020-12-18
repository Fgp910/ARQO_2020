#!/bin/bash

#Variables
Iter=1
fDat="speedup_edge_detector.dat"
num=5

list=(SD.jpg HD.jpg FHD.jpg 4k.jpg 8k.jpg)

#--------------Computation block-----------------
rm -rf $fDat

unset meanS
unset meanP
for j in $(seq 1 1 $num); do 
    meanS+=(0)
    meanP+=(0)
done
for ((i=1; i<=$Iter; i++)); do
    echo "I $i / $Iter"
    for ((j=0; j<$num; j++)); do
        aux=$(./../edgeDetector ${list[$j]} | grep "Tiempo:" | awk '{print $2}')
        meanS[$j]=$(echo "${meanS[$j]} + $aux" | bc)
        aux=$(./../edgeDetectorPar ${list[$j]} | grep "Tiempo:" | awk '{print $2}')
        meanP[$j]=$(echo "${meanP[$j]} + $aux" | bc)
    done
done
for ((j=0; j<$num; j++)); do
    meanS[$j]=$(echo "${meanS[$j]} / $Iter" | bc -l)
    meanP[$j]=$(echo "${meanP[$j]} / $Iter" | bc -l)
    speedup=$(echo "${meanS[$j]} / ${meanP[$j]}" | bc -l)
    fps1=$(echo "1 / ${meanS[$j]}" | bc -l)
    fps2=$(echo "1 / ${meanP[$j]}" | bc -l)
    echo "${meanS[$j]}    ${meanP[$j]}    $speedup    $fps1    $fps2" >> $fDat
done