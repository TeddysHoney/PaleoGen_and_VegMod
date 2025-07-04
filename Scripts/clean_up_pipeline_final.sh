#!/bin/bash
#SBATCH --job-name="cleanup_test_script"
#SBATCH --mail-user=jennifer.zhu@unibe.ch
#SBATCH --mail-type=All
#SBATCH --time=48:00:00
#SBATCH --mem=265G
#SBATCH --cpus-per-task=64
#SBATCH --partition=epyc2
#SBATCH --qos=job_cpu_long		#for testing check points, remove long, or add _long for running script
#SBATCH --output=job_pal_%j.out
#SBATCH --error=job_pal_%j.err

# Script written by Jennifer Zhu (jennifer.zhu@unibe.ch)
# Last updates 18.06.2025
# All echo in *.out

# load required modules
module load wget/1.21.1-GCCcore-10.3.0
module load BWA/0.7.17-GCC-10.3.0
module load SAMtools/1.13-GCC-10.3.0
module load mapDamage/2.2.1-foss-2022a
module load FastQC/0.11.9-Java-11
# module load BBMap/38.96-GCC-10.3.0 need to test package

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


# download files 
wget -i ${working_path}/link.txt --rejected-log=${scratch_path}/rejected_links_log.csv

# create file to store sample names, NEVER ** I REPEAT ** NEVER edit this file, only for viewing purposes
touch sample_name.txt

# write sample name in sample_name.txt
for fastq in $(ls *L*_R*_*.fastq.gz)
do 
	echo $fastq
	sample_name=${fastq%_L*_R*_*}
	echo ${sample_name}
	
	# create file to save variable 
	touch sample_name.txt # this may need to be changed if multiple iterations are run in parallel
	
	# set file name to variable
	text_name=sample_name.txt
	
	# write sample name
	if grep -Fxq ${sample_name} ${text_name} # need to understand this 
	then 
		continue 
	else 
		printf "${sample_name}\n" >> ${text_name}
		
		continue
	fi
done

# starts clean up, loops for each sample
for sample_name in $(cat sample_name.txt)
do 
	echo ${sample_name}
	
	# make directory for all saved files
	mkdir -p ${saved_path}/${sample_name}
	saved_path_sample=${saved_path}/${sample_name}
	echo ${saved_path_sample}
	
	# make directory for intermediate files of sample
	mkdir -p ${scratch_path}/${sample_name}
	scratch_path_sample=${scratch_path}/${sample_name}
	echo ${scratch_path_sample}
	
	# make shortcut to temp_files in the saved files directory
	cd ${saved_path_sample}
	ln -s ${scratch_path_sample} temp_file_${sample_name}
	
	# go to working path for every sample because we will be moving to a different directory 
	cd ${working_path}

	# merge files from different lanes into a single file per sample
	cat ${sample_name}_*_R1_*.fastq.gz > ${scratch_path_sample}/${sample_name}_R1_001.fastq.gz
	cat ${sample_name}_*_R2_*.fastq.gz > ${scratch_path_sample}/${sample_name}_R2_001.fastq.gz
	
	# move all downloaded files to saved_files directory
	mv ${sample_name}*L*_R*_*.fastq.gz ${saved_path_sample}
	
	# fastQC on raw reads
	fastqc -f fastq ${scratch_path_sample}/${sample_name}_R1_001.fastq.gz -o ${saved_path_sample}
	fastqc -f fastq ${scratch_path_sample}/${sample_name}_R2_001.fastq.gz -o ${saved_path_sample}
	
	# rest is done in bbmap
	cd $WORKSPACE/HOLOGENE/programs/bbmap/
	
	# Step1: Remove low quality reads, adapters and PolyGs and remove last base
	sh bbduk.sh -Xmx2g in1=${scratch_path_sample}/${sample_name}_R1_001.fastq.gz in2=${scratch_path_sample}/${sample_name}_R2_001.fastq.gz out1=${scratch_path_sample}/${sample_name}_R1_001_clean.fastq.gz out2=${scratch_path_sample}/${sample_name}_R2_001_clean.fastq.gz qtrim=rl trimpolygright=10 ref=resources/adapters.fa ktrim=r k=17 mink=9 hdist=1 minlength=15 tbo=t forcetrimright2=1
	
	# fastQC on cleaned reads
	fastqc -f fastq ${scratch_path_sample}/${sample_name}_R1_001_clean.fastq.gz -o ${saved_path_sample}
	fastqc -f fastq ${scratch_path_sample}/${sample_name}_R2_001_clean.fastq.gz -o ${saved_path_sample}
	
	# Step2: force trim right end 10bp only on R1
	sh bbduk.sh -Xmx2g in=${scratch_path_sample}/${sample_name}_R1_001_clean.fastq.gz out=${scratch_path_sample}/${sample_name}_R1_001_clean_trim.fastq.gz minlength=0 forcetrimright2=10
	
	# fastQC on trimmed reads
	fastqc -f fastq ${scratch_path_sample}/${sample_name}_R1_001_clean_trim.fastq.gz -o ${saved_path_sample}
	
	# Step3: Merge reads, min length=15; this should be saved 
	sh bbmerge.sh in1=${scratch_path_sample}/${sample_name}_R1_001_clean_trim.fastq.gz in2=${scratch_path_sample}/${sample_name}_R2_001_clean.fastq.gz out=${saved_path_sample}/${sample_name}_001_merged.fastq.gz minlength=15
	
	# fastQC on merged reads
	fastqc -f fastq ${saved_path_sample}/${sample_name}_001_merged.fastq.gz -o ${saved_path_sample}
	
	# note currently in $WORKSPACE/HOLOGENE/programs/bbmap/

done

# Check point 

# Files in files/${sample_name}
## x4 ${sample_name}*L*_R*_*.fastq.gz
## x2 ${sample_name}_R*_001.fastqc.zip
## x2 ${sample_name}_R*_001.fastqc.html 
## x2 ${sample_name}_R*_001_clean.fastqc.zip
## x2 ${sample_name}_R*_001_clean.fastqc.html 
## ${sample_name}_001_clean_trim.fastqc.zip
## ${sample_name}_001_clean_trim.fastqc.html
## ${sample_name}_001_merged.fastq.gz
## ${sample_name}_001_merged.fastqc.zip
## ${sample_name}_001_merged.fastqc.html
### 17 files

# Files in temp_files 
## x2 ${sample_name}_R*_001.fastq.gz
## x2 ${sample_name}_R*_001_clean.fastq.gz
## ${sample_name}_R1_001_clean_trim.fastq.gz
### 5 files

