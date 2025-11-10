# Ancient DNA Pipelines at UniBe 🚧

## Introduction 
This is still under construction 🚧. This is the preliminary pipeline that is available. Scripts may be missing on github or __ips_pal__.

This is the pipeline used at UniBe to process ancient DNA samples. Please read this document carefully to avoid errors. All scripts for this pipeline can be found in [Scripts folder](../Scripts/). 
A copy of all the scripts can also be found in the __ips_pal__ workspace:

```bash 
cd $WORKSPACE/reference/scripts
```
This pipeline make use of an envorinment file to be used in conjuction with the scripts to set variables. This is to avoid editing the scripts and creating errors. Currently, the scripts should not contain errors when run. If you encounter errors, please email jennifer.zhu@unibe.com. 

## Setup

Please copy the *.env template file to the project folder or your project-specific folder and rename it in the following format: <project_name>_<species>_<run_number>.env
```bash
cp $WORKSPACE/reference/scripts/variable_file_example.env <project_folder>
```
```bash
cd <project_folder>
```
```bash
mv variable_file_example.env <project_name>_<species>_<run_number>.env
```
Open the *.env file and read all the instructions in the hastag box and edit the relavent vairables:
```bash
nano <project_name>_<species>_<run_number>.env
```
>[!warning]
>Ensure that there are no spaces around the "=". This will cause the script to fail.

## Clean up 

Script:  [clean_up_pipeline_final.sh](../Scripts/clean_up_pipeline_final.sh)

This script is to be run on paired-end sequencing data. It will download raw fastq data directly from [UHTS-lims](https://lims.bioinformatics.unibe.ch/), remove adapters and merge paired-end reads. It will also remove duplicates for optimal data storage. 

### Direct Download from UHTS-lims

To download the raw fastq data directly from [UHTS-lims](https://lims.bioinformatics.unibe.ch/), please provide a link file named preferably with the following convention: *__link_<project_name>_<species>_<run>.txt__*. Each link should be a separate line.

Ensure the name of this file is saved as *__link_text__* variable in the *.env file. This will automatically write the sample names to a *.txt document used for downstream analysis.

>[!important]
>If mapping to a single organism (i.e. NOT metagenomics) it is simpler for downstream analysis to separate samples by species.
>
>Put the absolute path to to the link file to avoid errors.

### Running Script with pre-download fastq files (Edit) 

In the *.env file, ensure that link_text is set to "NA" to skip fastq download. Ensure that all our fastq files are in the same directory, start an interactive session and used the sample_autowrite.sh script to create a sample_text with all the sample names. 

Ensure that this is the same sample_text name is the same as the one set in the *.env file.

>[!warning] 
>Do not run multiple sample_autowrite in the same directory at once. This will result in the same final sample_text.

### Submitting the clean up script. 
After ensuring you have edited the *.env file and the link_text/sample_text file, you can submitt the script with the following command. 
```bash
sbatch $WORKSPACE/reference/script/clean_up_submitter.sh <edited_enviorment_file>.env
```
### Next Steps
To map to one single organism, follow the instruction under [Single Organism Mapping](#single-organism-mapping). 

To start metagenomic analysis, follow the instruction under [Metagenomics](#metagenomics).

# Single Organism Mapping

Script: [mapping_script.sh](../Scripts/mapping_script.sh)

This is used to map reads to the available genomes of a single organism with BWA or bowtie, depending or which method you have set as the __mapping_method__. The script will automatically index the genome if it is not already indexed. You can change the specifiy genome you map to (i.e. cpDNA, mtDNA, ncDNA) in the *.env file under __mapped_genome__. Please ensure that a corresponding __genome_text__ is found in:
```bash
cd $WORKSPACE/reference/scripts/genome_txt
```
If not, please email jennifer.zhu@unibe.ch. 

### Changing mapped genome
The script will automatically map to all available genomes specified in genome_txt to all samples in __sample_text__, unless specified in __mapped_genome__. To change this, you will have to write your own __combination_text__ in the following format:
```
${sample_name}\t${full_genome_path}
```
e.g.
```
SNG_18	$WORKSPACE/reference/genomes/Abies/Abies_alba_ncDNA.fa
SNG_19	$WORKSPACe/reference/genomes/Larix/Larix_decidua_mtDNA.fasta 
```
Unfortunately, this is not currently automated. Please use this format with caution as it may result in errors and script failures.

### Submitting the mapping script. 
After ensuring you the *.env file has all of the variables set to the desired setting, you can submit the script with the following command:
```bash
sbatch $WORKSPACE/reference/script/mapping_submitter.sh <edited_enviorment_file>.env
```
### Getting Summary data
Submit the Summary script:
```bash
sbatch $WORKSPACE/reference/script/summary.sh <edited_enviorment_file>.env
```
Then run multiqc with the following command: 
```bash
multiqc . --ignore-symlinks --config modifed_eager.yaml --tag ${project_name}_${run} -o ${project_name}_multiqc_${run}
```

# Metagenomics 
This is currently underconstruction 🚧.

### Submitting the metagenomic script. 
After ensuring you the *.env file has all of the variables set to the desired setting, you can submit the script with the following command:
```bash
sbatch $WORKSPACE/reference/script/metagenomics_submitter.sh <edited_enviorment_file>.env
```

# Finishing up

Please delete files that are no longer necessary so that we have enough storage space in the cluster. 

After the scripts have finished running, all __\*.err__ and __\*.out files__ can be deleted immediately. They are mostly important for troubleshooting the script.

```bash 
rm job_pal*
```

Check before you delete the scratch file directory that the files are no longer required. 

```bash 
rm -r temp_files
```



# Troubleshooting

If you need help with the scripts, please email jennifer.zhu@unibe.ch. Otherwise, googling the error code found in the __\*.err__ file is always a good place to start. [You can also start a support ticket with the HPC team](https://hpc-unibe-ch.github.io/support/). 
