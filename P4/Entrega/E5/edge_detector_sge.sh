#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -o edge.out
#$ -j y
#$ -pe openmp 8

echo "Ejecutando time_edge_detector.sh"
echo ""
source time_edge_detector.sh