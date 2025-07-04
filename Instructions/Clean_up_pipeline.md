# Clean Up Pipeline

## Introduction 

This is the initial pipeline used clean genomic data following sequencing. Scripts for this are found here:

```bash 
cd $WORKSPACE/HOLOGENE/scripts
```

>[!caution]
>Always create a new file. __DO NOT__ edit the original script files.
>This can be done with the following commands: 
>
>```bash 
> cd $WORKSPACE/HOLOGENE/scripts
> ```
> ```bash
> cp <script_name> <directory_where_you_are_running_the_script>
> ```
>

Always change the name of the job_name and the email address at the beginning of the script before submitting the job.

```bash
#SBATCH --job-name="Change_this_name"
#SBATCH --mail-user=<name>@unibe.ch
```

Scripts can be submitted and run on the UBELIX with the following command 
```bash 
sbatch <script_name>.sh
```




## Clean up 

Script:  [clean_up_pipeline_final.sh]

This script will remove the primers and duplicates from the raw reads, thereby "cleaning"  it for alignment to a reference genome.

Check list before running the code:

- [ ] define ${working_path}. *This is defined as the directory you are running the script in.*
	- This is the first variable you will encounter in the script
- [ ] created a document with links to the samples being processed, preferably named __link.txt__

The above variables should all be found at the start of the script. Unless absolutely necessary __DO NOT__ change the script. 

>[!important]
> - Link to download samples can be found [here](https://lims.bioinformatics.unibe.ch/account/logout).
> - Each link should be on a separate line in the .txt file (i.e delimiter is \n). 
> - Maximum of sample is currently set to *__8__*. At the moment, the max number of samples is untested.

If multiple iterations of the script is run in parallel, the __job_name__ and the __sample_name.txt__ on line 54 should be changed. 

```bash 
touch <sample_name.txt> # this may need to be changed 
```

>[!warning] 
>Do not delete ` sample_name.txt`. This is needed for the subsequent script to map the samples to the reference genome(s).


# Mapping

Script: [mapping_script.sh]

This is run in the same directory as the [clean_up_pipeline_final.sh] script. 

Check list before running the code:
- [ ] define ${working_path}. *This is defined as the directory you are running the script in.*
	- This is the first variable you will encounter in the script
- [ ] create a .txt file that lists the reference genomes, preferably named __genome_name.txt__,  as listed by the following commands: ***(copy exactly as seen)***
	```bash 
		cd $WORKSPACE/HOLOGENE/genomes 
	```
  ```bash
  ls *.{fasta,fa,fna}
  ```
  
The directories should be set to the same values as is utilized in __clean_up_pipeline_final.sh__. 

>[!caution]
>Check to make sure that the reference genome is actually indexed. If it is indexed, there should be a __\*.amb, \*.ann, \*.bwt, \*.fai, \*.pac, \*.sa and file__ of the genome in the `$WORKSPACE/HOLOGENE/genomes` directory.
>
>If these files don't exist run the [genome_indexing.sh] script found in the script folder. This script can be run directly in the script directory
>```bash
>sbatch $WORKSPACE/HOLOGENE/scripts/genome_indexing.sh
>```
>
>Please remember to delete all __\*.err__ and __\*.out files__ after running this script.
>
>```bash
>rm job_pal*
>```


# Finishing up

Please delete files that are no longer necessary so that we have enough storage space in the cluster. 

After the scripts have finished running, all __\*.err__ and __\*.out files__ can be deleted immediately. They are mostly important for troubleshooting the script.

```bash 
rm job_pal*
```

Check before you delete the scratch file directory that the files are no longer required. 

```bash 
rm -r $SCRATCH_PATH
```

All duplicated scripts can also be deleted if you are done with it as an original version can be found in the *script* directory (hopefully). Although for your reference, it is recommended to keep it until the project is finished

```bash 
rm *.sh 
```



# Troubleshooting

If you need help with the scripts, please email jennifer.zhu@unibe.ch. Otherwise, googling the error code found in the __\*.err__ file is always a good place to start. [You can also start a support ticket with the HPC team](https://hpc-unibe-ch.github.io/support/). 

The directories should be set to the same values as is utilized in __clean_up_pipeline_final.sh__. 

>[!important]
>Check to make sure that the reference genome is actually indexed. If it is indexed, there should be a __\*.amb, \*.ann, \*.bwt, \*.fai, \*.pac, \*.sa and file__ of the genome in the `$WORKSPACE/HOLOGENE/genomes` directory.
>
>If these files don't exist run the genome_indexing.sh script found in the script folder. This script can be run directly in the script directory
>```bash
>sbatch $WORKSPACE/HOLOGENE/scripts/genome_indexing.sh
>```
>
>Please remember to delete all __\*.err__ and __\*.out files__ after running this script.
>
>```bash
>rm job_pal*
>```
