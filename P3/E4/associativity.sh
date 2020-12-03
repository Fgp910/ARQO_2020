# ARQO 2020-2021. Task 3: exercise 4
# Script for cachegrind simulation and plot generation with variable associativity

#!/bin/bash


P=5
Ninicio=$((128 + $P * 128))
Nfinal=$((128 + ($P + 1) * 128))
Npaso=16
fDAT="assoc_"
L1size=$((1024*32))
MaxLsize=$((8*1024*1024))
LineSize=64
K=8
TempFile=temporary_file.dat
f1PNG=asoc_lectura.png
f2PNG=asoc_escritura.png

# Removing previous files
rm -rf $fDAT*

# Simulation
echo "Simulating..."

for i in $(seq $Ninicio $Npaso $Nfinal); do
	echo "Beginning simulation for size $i matrix with regular algorithm..."
	for ((j=1; j<=$K; j*=2)); do
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$L1size,$j,$LineSize --D1=$L1size,$j,$LineSize \
		--LL=$MaxLsize,$j,$LineSize ./../mult $i
		D1mrs=$(printf "%10d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}' | sed 's/,//g'))
		D1mws=$(printf "%10d" $(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}' | sed 's/,//g'))
		rm -rf $TempFile
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile \
		--I1=$L1size,$j,$LineSize --D1=$L1size,$j,$LineSize \
		--LL=$MaxLsize,$j,$LineSize ./../mult_trans $i
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
plot "$fDAT"."1.dat" u 1:2 w l lw 2 lt rgb "#EDDA05" title "1-way associative regular", \
     "$fDAT"."2.dat" u 1:2 w l lw 2 lt rgb "#FAAB00" title "2-way associative regular", \
     "$fDAT"."4.dat" u 1:2 w l lw 2 lt rgb "#FF7600" title "4-way associative regular", \
     "$fDAT"."8.dat" u 1:2 w l lw 2 lt rgb "#FF2B0F" title "8-way associative regular", \
     "$fDAT"."1.dat" u 1:4 w l lw 2 lt rgb "#CD7DFF" title "1-way associative transposed", \
     "$fDAT"."2.dat" u 1:4 w l lw 2 lt rgb "#6C72D6" title "2-way associative transposed", \
     "$fDAT"."4.dat" u 1:4 w l lw 2 lt rgb "#1B5C9C" title "4-way associative transposed", \
     "$fDAT"."8.dat" u 1:4 w l lw 2 lt rgb "#003F5C" title "8-way associative transposed",
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
plot "$fDAT"."1.dat" u 1:3 w l lw 2 lt rgb "#EDDA05" title "1-way associative regular", \
     "$fDAT"."2.dat" u 1:3 w l lw 2 lt rgb "#FAAB00" title "2-way associative regular", \
     "$fDAT"."4.dat" u 1:3 w l lw 2 lt rgb "#FF7600" title "4-way associative regular", \
     "$fDAT"."8.dat" u 1:3 w l lw 2 lt rgb "#FF2B0F" title "8-way associative regular", \
     "$fDAT"."1.dat" u 1:5 w l lw 2 lt rgb "#CD7DFF" title "1-way associative transposed", \
     "$fDAT"."2.dat" u 1:5 w l lw 2 lt rgb "#6C72D6" title "2-way associative transposed", \
     "$fDAT"."4.dat" u 1:5 w l lw 2 lt rgb "#1B5C9C" title "4-way associative transposed", \
     "$fDAT"."8.dat" u 1:5 w l lw 2 lt rgb "#003F5C" title "8-way associative transposed",
replot
quit
END_GNUPLOT
