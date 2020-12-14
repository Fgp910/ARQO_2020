# ARQO 2020-2021. Task 4: exercise 3
# Script for times and speedup tables (different grain)

#!/bin/bash

# inicializar variables
P=1
N=10
Hinicio=1
Hfinal=4
Iter=5
fTime=grano_time.dat
fSpeed=grano_speedup.dat

# borrar los ficheros DAT
rm -f $fTime $fSpeed

# generar los ficheros DAT vacíos
touch $fTime $fSpeed

echo "Running mult_serie..."
serieTime=0
for ((i=1; i <= Iter; i++)); do
    echo "I: $i / $Iter..."
    aux=$(./../mult_serie $N | grep 'time' | awk '{print $3}')
    serieTime=$(echo "$serieTime + $aux" | bc)
done
serieTimeMean=$(echo "$serieTime / $Iter" | bc -l)
echo "$serieTime" >> $fTime

echo "Running mult_par*..."
unset par1Time
unset par2Time
unset par3Time
for i in $(seq $Hinicio 1 $Hfinal); do par1Time+=(0); done
for i in $(seq $Hinicio 1 $Hfinal); do par2Time+=(0); done
for i in $(seq $Hinicio 1 $Hfinal); do par3Time+=(0); done
for ((H=Hinicio, j=0; H <= Hfinal ; H++, j++)); do
    echo "Th: $H / $Hfinal..."
    export OMP_NUM_THREADS=$H
    for ((i=1; i <= Iter; i++)); do
        echo "I: $i / $Iter..."
        aux=$(./../mult_par1 $N | grep 'time' | awk '{print $3}')
        par1Time[$j]=$(echo "${par1Time[$j]} + $aux" | bc)
        aux=$(./../mult_par1 $N | grep 'time' | awk '{print $3}')
        par2Time[$j]=$(echo "${par2Time[$j]} + $aux" | bc)
        aux=$(./../mult_par1 $N | grep 'time' | awk '{print $3}')
        par3Time[$j]=$(echo "${par3Time[$j]} + $aux" | bc)
    done
done

unset par1Speed
unset par2Speed
unset par3Speed
for i in $(seq $Hinicio 1 $Hfinal); do par1Speed+=(0); done
for i in $(seq $Hinicio 1 $Hfinal); do par2Speed+=(0); done
for i in $(seq $Hinicio 1 $Hfinal); do par3Speed+=(0); done
for ((H=Hinicio, j=0; H <= Hfinal ; H++, j++)); do
    par1Time[$j]=$(echo "${par1Time[$j]} / $Iter" | bc -l)
    par2Time[$j]=$(echo "${par2Time[$j]} / $Iter" | bc -l)
    par3Time[$j]=$(echo "${par3Time[$j]} / $Iter" | bc -l)
    par1Speed[$j]=$(echo "$serieTime / ${par1Time[$j]}" | bc -l)
    par2Speed[$j]=$(echo "$serieTime / ${par2Time[$j]}" | bc -l)
    par3Speed[$j]=$(echo "$serieTime / ${par3Time[$j]}" | bc -l)
done

echo ${par1Time[@]} >> $fTime
echo ${par2Time[@]} >> $fTime
echo ${par3Time[@]} >> $fTime
echo ${par1Speed[@]} >> $fSpeed
echo ${par2Speed[@]} >> $fSpeed
echo ${par3Speed[@]} >> $fSpeed
