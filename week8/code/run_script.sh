#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l select=1:ncpus=1:mem=1gb
module load anaconda3/personal
cp $HOME/run_files/Demographic.R $TMPDIR
R --vanilla < $HOME/run_files/hjt24_HPC_2024_demographic_cluster.R
mv output_* $HOME/results/
echo "R has finished running"
