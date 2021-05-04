#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 128

srun ./a.out
