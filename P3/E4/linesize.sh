# ARQO 2020-2021. Task 3: exercise 4
# Script for cachegrind simulation and plot generation with variable line size

#!/bin/bash


P=5
Ninicio=$((128 + $P * 128))
Nfinal=$((128 + ($P + 1) * 128))
Npaso=16
fDAT="line_"
L1size=$((1024*32))
MaxLsize=$((8*1024*1024))
NWays=1
K=256
TempFile=temporary_file.dat
f1PNG=line_lectura.png
f2PNG=line_escritura.png

# Removing previous files
rm -rf $fDAT*

# Simulation
echo "Simulating..."

for i in $(seq $Ninicio $Npaso $Nfinal); do
	echo "Beginning simulation for size $i matrix with regular algorithm..."
	for ((j=32; j<=$K; j*=2)); do
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$L1size,$NWays,$j --D1=$L1size,$NWays,$j \
		--LL=$MaxLsize,$NWays,$j ./../mult $i
		D1mrs=$(printf "%10d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}' | sed 's/,//g'))
		D1mws=$(printf "%10d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}' | sed 's/,//g'))
		rm -rf $TempFile
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$L1size,$NWays,$j --D1=$L1size,$NWays,$j \
		--LL=$MaxLsize,$NWays,$j ./../mult_trans $i
		D1mrf=$(printf "%10d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}' | sed 's/,//g'))
		D1mwf=$(printf "%10d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}' | sed 's/,//g'))
		rm -rf $TempFile
		echo "$i	$D1mrs		$D1mws		$D1mrf		$D1mwf" >> $fDAT$j".dat"
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
plot "$fDAT"."32.dat"  u 1:2 w l lw 2 lt rgb "#EDDA05" title "32B line regular", \
     "$fDAT"."64.dat"  u 1:2 w l lw 2 lt rgb "#FAAB00" title "64B line regular", \
     "$fDAT"."128.dat" u 1:2 w l lw 2 lt rgb "#FF7600" title "128B line regular", \
     "$fDAT"."256.dat" u 1:2 w l lw 2 lt rgb "#FF2B0F" title "256B line regular", \
     "$fDAT"."32.dat"  u 1:4 w l lw 2 lt rgb "#CD7DFF" title "32B line transposed", \
     "$fDAT"."64.dat"  u 1:4 w l lw 2 lt rgb "#6C72D6" title "64B line transposed", \
     "$fDAT"."128.dat" u 1:4 w l lw 2 lt rgb "#1B5C9C" title "128B line transposed", \
     "$fDAT"."256.dat" u 1:4 w l lw 2 lt rgb "#003F5C" title "256B line transposed",
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
plot "$fDAT"."32.dat"  u 1:3 w l lw 2 lt rgb "#EDDA05" title "32B line regular", \
     "$fDAT"."64.dat"  u 1:3 w l lw 2 lt rgb "#FAAB00" title "64B line regular", \
     "$fDAT"."128.dat" u 1:3 w l lw 2 lt rgb "#FF7600" title "128B line regular", \
     "$fDAT"."256.dat" u 1:3 w l lw 2 lt rgb "#FF2B0F" title "256B line regular", \
     "$fDAT"."32.dat"  u 1:5 w l lw 2 lt rgb "#CD7DFF" title "32B line transposed", \
     "$fDAT"."64.dat"  u 1:5 w l lw 2 lt rgb "#6C72D6" title "64B line transposed", \
     "$fDAT"."128.dat" u 1:5 w l lw 2 lt rgb "#1B5C9C" title "128B line transposed", \
     "$fDAT"."256.dat" u 1:5 w l lw 2 lt rgb "#003F5C" title "256B line transposed",
replot
quit
END_GNUPLOT
