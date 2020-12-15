# Script for executions and plot generations in exercise 2.6 in P4

#!/bin/bash

# Variables
C=
M=$(2*$C)
NInicio=
NPaso=
NFinal=
Iter=5
fDat=timeSeriePar.dat

# Execution block
unset tSerie
for k in $(seq 2 1 $M); do
    unset tPar$k
done
for i in $(seq $Ninicio $Npaso $Nfinal); do tSerie+=(0); done
for i in $(seq $Ninicio $Npaso $Nfinal); do tPar+=(0); done
for ((i=1; i<=$Iter; i++)); do
    echo "I $i/$Iter"
    for ((j=0, N=$NInicio; N<=$NFinal; j+=1, N+=$NPaso)); do
        aux=$(./pescalar_serie $N | grep 'Tiempo:' | awk '{print $2}')
        tSerie[$j]=$(echo "${tSerie[$j]} + $aux" | bc)
        for k in $(seq 2 1 $M); do
            export OMP_NUM_THREADS=$k
            aux=$(./pescalar_par3 $N | grep 'Tiempo:' | awk '{print $2}')
            tPar$k[$j]=$(echo "${tPar$k[$j]} + $aux" | bc)
        done
    done
done

for ((j=0, N=$NInicio; N<=$NFinal; j+=1, N+=$NPaso)); do
    serieMean=$(echo "${tSerie[$j]}  / $Iter" | bc -l)
    str="$N    $serieMean"
    for k in $(seq 2 1 $M); do
        parMean=$(echo "${tPar$k[$j]}  / $Iter" | bc -l)
        str=$str+"   $parMean"
    done
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
plot "$fDat" u 1:2 w l title "Serial", \
     for [i=2:$M] "$fDat" u 1:($1+i) w l title i." threads"
replot
quit
END_GNUPLOT