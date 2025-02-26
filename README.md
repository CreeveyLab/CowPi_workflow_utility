# CowPi WorkFlow Utility

## To install:

Tool used to aid the use of the CowPi tool for analysing 16S data. Run in Python 2.

This can be run on  a single dataset or multiple independent datasets (completely separate datasets, only thing that is together is production of a summary file of the stages).


To create conda environment to run this tool:
```
conda create -n cowpi_workflow picrust=1.1.4 biom-format=2.1.7 vsearch=2.18.0 pyyaml=5.2 pandas=0.24.2 python=2.7.18
```

**Please note:** Sometimes this command may have issues with `conda forge`, removing the conda forge channel whilst producing this environment should fix this.

---

## DATA

You can get this workflow to analyse data from a **single** study or **multiple** studies which is **pre-clustered** or **unclustered i.e. raw sequence data**.

### Unclustered Data (raw fastq files)

#### Analysis of a single study

  * Create a data folder
  * Put all the fastq files in the folder

#### Analysis of multiple studies

  * Create a data folder
  * In the data folder, create a folder for the data associated with each study
  * Put the data in the associated stuy folders

### Pre-clustered Data (OTU/ASV Table and Representative sequences)

#### Analysis of a single study

  * ...
  * ...

#### Analysis of multiple studies

  * ...
  * ...


---

## Contents

Contains following scripts:

**1. `cowpi_get_and_prep_data.sh`**

run the command like this:

 `./cowpi_get_and_prep_data.sh {YAML FILE NAME} {PATH TO PUT DATABASES} {IS DATA PRECLUSTERED? (Y/N)}`

Where:

`{YAML FILE NAME}` is the name of the yaml file to be created with the location of the databases and options for analysis
`{PATH TO PUT DATABASES}` is the the name of the folder to create where cowpi data from the Zenodo database will be downloaded
`{IS DATA PRECLUSTERED? (Y/N)}` is an indication `Y` or `N` as to whether the analyses will be run from raw fastq reads or from preclustered data (from QIIME for instance)


So for example:

```
./cowpi_get_and_prep_data.sh mydata_info.yml ./databases N
```


**2. `filter_archaea.py` (optional)**

This python script filters archaea from the initial cowpi data files. This optional step can be used if you do not expect archaea data (i.e. used bacterial-specific primers).

Argument one: archaea file list (see 'archaea_file.txt') path
Argument Two: The initial CowPi precalculated files directory (produced above)

**3. `cowpi_main_workflow.py`**

This is the main workflow python script. Takes the yaml configuration file as the first argument, then runs each step of the CowPi workflow and generates functional pathway results, as well as producing a summary file of each step. 

Argument one: yaml configuration file

`./cowpi_main_workflow.py {YAML FILE}`

where:

`{YAML FILE}` is the file created using the `cowpi_get_and_prep_data.sh` script.

Example: `./cowpi_main_workflow.py mydata_info.yml`

***4. `conversion_of_read_names.py` (optional)***

Depending on headers of fasta sequence file, this can result in problems in output from `vsearch` stage of cowpi. This adds the file name into the headers and checks for any "."s in file sample name which can cause issues.

Usage:

`./conversion_of_read_names.py {PATH TO ANALYSIS DATA FOLDER} {PATH TO NEW DATA FOLDER} {single/multiple}`

Where:

`{PATH TO ANALYSIS DATA FOLDER}` is the path to where your data for analysis is located
`{PATH TO NEW DATA FOLDER}` is the path to the new directory to be created following cleaning
`{single/multiple}` indicates whether you an analysing data from a single study or multiple studies

Example: `./conversion_of_read_names.py ./data ./data_cleaned/ single`

---

## Process:

1. Run `cowpi_get_and_prep_data.sh`. 

This will download and prepare the cowpi precalculated data, as well as produce a yaml file with the paths to the cowpi precalculateds. 



2. Run `conversion_of_read_names.py`. 

This is probably optional depending on the name of fastq sequence headers. This is only for data not preclustered at the moment. 
 

3. Fill in configurations of the yaml file. 

If running on a single dataset, point the directory_of_datasets path to the directory containing that dataset. 

If multiple, then directory containing sub directories of that datasets.

Example yaml file contents:

```
copy_number_table_file: ./databases/CowPi_V1.0_16S_precalculated.tab
ko_table: ./databases/CowPi_V1.0_ko_precalc1.tab
16s_sequence_table: ./databases/CowPi_V1.0_all_rumen_16S_combined.fas
single_or_multiple_datasets: "single"
directory_of_datasets: ./data_cleaned
threads: 4
remove_chimeras: false
pre_clustered: false

```


4. Run `cowpi_main_workflow.py` with the argument pointing to the yaml file.

---

## Outputs

Important Outputs (in each dataset directory)
1. `summary_output_file.txt` - gives various information about results of each stage.
2. `categoried_predictions` - directory containing collapsed pathways at each kegg ortholog.
3. `metagenome_predictions/metagenome_predictions.tsv` - tabulated file containing counts of each KEGG ortholog.


If multiple datasets option chosen, `all_datasets_summary_file.csv` file is also produced. 
This takes the summary output file from each dataset analysis and puts into a simpler table.



