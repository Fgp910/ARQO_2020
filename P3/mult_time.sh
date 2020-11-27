# ARQO 2020-2021. Task 3: exercise 3
# Script for times and plot generation (mult, mult_trans)

#!/bin/bash

# inicializar variables
P=5
Ninicio=$((1000 + 1024 * $P))
Npaso=64
Nfinal=$((1000 + 1024 * ($P + 1)))
Iter=3
fDAT=time_slow_fast.dat
fPNG=time_slow_fast.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);
unset slowTime
unset fastTime
for i in $(seq $Ninicio $Npaso $Nfinal); do slowTime+=(0); done
for i in $(seq $Ninicio $Npaso $Nfinal); do fastTime+=(0); done
for ((i=1; i <= Iter; i++)); do
    echo "I: $i / $Iter..."
    for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
        echo -e "\tslow, N: $N / $Nfinal..."
        aux=$(./slow $N | grep 'time' | awk '{print $3}')
        slowTime[$j]=$(echo "${slowTime[$j]} + $aux" | bc)
    done
    for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
        echo -e "\tfast, N: $N / $Nfinal..."
        aux=$(./fast $N | grep 'time' | awk '{print $3}')
        fastTime[$j]=$(echo "${fastTime[$j]} + $aux" | bc)
    done
done

for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
    slowTimeMean=$(echo "${slowTime[$j]} / $Iter" | bc -l)
    fastTimeMean=$(echo "${fastTime[$j]} / $Iter" | bc -l)
    echo "$N	$slowTimeMean	$fastTimeMean" >> $fDAT
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
