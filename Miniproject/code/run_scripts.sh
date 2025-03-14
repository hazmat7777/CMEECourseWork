#!/bin/bash

echo "Wrangling data..."
# Run DataWrang.R
Rscript DataWrang.R

echo "Fitting models..."
# Run model_fitting.R
Rscript model_fitting.R

echo "Making plots..."
# Run visualisation.R
Rscript visualisation.R


echo "All scripts executed successfully!"
