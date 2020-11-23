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
fPNG=misses.png

# Removing previous files
rm -rf Cachegrind/*

#Simulation
echo "Simulating..."
mkdir Cachegrind -p

for i in $(seq $Ninicio $Npaso $Nfinal); do
	echo "Beginning simulation for size $i matrix with slow algorithm..."
	touch $fDAT$i".dat"
	for ((j=1; j<=$NL1; j*=2)); do
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile --I1=$(($L1size*$j)),$Nways,$LineSize --D1=$(($L1size*$j)),$Nways,$LineSize --LL=$MaxLsize,$Nways,$LineSize ./slow $i
		D1mrs=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}')
		D1mws=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}')
		rm -rf $TempFile
		valgrind --tool=cachegrind --cachegrind-out-file=$TempFile --I1=$(($L1size*$j)),$Nways,$LineSize --D1=$(($L1size*$j)),$Nways,$LineSize --LL=$MaxLsize,$Nways,$LineSize ./fast $i
		D1mrf=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $5}')
		D1mwf=$(cg_annotate $TempFile | head -n 30 | grep "PROGRAM TOTALS" | awk '{print $8}')
		rm -rf $TempFile
		echo "$i	$D1mrs	$D1mws	$D1mrf	$D1mwf" >> $fDAT$i".dat"
	done
done