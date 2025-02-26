#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=1gb
module load anaconda3/personal
cp $HOME/run_files/Demographic.R $TMPDIR
cp $HOME/run_files/hjt24_HPC_2024_neutral_cluster.R $TMPDIR
cp $HOME/run_files/hjt24_HPC_2024_main.R $TMPDIR
cd $TMPDIR
R --vanilla < $HOME/run_files/hjt24_HPC_2024_neutral_cluster.R
mv result_* $HOME/results/
