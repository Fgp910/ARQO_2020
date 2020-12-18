#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -o grano_sge.out
#$ -j y
#$ -pe openmp 4

echo "--------------- Ejecutando grano.sh ---------------"
echo ""
source grano.sh
