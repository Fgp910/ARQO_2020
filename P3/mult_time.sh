# ARQO 2020-2021. Task 3: exercise 3
# Script for times generation, cachegrind simulation and the corresponding plots

#!/bin/bash

# inicializar variables
P=5
Ninicio=$((256 + 256 * $P))
Npaso=32
Nfinal=$((256 + 256 * ($P + 1)))
Iter=3
fDAT=mult.dat
fPNG_cache=mult_cache.png
fPNG_time=mult_time.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG_cache $fPNG_time

# generar el fichero DAT vacío
touch $fDAT

echo "Running mult and mult_trans..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);
unset slowTime
unset fastTime
for i in $(seq $Ninicio $Npaso $Nfinal); do slowTime+=(0); done
for i in $(seq $Ninicio $Npaso $Nfinal); do fastTime+=(0); done
for ((i=1; i <= Iter; i++)); do
    echo "I: $i / $Iter..."
    for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
        echo -e "\tmult, N: $N / $Nfinal..."
        aux=$(./mult $N | grep 'time' | awk '{print $3}')
        slowTime[$j]=$(echo "${slowTime[$j]} + $aux" | bc)
    done
    for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
        echo -e "\tmult_trans, N: $N / $Nfinal..."
        aux=$(./mult_trans $N | grep 'time' | awk '{print $3}')
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
plot "$fDAT" using 1:2 with lines lw 2 title "mult", \
     "$fDAT" using 1:3 with lines lw 2 title "mult_trans"
replot
quit
END_GNUPLOT
