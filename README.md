### Introduction

This repository contains a collection of standalone Nextflow scripts that I used to perform specific bioinformatic tasks related to my graduate research.  Creating an entire workflow is not always necessary, so having standalone scripts is convenient when I need to do something specific.  There are also benefits to inspecting the output of a specific analyses prior to piping the output to the next tool, obviating the need to rerun an entire pipeline when something looks strange.

As of now, none of the tools are containerized using Docker or Singularity.  The University prefers not to give graduate students 'sudo' privileges to run containers on the super computer.  Singularity does not require 'sudo' privileges to install, but building from source is not that big of a deal for standalone scripts.  You will need to perform the latter task if you would like to use these scripts, or install the bioinformatics tool using a package manager.  Conda is a popular option for this.

Feel free to use, copy, or modify any of the standalone scripts at your convenience.

### Usage
Each standalone script contains atleast three components: a configuration file (nextflow.config), a configuration template (conf/template.config) and a Nextflow script (main.nf).  To learn more about the available parameters for each script and how to run them, enter the following command into your terminal:
```
$ nextflow run main.nf --help
```
