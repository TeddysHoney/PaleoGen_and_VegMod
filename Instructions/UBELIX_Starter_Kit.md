# UBELIX Starter Kit (MacOS)

Simplified set up of UBELIX in Terminal for Mac users. 

Window Version is in development.



## Set up 


Please sent a request to the IT department to open an account: [https://serviceportal.unibe.ch/hpc](https://serviceportal.unibe.ch/hpc). 

>[!important]
>__Title of Request__: HPC Account activation 
>
> In the description, request access to the ips_pal workspace

An email will be sent with your account information. Follow the instructions on [this page](https://hpc-unibe-ch.github.io/firststeps/loggingin/).

## SSH Setup 

This is completed on your computer to set up a short cut to log in to UBELIX.
Follow the [this page](https://hpc-unibe-ch.github.io/firststeps/SSH-keys/) for the complete instructions. The following details and helpfull tips.

To find the '.ssh' file type the following into the command line, which will show all hidden files. 

```bash
ls -a
```

To navigate to the file, type in the following, do not keep the '<>': 

```bash
cd <filename>
```

If a config file does not exist in the __'.ssh'__, you can make and edit one with the following code:

```bash
nano ~/.ssh/config
```

Then you can copy and paste the __Host configuration__. Please note that the user name is found in the __HPC Account Activation__ email. Navigation in `nano`is also done with the __arrow keys__, and not the mouse. 


>[!tip]
>There are multiple commands for editing files in bash. I just like using 'nano'.


To save changes, follow the directions along the bottom edge of the screen. 


>[!note] 
> I set up individual Host config for each of the four login nodes (labeled *__ubelix0X__*) and I did not set up a SSH agent. 

### Alias

You can also set up alias so you have a short cut to call the __'ssh'__ command. To do this you have to note if you are in *bash* or *zsh* (for Mac users). Look at the top of your terminal to see if you are in bash or zsh. 

#### BASH
If in *__bash__*:

```bash
nano .bash_profile
```

Add the following line to the end of the file:

```bash
source ~/.custom_commands.sh
```

Edit the file

```bash
nano .custom_commands.sh
```
And add the relevant command: 

```bash
#!./bin/bash
alias ubelix01='ssh ubelix01'
```
#### ZSH

If in *__zsh__*:
```zsh
nano .zshrc
```

Then enter the following:
```zsh
alias ubelix01='ssh ubelix01'
```

You can can create individual alias for each of the login nodes by adding the following code to the file you have open.

```bash
alias ubelix02='ssh ubelix02'
alias ubelix03='ssh ubelix03'
alias ubelix04='ssh ubelix04'
```

## Workspace

To access the group work space, you have to load the __Workspace__ module. 

```bash
module load Workspace
```

Then you will be prompted to load one of two workspaces, choose the first one. 

```bash
HPC_WORKSPACE=ips_pal module load Workspace
```

Following which you will have to navigate to the Workspace to access the files

```bash
cd $WORKSPACE
```

To access your own storage:

```bash
cd $HOME
```

Again, you can set up alias to create short cuts so you don't have to type every thing out. To do this run the [pal_config.sh](../Scripts/pal_config.sh) file.

```bash
sbatch pal_config.sh
```

This will set up the following shortcuts: 
```bash
#shortcuts 
alias ll='ls -a'
alias home='cd $HOME'
alias workspace='cd $WORKSPACE'
alias load='module load Workspace'
alias ips='HPC_WORKSPACE=ips_pal module load Workspace'
alias queue='squeue --me'
```
It will also setup some other configurations, which are not relevant for now. Please read the script for more information.

Tada, you're all set. 
