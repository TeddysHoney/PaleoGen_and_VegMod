#!/bin/bash
#SBATCH --job-name="obipcr_<primer"  
#SBATCH --mail-user=<your_email@unibe.ch>               
#SBATCH --mail-type=All
#SBATCH --nodes=1
#SBATCH --time=72:00:00
#SBATCH --mem=128G
#SBATCH --cpus-per-task=4
#SBATCH --partition=epyc2
#SBATCH --qos=job_cpu
#SBATCH --wckey=<your_wckey>
#SBATCH --account=paygo                                         
#SBATCH --output=obiinstall_%j.out
#SBATCH --error=obiinstall_%j.err

# this is the first step for obitools db curation from db

# variables
dir=""
DB="db_file.fasta"
DB_NAME=$(basename "$DB" .fasta)
primer_name=""
forward_primer=""
reverse_primer=""
max_length=""

# if file too big, split file
awk -v DB_name="$DB_NAME" 'BEGIN {file_idx=1; chunk_size=40*1024*1024*1024} 
    { if (/^>/ && total_size > chunk_size) 
        { file_idx++; total_size=0; } print $0 >> DB_name "_" file_idx ".fasta"; 
        total_size += length($0) + 1; }' "$DB"


# for trnL gh primers found in Taberlet et al 2006
count=1
for FASTA in ${DB_NAME}_*.fasta
do 

    obipcr -e 3 -l 10 \
        --max-length ${max_length} \
        --max-cpu 4 \
        --input-OBI-header \
        --forward $forward_primer \
        --reverse $reverse_primer \
        --no-order \
        -o ${dir}/${DB_NAME}_${count}_${primer_name}_pcr.fasta \
        $FASTA 
    ((count++))
done

# cat together for next step
cat ${DB_NAME}_*_${primer_name}_pcr.fasta > ${DB_NAME}_${primer_name}_pcr.fasta
