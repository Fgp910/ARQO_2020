# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=5
Ninicio=100
Npaso=16
Nfinal=$((Ninicio + 100))
Nsizes=$(((Nfinal - Ninicio + Npaso)/Npaso))
Iter=2
fDAT=time_slow_fast.dat
fPNG=time_slow_fast.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);
declare -a slowTime=( $(for i in {1..Nsizes}; do echo 0; done) )
declare -a fastTime=( $(for i in {1..Nsizes}; do echo 0; done) )
for ((i=0; i < Iter; i++)); do
    echo "I: $i / $Iter..."
    for ((N=Ninicio ; N <= Nfinal ; N+=Npaso)); do
        echo "\tslow, N: $N / $Nfinal..."
        j=$(((N - Ninicio + Npaso)/Npaso))
        aux=$(./slow $N | grep 'time' | awk '{print $3}')
        slowTime[$j]=$(echo "$slowTime[$j] + $aux" | bc)
    done
    for ((N=Ninicio ; N <= Nfinal ; N+=Npaso)); do
        echo "\tfast, N: $N / $Nfinal..."
        j=$(((N - Ninicio + Npaso)/Npaso))
        aux=$(./fast $N | grep 'time' | awk '{print $3}')
        fastTime[$j]=$(echo "$fastTime[%j] + $aux" | bc)
    done
done

for ((N=Ninicio ; N <= Nfinal ; N+=Npaso)); do
    j=$(((N - Ninicio + Npaso)/Npaso))
    slowTimeMean=$(echo "$slowTime[j]/$Iter" | bc)
    fastTimeMean=$(echo "$fastTime[j]/$Iter" | bc)
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
