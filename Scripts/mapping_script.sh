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
# Last updates 28.07.2025
# All echo in *.out

# load required modules
# module load wget/1.21.1-GCCcore-10.3.0
module load BWA/0.7.17-GCC-10.3.0
module load SAMtools/1.13-GCC-10.3.0
module load mapDamage/2.2.1-foss-2022a
# module load FastQC/0.11.9-Java-11

# set up directories, 
# this should be the same as what is used for the clean_up_final.sh script
# this should also be run from the same directory as the clean_up_final.sh script

# set working path
working_path=$WORKSPACE/test_scripts/loop_test
echo ${working_path}

# make directory for temp files and set as scratch_path 
mkdir -p ${working_path}/temp_files
scratch_path=${working_path}/temp_files
echo ${scratch_path}

# set path for saved files 
mkdir -p ${working_path}/files
saved_path=${working_path}/files
echo ${saved_path}

# document to save all information about samples 
# touch sample_info.txt 

# iteration over samples, then genome
for sample_name in $(cat sample_name.txt)
do
	echo ${sample_name}
	
	# set individual sample directories 
	
	# saved files 
	mkdir -p ${saved_path}/${sample_name}
	saved_path_sample=${saved_path}/${sample_name}
	echo ${saved_path_sample}
	
	# intermediate samples 
	mkdir -p ${scratch_path}/${sample_name}
	scratch_path_sample=${scratch_path}/${sample_name}
	echo ${scratch_path_sample}
	
	# set count
	count=1
	
	for genome in $(cat genome_name.txt) 
	# note genomes should be in *.fasta format
	do 
		genome_name=${genome%.f*}
		echo ${genome_name}
		# genome is ${genome_name}.{fasta,fna,fa}
		echo ${genome}
		
		# run from sample specific directory
		cd ${saved_path_sample}
		echo "current path: $(pwd)"
		
		# align to reference genome
		bwa aln -l 1024 -n 0.01 -o 2 -t 16 $WORKSPACE/reference/genomes/${genome} ${saved_path_sample}/${sample_name}_001_merged.fastq.gz > ${sample_name}_${genome_name}_mapped.sai
		echo $(ls -l *_mapped.sai)
		
		# convert .sai directly to .bam file, note that the command is specific for single-end reads (samse)
		# use sampe for paired-end reads
		bwa samse -r '@RG\tID:'${sample_name}_${genome_name}'\tLB:Lib'${count}_${sample_name}'\tPL:ILLUMINA\tSM:'${sample_name}_${genome_name} $WORKSPACE/HOLOGENE/genomes/$genome ${sample_name}_${genome_name}_mapped.sai ${sample_name}_001_merged.fastq.gz | samtools view -Sbho ${sample_name}_${genome_name}_mapped.bam
		echo $(ls -l *_mapped.bam)
		
		# remove reads with mapping quality lower than 20 to get rid of ambiguous alignments, save only mapped reads
		samtools view -bh -F4 -q 20 ${sample_name}_${genome_name}_mapped.bam > ${sample_name}_${genome_name}_mapped_qc.bam
		echo $(ls -l *_mapped_qc.bam)
		
		# print out number of mapped reads
		samtools view -c -F4 ${sample_name}_${genome_name}_mapped.bam  # should actually print this to a doc
		
		# sort mapped reads
		samtools sort -o ${sample_name}_${genome_name}_mapped_qc_sort.bam -O BAM ${sample_name}_${genome_name}_mapped_qc.bam
		echo $(ls *_mapped_qc_sort.bam)
		
		# remove duplicates 
		samtools rmdup -s ${sample_name}_${genome_name}_mapped_qc_sort.bam ${sample_name}_${genome_name}_clean.bam
		samtools index ${sample_name}_${genome_name}_clean.bam
		echo $(ls *_clean.bam)
		
		# print out final number of cleaned and mapped reads and calculate depth of coverage
		# print this to a doc?? 
		samtools view -c ${sample_name}_${genome_name}_clean.bam
		samtools depth -aa ${sample_name}_${genome_name}_clean.bam | awk '{sum+=$3} END {print "Average = ", sum/NR}'
		
		# run MapDamage
		mapDamage -i ${sample_name}_${genome_name}_clean.bam -r $WORKSPACE/HOLOGENE/genomes/${genome} 
		
		#checkpoint 
		echo "Finished ${genome_name}"	
		
		# increase count for next genome
		count=$((count+1))
		echo "This is the $((count-1))th loop of the genome"
	done
	
	# this is where we would sort the files to specific locations
	
	# return to original directory to restart iteration
	cd ${working_path}
	
done
