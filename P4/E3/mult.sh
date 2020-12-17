# ARQO 2020-2021. Task 4: exercise 3
# Script for times, speedup and plot generation (mult_serie, mult_par3)

#!/bin/bash

# inicializar variables
P=1
Ninicio=$((512 * $P))
Npaso=64
Nfinal=$((1024 + 512 * $P))
Iter=2
fDAT=mult.dat
fTimePNG=mult_time.png
fSpeedupPNG=mult_speedup.png

# borrar el fichero DAT y los ficheros PNG
rm -f $fDAT $fTimePNG $fSpeedupPNG

# generar el fichero DAT vacío
touch $fDAT

echo "Running mult_serie and mult_par3..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);
unset serieTime
unset parTime
unset speedupAcum
unset auxSerie
for i in $(seq $Ninicio $Npaso $Nfinal); do serieTime+=(0); done
for i in $(seq $Ninicio $Npaso $Nfinal); do parTime+=(0); done
for i in $(seq $Ninicio $Npaso $Nfinal); do speedupAcum+=(1); done
for i in $(seq $Ninicio $Npaso $Nfinal); do auxSerie+=(1); done
export OMP_NUM_THREADS=4
for ((i=1; i <= Iter; i++)); do
    echo "I: $i / $Iter..."
    for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
        echo -e "\tserie, N: $N / $Nfinal..."
        auxSerie[$j]=$(./../mult_serie $N | grep 'time' | awk '{print $3}')
        serieTime[$j]=$(echo "${serieTime[$j]} + ${auxSerie[$j]}" | bc)
    done
    for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
        echo -e "\tpar, N: $N / $Nfinal..."
        aux=$(./../mult_par3 $N | grep 'time' | awk '{print $3}')
        parTime[$j]=$(echo "${parTime[$j]} + $aux" | bc)
        speedupAcum[$j]=$(echo "${speedupAcum[$j]} * ${auxSerie[$j]} / $aux" | bc -l)
    done
done

for ((N=Ninicio, j=0; N <= Nfinal ; N+=Npaso, j++)); do
    serieTimeMean=$(echo "${serieTime[$j]} / $Iter" | bc -l)
    parTimeMean=$(echo "${parTime[$j]} / $Iter" | bc -l)
    speedup=$(echo "e( l(${speedupAcum[$j]}) / $Iter )" | bc -l) #Media geom�trica
    echo -e "$N\t $serieTimeMean\t $parTimeMean\t $speedup" >> $fDAT
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Matrix Multiplication Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set grid
set term png size 960, 480
set key outside right center
set output "$fTimePNG"
plot "$fDAT" using 1:2 with lines lw 2 title "Series", \
     "$fDAT" using 1:3 with lines lw 2 title "Parallel"
replot
quit
END_GNUPLOT
gnuplot << END_GNUPLOT
set title "Matrix Multiplication Speedup"
set ylabel "Speedup"
set xlabel "Matrix Size"
set grid
set term png size 960, 480
set key outside right center
set output "$fSpeedupPNG"
plot "$fDAT" using 1:4 with lines lw 2 title "Parallel (vs series)"
replot
quit
END_GNUPLOT
