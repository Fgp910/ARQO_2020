# Script for executions and plot generations in exercise 2.6 in P4

#!/bin/bash

# Variables
M=9
NInicio=1000000
NPaso=1500000
NFinal=10000000
Iter=1
fDat=timeSeriePar.dat
fDat2=speedupSeriePar.dat

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

rm -rf $fDat $fDat2
for ((j=0, N=$NInicio; N<=$NFinal; j+=1, N+=$NPaso)); do
    serieMean=$(echo "${tSerie[$j]}  / $Iter" | bc -l)
    str="$N    $serieMean"
    str2="$N    "
    for k in $(seq 1 1 $M); do
        parMean=$(echo "${tPar[$(($j*$M + ($k-1)))]}  / $Iter" | bc -l)
        str="$str   $parMean"
        speedup=$(echo "$serieMean / $parMean" | bc -l)
        str2="$str2    $speedup"
    done
    echo $str >> $fDat
    echo $str2 >> $fDat2
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
plot "$fDat" u 1:2  w l lw 2 lt rgb "#000000" title "Serial",     \
     "$fDat" u 1:3  w l lw 2 lt rgb "#003F5C" title "2 threads",  \
     "$fDat" u 1:4  w l lw 2 lt rgb "#58508D" title "4 threads",  \
     "$fDat" u 1:5  w l lw 2 lt rgb "#BC5090" title "6 threads",  \
     "$fDat" u 1:6  w l lw 2 lt rgb "#FF6361" title "8 threads",  \
     "$fDat" u 1:7  w l lw 2 lt rgb "#FFA600" title "10 threads", \
     "$fDat" u 1:8  w l lw 2 lt rgb "#FF582E" title "12 threads", \
     "$fDat" u 1:9  w l lw 2 lt rgb "#FF0067" title "14 threads", \
     "$fDat" u 1:10 w l lw 2 lt rgb "#DC00AB" title "16 threads", \
     "$fDat" u 1:11 w l lw 2 lt rgb "#280EEB" title "18 threads"
replot
quit
END_GNUPLOT
gnuplot << END_GNUPLOT
set title "Scalar Product Speedup Depending on Number of Threads"
set xlabel "Vector size"
set ylabel "Speedup"
set grid
set term png
set key outside right center
set output "pescalar_speed.png"
plot "$fDat2" u 1:2  w l lw 2 lt rgb "#003F5C" title "2 threads",  \
     "$fDat2" u 1:3  w l lw 2 lt rgb "#58508D" title "4 threads",  \
     "$fDat2" u 1:4  w l lw 2 lt rgb "#BC5090" title "6 threads",  \
     "$fDat2" u 1:5  w l lw 2 lt rgb "#FF6361" title "8 threads",  \
     "$fDat2" u 1:6  w l lw 2 lt rgb "#FFA600" title "10 threads", \
     "$fDat2" u 1:7  w l lw 2 lt rgb "#FF582E" title "12 threads", \
     "$fDat2" u 1:8  w l lw 2 lt rgb "#FF0067" title "14 threads", \
     "$fDat2" u 1:9  w l lw 2 lt rgb "#DC00AB" title "16 threads", \
     "$fDat2" u 1:10 w l lw 2 lt rgb "#280EEB" title "18 threads"
replot
quit
END_GNUPLOT
