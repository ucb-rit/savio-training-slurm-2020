#!/bin/bash
# Job name:
#SBATCH --job-name=test
#
# Account:
#SBATCH --account=co_stat
#
# Partition:
#SBATCH --partition=savio2
#
# Wall clock limit (45 seconds here):
#SBATCH --time=00:00:45
#
## Command(s) to run:
module load python/3.6
python calc.py >& calc.out
