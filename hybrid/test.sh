#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -c 16

srun ./a.out
