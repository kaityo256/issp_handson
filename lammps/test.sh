#!/bin/sh

#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -c 16

source /home/issp/materiapps/intel/lammps/lammpsvars.sh
srun lammps < collision.input
