#!/bin/bash
#SBATCH --job-name="pal_configratioin_test"
#SBATCH --mail-user=jennifer.zhu@unibe.ch
#SBATCH --mail-type=All
#SBATCH --time=01:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --partition=epyc2
#SBATCH --qos=job_cpu	#for testing check points, remove long, or add _long for running script
#SBATCH --output=job_pal_%j.out
#SBATCH --error=job_pal_%j.err

# Script written by Jennifer Zhu (jennifer.zhu@unibe.ch)
# Last updates 31.07.2025
# All echo in *.out

# This script is written to reconfigure your HPC profile for the ips_pal genetic workflow
# If you are going to run this file, please note that you will likely have to logout of UBELIX and log back in for the new commands to work
# Logout command: exit 
# Note: This will send Jennifer Zhu an email. KEEP IT LIKE THIS. 

# Go to $HOME as this will be written to the .bashrc file
# test write to .output.txt
cd $HOME

# setup shortcuts 
cat << EOF >> .output.txt

#shortcuts 
alias ll='ls -a'
alias home='cd $HOME'
alias workspace='cd $WORKSPACE'
alias load='module load Workspace'
alias ips='HPC_WORKSPACE=ips_pal module load Workspace'
alias queue='squeue --me'

EOF

# Set $PATH to $WORKSPACE/bin instead of $HOME/bin, required to run OBITools4
cat << EOF >> .output.txt

# reset \$PATH\ to run OBITools4
export PATH=/storage/research/ips_pal/bin:\$PATH\

EOF

# Output should be found in $HOME
# *.err and *.out should be in script file