# Script for executions and plot generations in exercise 2.6 in P4

#!/bin/bash

# Variables
C=
NInicio=
NPaso=
NFinal=
Iter=5
fDat=timeSeriePar.dat

# Execution block
unset tSerie
unset tPar
for i in $(seq $Ninicio $Npaso $Nfinal); do tSerie+=(0); done
for i in $(seq $Ninicio $Npaso $Nfinal); do tPar+=(0); done
for ((i=1; i<=$Iter; i++)); do
    echo "I $i/$Iter"
    for ((j=0, N=$NInicio; N<=$NFinal; j+=1, N+=$NPaso)); do
        aux=$(./pescalar_serie $N | grep 'Tiempo:' | awk '{print $2}')
        tSerie[$j]=$(echo "${tSerie[$j]} + $aux" | bc)
        aux=$(./pescalar_par3 $N | grep 'Tiempo:' | awk '{print $2}')
        tPar[$j]=$(echo "${tPar[$j]} + $aux" | bc)
    done
done

for ((j=0, N=$NInicio; N<=$NFinal; j+=1, N+=$NPaso)); do
    serieMean=$(echo "${tSerie[$j]}  / $Iter" | bc -l)
    parMean=$(echo "${tPar[$j]}  / $Iter" | bc -l)
    echo "$N    $serieMean    $parMean" >> $fDat
done

# Plot generation
echo "Generating plots..."
gnuplot << END_GNUPLOT
set title "Scalar product execution time depending on number of threads"
set xlabel "Vector size"
set ylabel "Time (s)"
set grid 
set term PNG
set output "pescalar.png"
plot 
replot
quit
END_GNUPLOT