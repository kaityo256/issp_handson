#!/bin/bash
#SBATCH -p i8cpu
#SBATCH -N 1
#SBATCH -n 128

srun ~/github/cps/cps task.sh
