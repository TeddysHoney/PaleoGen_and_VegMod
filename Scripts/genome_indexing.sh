#!/bin/bash
#SBATCH --job-name="Mapping_test"
#SBATCH --mail-user=jennifer.zhu@unibe.ch
#SBATCH --mail-type=All
#SBATCH --time=48:00:00
#SBATCH --mem=100G
#SBATCH --cpus-per-task=64
#SBATCH --partition=epyc2
#SBATCH --qos=job_cpu_long		#for testing check points, remove long, or add _long for running script
#SBATCH --output=job_pal_%j.out
#SBATCH --error=job_pal_%j.err

# Script written by Jennifer Zhu (jennifer.zhu@unibe.ch)
# Last updates 19.06.2025
# All echo in *.out

# load required modules
module load BWA/0.7.17-GCC-10.3.0
module load SAMtools/1.13-GCC-10.3.0


# go to genome directory
cd $WORKSPACE/HOLOGENE/genomes

# find all files that only end in .fasta

for file in $(ls *.{fasta,fa,fna})
do 
	echo ${file}
	name=${file%.f*}
	echo ${name}
	
	# check if the *.amb file exists
	# if the *.amb file exists it has already been indexed
	if [[ -f ${file}.amb ]] 
	then
		
		# file exists
		echo "${file} is already indexed."
		continue
	
	else
	
		# file doesn't exist, index file
		echo "Indexing ${file}"
		bwa index ${file}
	fi
	
done	