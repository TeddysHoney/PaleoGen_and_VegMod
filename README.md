# Paleogenetics and Vegetation Modelling

Repository and SOP for the [Paleogenetics and Vegetation Modelling Group](https://www.ips.unibe.ch/research/palgen/index_eng.html) at the University of Bern. All pipelines and scripts are created specificly for this group.

[ResearchGate Link](https://www.researchgate.net/lab/Paleoecology-group-Bern-Willy-Tinner)

## General Information on this Repository

[SOP](SOP) directory houses all relevant instructions for lab work.

All instructions for bioinformatics are found in the [Instructions](Instructions) directory.

All scripts are found in the [Scripts](Scripts) folder. This is the backup for all scripts in case irreversible changes are made to the version found on UBELIX.

Scripts are found in the following folder in our workspace on UBELIX:

```bash
cd $WORKSPACE/references/scripts
```

## New Members
Follow the instructions in the [UBELIX Starter Kit](Instructions/UBELIX_Starter_Kit.md) to create an account on [UBELIX](https://hpc-unibe-ch.github.io/) (UniBe HPC) and access the group's database

### MacOS Users

You can connect to the group server where the majority of the bioinfomatic files are are housed by going to *__Finder>Windows>Connect to Servers__* and then type in the following link:

```
smb://resstore.unibe.ch/ips_pal
```

This can also be done with the shortcut __⌘ K__. It may ask you to give your login infomation to your UniBE Staff account. The username is the string of letters and numbers that identify you on the HPC, which should be found in the account activation email. 

Similarly, you can also connect to the Group's server where the majority of written work is housed:

```
smb://nas-ips.unibe.ch/ips/Groups/Palaeo 
```

You can also connect to your own server:

```
smb://nas-ips.unibe.ch/ips/Users/<Username>
```

>[!warning]
>The Username here is not the same as your email name, this is the HPC username.


## Ancient DNA Pipeline
We have opted to create our own pipeline for aDNA processing.

🚧 *__Our Pipeline is currently under construction.__*

Please follow the [aDNA instructions](Instructions/aDNA_pipeline.md) for our current workflow.
