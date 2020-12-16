#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -o pescalar.out
#$ -j y
#$ -pe openmp 4

echo "Ejecutando timeSeriePar.sh"
echo ""
source timeSeriePar.sh