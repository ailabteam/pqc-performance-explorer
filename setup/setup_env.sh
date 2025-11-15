#!/bin/bash
echo "=== Setting up Conda environment: pqc-research ==="
conda create -y --name pqc-research python=3.10
conda activate pqc-research

echo "=== Installing dependencies ==="
conda install -y -c conda-forge cmake gcc gxx make ninja git pandas numpy matplotlib seaborn jupyterlab

echo "=== Environment 'pqc-research' is ready. Please run 'conda activate pqc-research' ==="
