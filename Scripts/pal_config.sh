#!/bin/bash
#SBATCH --job-name="pal_configuration"
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
# Last updates 22.08.2025
# All echo in *.out

# This script is written to reconfigure your HPC profile for the ips_pal genetic workflow
# If you are going to run this file, please note that you will likely have to logout of UBELIX and log back in for the new commands to work
# Logout command: exit 
# Note: This will send Jennifer Zhu (jennifer.zhu@unibe.ch) an email. PLEASE KEEP IT THIS WAY. 

# Fail safe 
set -e -u -o pipefail 

# reporting
script_name="pal_configuration"
echo "## Running ${script_name}"
date

# Go to $HOME as this will be written to the .bashrc file
cd $HOME

# setup shortcuts 
cat << EOF >> .bashrc

#shortcuts 
alias ll='ls -a'
alias home='cd $HOME'
alias workspace='cd $WORKSPACE'
alias load='module load Workspace'
alias ips='HPC_WORKSPACE=ips_pal module load Workspace'
alias queue='squeue --me'

EOF

# Set $PATH to $WORKSPACE/bin instead of $HOME/bin, required to run OBITools4
cat << EOF >> .bashrc

# reset \$PATH\ to run OBITools4
export PATH=/storage/research/ips_pal/bin:\$PATH\

EOF

# finish script
echo "## Finished Script"
if [ -n "$SLURM_JOB_ID" ]; then
    echo "## Fetching resource usage for SLURM job ID: $SLURM_JOB_ID"
    sacct -j "$SLURM_JOB_ID" --format=JobID,JobName,MaxRSS,Elapsed,State -P
fi

# Output should be found in $HOME
# *.err and *.out should be in script file, please delete with following command
# rm job_pal_*

