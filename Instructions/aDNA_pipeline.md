# Ancient DNA Pipelines at UniBe 🚧

## Introduction 
This is still under construction 🚧. This is the preliminary pipeline that is available. Scripts may be missing on GitHub or __ips_pal__.

This is the pipeline used at UniBe to process ancient DNA samples. Please read this document carefully to avoid errors. All scripts for this pipeline can be found in [Scripts directory](../Scripts/). 
A copy of all the scripts can also be found in the __ips_pal__ workspace:

```bash 
cd $WORKSPACE/reference/scripts
```
This pipeline makes use of an environment file to be used in conjunction with the scripts to set variables. This is to avoid editing the scripts and creating errors. Currently, the scripts should not contain errors when run. If you encounter errors, please email jennifer.zhu@unibe.com. 


## Setup

Please copy the *.env template file to the __project__ directory or your project-specific directory and rename it in the following format: <project_name>_<species>_<run_number>.env
```bash
cp $WORKSPACE/reference/scripts/variable_file_example.env <project_directory_path>
```
```bash
cd <project_directory>
```
```bash
mv variable_file_example.env <project_name>_<species>_<run_number>.env
```
Open the *.env file and read all the instructions in the hashtag box and edit the relevant variables:
```bash
nano <project_name>_<species>_<run_number>.env
```
>[!warning]
> It is recommended that you edit the *.env files with `nano`. You can edit this file in any text-editing software, but this may add carriage returns that may break the script.
>Also, ensure that there are no spaces around the "=". This will cause the script to fail.


## Downloading Fastq Files and Auto-writing sample_text 

Script:  [fastq_download.sh](../Scripts/fastq_download.sh) *change

To download the raw fastq data directly from [UHTS-lims](https://lims.bioinformatics.unibe.ch/), please provide a link file named preferably with the following convention: *__link_<project_name>_<species>_<run>.txt__* with the download link for all the fastq files you want to download. __Each link should be a separate line.__

Ensure the name of this file is saved as the *__link_text__* variable in the *.env file. This will automatically write the sample names to a *.txt document used for downstream analysis.

>[!important]
>If mapping to a single organism (i.e., NOT metagenomics), it is simpler for downstream analysis to separate samples by species.
>
>Put the absolute path to the link file to avoid errors.

### Submitting the Script

Submit the script with the following command:
```bash
sbatch $WORKSPACE/reference/script/fastq_download.sh < edited_environment_file>.env
```

This script will automatically run the [clean_up_submitter.sh](../Scripts/clean_up_submitter.sh)

## Running Script with pre-downloaded fastq files (Edit) 

If your fastq files are already downloaded, ensure that link_text is set to "NA" in the *.env file to skip fastq download. Then place all your fastq files in the same directory (e.g., `project` directory) and run the same script.

>[!warning] 
>If you are not downloading directly from UHTS-lims and running with pre-downloaded fastq files, DO NOT run multiple scripts at once in the same directory. This will result in the same final sample_text as the program will generate a sample_text with all the *.fastq.gz files in the same directory. This script will also generate sample names based on the UHTS-lims naming convention. If you have a different naming convention, please edit and run the [sample_autowrite.sh] script. 

### Submitting the Script

Submit the script with the following command:
```bash
sbatch $WORKSPACE/reference/script/clean_up_submitter.sh <edited_enviorment_file>.env
```

## Clean up 

Script:  [clean_up_submitter_fastp.sh](../Scripts/clean_up_submitter_fastp.sh)

This script is set to run on paired-end sequencing data. It will remove adapters, merge paired-end reads, and remove duplicates and low-quality reads with fastp, with the following parameters:
- clip 10bp on R2 5'
- clip 1bp on R1 3'
- Deduplicate with dup_cal_ccuracy 5
- minimum length set to 30 bp
- base quality set to 30
- read quality set to 25
- remove low complexity with trim_poly_x

If you are not running this script, please ensure that your files are in the following format to be processed by the next script: `*_clean_merged.fastq.gz`.

### Submitting the clean-up script. 

After ensuring you have edited the *.env file and the link_text/sample_text file, you can submit the script with the following command. 
```bash
sbatch $WORKSPACE/reference/script/clean_up_submitter.sh <edited_enviorment_file>.env
```

### Next Steps

To map to one single organism, follow the instructions under [Single Organism Mapping](#single-organism-mapping). 

To start metagenomic analysis, follow the instructions under [Metagenomics](#metagenomics).


## Single Organism Mapping

Script: [mapping_script_submitter.sh](../Scripts/mapping_script_submitter.sh)

This is used to map reads to the available genomes of a single organism with BWA or bowtie, depending on which method you have set as the __mapping_method__ in the *.env file. The script will automatically index the genome if it is not already indexed. You can change the specific genome you map to (i.e., cpDNA, mtDNA, ncDNA) in the *.env file under __mapped_genome__, where you can choose only *cpDNA*, *mtDNA*, or *ncDNA*. Please ensure that a corresponding __genome_text__ is found in:
```bash
cd $WORKSPACE/reference/scripts/genome_txt
```
If not, please email jennifer.zhu@unibe.ch. 

### Changing the mapped genome

The script will automatically map to all available genomes specified in genome_txt to all samples in __sample_text__, unless specified in __mapped_genome__. To map each sample. 
```
${sample_name}\t${full_genome_path}
```
e.g.
```
SNG_18	$WORKSPACE/reference/genomes/Abies/Abies_alba_ncDNA.fa
SNG_19	$WORKSPACe/reference/genomes/Larix/Larix_decidua_mtDNA.fasta 
```
Unfortunately, this is not currently automated. Please use this format with caution, as it may result in errors and script failures.

### Submitting the mapping script. 

After ensuring you the *.env file has all of the variables set to the desired setting, you can submit the script with the following command:
```bash
sbatch $WORKSPACE/reference/script/mapping_submitter.sh <edited_enviorment_file>.env
```

### Getting Summary Data

Submit the Summary script:
```bash
sbatch $WORKSPACE/reference/script/summary.sh < edited_environment_file>.env
```
Then run multiqc with the following command: 
```bash
multiqc . --ignore-symlinks --config modifed_eager.yaml --tag ${project_name}_${run} -o ${project_name}_multiqc_${run}
```


## Metagenomics 

This is currently underconstruction 🚧.

### Submitting the metagenomic script. 
After ensuring you the *.env file has all of the variables set to the desired setting, you can submit the script with the following command:
```bash
sbatch $WORKSPACE/reference/script/metagenomics_submitter.sh <edited_enviorment_file>.env
```


## Finishing up

Please delete files that are no longer necessary so that we have enough storage space in the cluster. 

After the scripts have finished running, all __\*.err__ and __\*.out files__ can be deleted immediately. They are mostly important for troubleshooting the script.

```bash 
rm job_pal*
```

Check before you delete the scratch file directory that the files are no longer required. 

```bash 
rm -r temp_files
```



## Troubleshooting

If you need help with the scripts, please email jennifer.zhu@unibe.ch. Otherwise, googling the error code found in the __\*.err__ file is always a good place to start. [You can also start a support ticket with the HPC team](https://hpc-unibe-ch.github.io/support/). 
