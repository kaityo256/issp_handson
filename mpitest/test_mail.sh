#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 128
#SBATCH --mail-type=BEGIN
#SBATCH --mail-user=your@mail.address

srun ./a.out
