#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -o pescalar.out
#$ -j y
#$ -pe openmp 4

export PATH=$PATH:/share/apps/tools/valgrind/bin:/share/apps/tools/gnuplot/bin
echo "Ejecutando time_serie_par.sh"
echo ""
source time_serie_par.sh