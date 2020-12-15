#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -o mult_sge.out
#$ -j y
#$ -pe openmp 4

export PATH=$PATH:/share/apps/tools/gnuplot/bin
echo "--------------- Ejecutando mult.sh ---------------"
echo ""
source mult.sh
