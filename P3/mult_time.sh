# ARQO 2020-2021. Task 3: exercise 3
# Script for times generation, cachegrind simulation and the corresponding plots

#!/bin/bash

# inicializar variables
P=5
Ninicio=$((256 + 256 * $P))
Npaso=32
Nfinal=$((256 + 256 * ($P + 1)))
Iter=15
TempFile=temporary_file.dat
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

echo "Running mult and mult_trans with cachegrind..."
for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
    slowTimeMean=$(echo "${slowTime[$j]} / $Iter" | bc -l)
    fastTimeMean=$(echo "${fastTime[$j]} / $Iter" | bc -l)

    echo "Beginning simulation for size $N matrix with regular algorithm..."
    valgrind --tool=cachegrind --cachegrind-out-file=$TempFile ./mult $N
    D1mrs=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}' | sed 's/,//g'))
    D1mws=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}' | sed 's/,//g'))
    rm -f $TempFile

    echo "Beginning simulation for size $N matrix with transposed algorithm..."
    valgrind --tool=cachegrind --cachegrind-out-file=$TempFile ./mult_trans $N
    D1mrf=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}' | sed 's/,//g'))
    D1mwf=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}' | sed 's/,//g'))
    rm -f $TempFile

    echo "$N	$slowTimeMean	$D1mrs	$D1mws	$fastTimeMean	$D1mrf	$D1mwf" >> $fDAT
done

echo "Generating plots..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Cache Misses"
set xlabel "Matrix Size"
set ylabel "Number of Misses"
set grid
set logscale y
set term png size 960, 480
set key outside right center
set output "$fPNG_cache"
plot "$fDAT" using 1:3 w l lw 2 lt rgb "#FAAB00" title "Regular (read)", \
     "$fDAT" using 1:4 w l lw 2 lt rgb "#FF2B0F" title "Regular (write)", \
     "$fDAT" using 1:6 w l lw 2 lt rgb "#6C72D6" title "Transposed (read)", \
     "$fDAT" using 1:7 w l lw 2 lt rgb "#003F5C" title "Transposed (write)"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Matrix Multiplication Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set grid
set term png size 960, 480
set key outside right center
set output "$fPNG_time"
plot "$fDAT" using 1:2 with lines lw 2 title "Regular", \
     "$fDAT" using 1:5 with lines lw 2 title "Transposed"
replot
quit
END_GNUPLOT
