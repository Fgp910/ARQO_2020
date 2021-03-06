# ARQO 2020-2021. Task 3: exercise 2
# Script for cachegrind simulation and plot generation

#!/bin/bash

P=5
Ninicio=$((2000 + $P * 512))
Nfinal=$((2000 + ($P + 1) * 512))
Npaso=64
fDAT="cache_"
L1size=1024
NL1=8
MaxLsize=$((8*1024*1024))
Nways=1
LineSize=64
TempFile=temporary_file.dat
f1PNG=cache_lectura.png
f2PNG=cache_escritura.png

# Removing previous files
rm -rf $fDAT*

# Simulation
echo "Simulating..."

for i in $(seq $Ninicio $Npaso $Nfinal); do
	echo "Beginning simulation for size $i matrix with slow algorithm..."
	for ((j=1; j<=$NL1; j*=2)); do
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$(($L1size*$j)),$Nways,$LineSize --D1=$(($L1size*$j)),$Nways,$LineSize \
		--LL=$MaxLsize,$Nways,$LineSize ./../slow $i
		D1mrs=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}' | sed 's/,//g'))
		D1mws=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}' | sed 's/,//g'))
		rm -rf $TempFile
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$(($L1size*$j)),$Nways,$LineSize --D1=$(($L1size*$j)),$Nways,$LineSize \
		--LL=$MaxLsize,$Nways,$LineSize ./../fast $i
		D1mrf=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}' | sed 's/,//g'))
		D1mwf=$(printf "%09d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}' | sed 's/,//g'))
		rm -rf $TempFile
		echo "$i	$D1mrs		$D1mws		$D1mrf		$D1mwf" >> $fDAT$(($L1size*$j))".dat"
	done
done

# Plot generation
echo "Generating plots..."
gnuplot << END_GNUPLOT
set title "Read Cache Misses"
set xlabel "Matrix Size"
set ylabel "Number of Misses"
set grid
set term png size 960, 480
set key outside right center
set output "$f1PNG"
plot "$fDAT"."1024.dat" u 1:2 w l lw 2 lt rgb "#EDDA05" title "Cache 1024B slow", \
     "$fDAT"."2048.dat" u 1:2 w l lw 2 lt rgb "#FAAB00" title "Cache 2048B slow", \
     "$fDAT"."4096.dat" u 1:2 w l lw 2 lt rgb "#FF7600" title "Cache 4096B slow", \
     "$fDAT"."8192.dat" u 1:2 w l lw 2 lt rgb "#FF2B0F" title "Cache 8192B slow", \
     "$fDAT"."1024.dat" u 1:4 w l lw 2 lt rgb "#CD7DFF" title "Cache 1024B fast", \
     "$fDAT"."2048.dat" u 1:4 w l lw 2 lt rgb "#6C72D6" title "Cache 8192B fast", \
     "$fDAT"."4096.dat" u 1:4 w l lw 2 lt rgb "#1B5C9C" title "Cache 4096B fast", \
     "$fDAT"."8192.dat" u 1:4 w l lw 2 lt rgb "#003F5C" title "Cache 8192B fast",
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Write Cache Misses"
set xlabel "Matrix Size"
set ylabel "Number of Misses"
set grid
set term png size 960, 480
set key outside right center
set output "$f2PNG"
plot "$fDAT"."1024.dat" u 1:3 w l lw 2 lt rgb "#EDDA05" title "Cache 1024B slow", \
     "$fDAT"."2048.dat" u 1:3 w l lw 2 lt rgb "#FAAB00" title "Cache 2048B slow", \
     "$fDAT"."4096.dat" u 1:3 w l lw 2 lt rgb "#FF7600" title "Cache 4096B slow", \
     "$fDAT"."8192.dat" u 1:3 w l lw 2 lt rgb "#FF2B0F" title "Cache 8192B slow", \
     "$fDAT"."1024.dat" u 1:5 w l lw 2 lt rgb "#CD7DFF" title "Cache 1024B fast", \
     "$fDAT"."2048.dat" u 1:5 w l lw 2 lt rgb "#6C72D6" title "Cache 8192B fast", \
     "$fDAT"."4096.dat" u 1:5 w l lw 2 lt rgb "#1B5C9C" title "Cache 4096B fast", \
     "$fDAT"."8192.dat" u 1:5 w l lw 2 lt rgb "#003F5C" title "Cache 8192B fast",
replot
quit
END_GNUPLOT
