# Script for executions and plot generations in exercise 2.6 in P4

#!/bin/bash

# Variables
M=9
NInicio=1000000
NPaso=1500000
NFinal=10000000
Iter=1
fDat=timeSeriePar.dat

# Execution block
unset tSerie
unset tPar
for i in $(seq $NInicio $NPaso $NFinal); do tSerie+=(0); done
for k in $(seq 1 1 $M); do
    for i in $(seq $NInicio $NPaso $NFinal); do tPar+=(0); done
done
for ((i=1; i<=$Iter; i++)); do
    echo "I $i / $Iter"
    for ((N=$NInicio, j=0; N<=NFinal; N+=NPaso, j++)); do
        aux=$(./pescalar_serie $N | grep 'Tiempo:' | awk '{print $2}')
        tSerie[$j]=$(echo "${tSerie[$j]} + $aux" | bc)
        for k in $(seq 1 1 $M); do
            export OMP_NUM_THREADS=$(($k*2))
            aux=$(./pescalar_par3 $N | grep 'Tiempo:' | awk '{print $2}')
            tPar[$(($j*$M + ($k-1)))]=$(echo "${tPar[$(($j*$M + ($k-1)))]} + $aux" | bc)
        done
    done
done

rm -rf $fDat
for ((j=0, N=$NInicio; N<=$NFinal; j+=1, N+=$NPaso)); do
    serieMean=$(echo "${tSerie[$j]}  / $Iter" | bc -l)
    str="$N    $serieMean"
    for k in $(seq 1 1 $M); do
        parMean=$(echo "${tPar[$(($j*$M + ($k-1)))]}  / $Iter" | bc -l)
        str="$str   $parMean"
    done
    echo $str >> $fDat
done

# Plot generation
echo "Generating plots..."
gnuplot << END_GNUPLOT
set title "Scalar Product Execution Time Depending on Number of Threads"
set xlabel "Vector size"
set ylabel "Time (s)"
set grid 
set term png
set key outside right center
set output "pescalar.png"
plot "$fDat" u 1:2 w l title "Serial", \
     "$fDat" u 1:3 w l title "2 threads", \
     "$fDat" u 1:4 w l title "4 threads", \
     "$fDat" u 1:5 w l title "6 threads", \
     "$fDat" u 1:6 w l title "8 threads", \
     "$fDat" u 1:7 w l title "10 threads", \
     "$fDat" u 1:8 w l title "12 threads", \
     "$fDat" u 1:9 w l title "14 threads", \
     "$fDat" u 1:10 w l title "16 threads", \
     "$fDat" u 1:11 w l title "18 threads"
replot
quit
END_GNUPLOT