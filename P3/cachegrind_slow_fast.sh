# Script for cachegrind simulation and plot generation

#!/bin/bash

P=5
Ninicio=$((2000 + $P * 512))
Nfinal=$((2000 + ($P + 1) * 512))
Npaso=64
fDAT="Cachegrind/cache_"
L1size=1024
NL1=8
MaxLsize=$((8*1024*1024))
Nways=1
LineSize=64
TempFile=temporary_file.dat
f1PNG=cache_lectura.png
f2PNG=cache_escritura.png

# Removing previous files
rm -rf Cachegrind/*

#Simulation
echo "Simulating..."
mkdir Cachegrind -p

for i in $(seq $Ninicio $Npaso $Nfinal); do
	echo "Beginning simulation for size $i matrix with slow algorithm..."
	for ((j=1; j<=$NL1; j*=2)); do
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$(($L1size*$j)),$Nways,$LineSize --D1=$(($L1size*$j)),$Nways,$LineSize \
		--LL=$MaxLsize,$Nways,$LineSize ./slow $i
		D1mrs=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}')
		D1mws=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}')
		rm -rf $TempFile
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$(($L1size*$j)),$Nways,$LineSize --D1=$(($L1size*$j)),$Nways,$LineSize \
		--LL=$MaxLsize,$Nways,$LineSize ./fast $i
		D1mrf=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}')
		D1mwf=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}')
		rm -rf $TempFile
		echo "$i	$D1mrs	$D1mws	$D1mrf	$D1mwf" >> $fDAT$(($L1size*$j))".dat"
	done
done

#Plot generation
echo "Generating plots..."
gnuplot << END_GNUPLOT
set title "Fallos de memoria en lectura"
set xlabel "Tamaño de la matriz"
set ylabel "Número de fallos"
set key right bottom
set grid
set term png
set output "$f1PNG"
plot for [tam in "1024 2048 4096 8192"] "$fDAT".tam.".dat" using 1:2 with lines lc "red" title "Cache ".tam."B slow", \
	 for [tam in "1024 2048 4096 8192"] "$fDAT".tam.".dat" using 1:4 with lines lc "blue" title "Cache ".tam."B fast"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Fallos de memoria en escritura"
set xlabel "Tamaño de la matriz"
set ylabel "Número de fallos"
set key right bottom
set grid
set term png
set output "$f2PNG"
plot for [tam in "1024 2048 4096 8192"] "$fDAT".tam.".dat" using 1:3 with lines lc "red" title "Cache ".tam."B slow", \
	 for [tam in "1024 2048 4096 8192"] "$fDAT".tam.".dat" using 1:5 with lines lc "blue" title "Cache ".tam."B fast"
replot
quit
END_GNUPLOT