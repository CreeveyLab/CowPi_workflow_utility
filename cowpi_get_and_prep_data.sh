#!/usr/bin/bash
cowpi_directory=$(realpath "${1}") # directory for cowpi output results to go

if [ ! -d "${cowpi_directory}" ] # checks if directory is present then produces it
then

    mkdir "${cowpi_directory}"

fi

# links to cowpi files download into array
cowpi_download_array=("https://zenodo.org/record/1252858/files/CowPi_V1.0_16S_precalculated.tab.gz?download=1" 
"https://zenodo.org/record/1252858/files/CowPi_V1.0_all_rumen_16S_combined.renamed.fas.gz?download=1"
"https://zenodo.org/record/1252858/files/CowPi_V1.0_ko_precalc1.tab.gz?download=1")

for download in "${cowpi_download_array[@]}" # loops over link array, downloads them, gives nice name and decompresses
do
    download_name=$(echo "${download}" | awk -F'/' '{print $NF}' | sed 's/?download=1//')
    download_path="${cowpi_directory}/${download_name}"

    gunzipped_download_name=$(echo "${download_name}" | sed 's/.gz$//')

    if [ -f "${gunzipped_download_name}" ]; then
        echo "File ${gunzipped_download_name} already exists."
    else
        wget "${download}" -O "${download_path}"
        gunzip "${download_path}"
    fi

done

if [ ! -f "${cowpi_directory}/CowPi_V1.0_all_rumen_16S_combined.fas" ]; then
cat "${cowpi_directory}/CowPi_V1.0_all_rumen_16S_combined.renamed.fas" | sed 's/-//g' > "${cowpi_directory}/CowPi_V1.0_all_rumen_16S_combined.fas" # removing the "-" to allow vsearch to work
fi

# Define the arrays
yaml_configs_array=("copy_number_table_file: ${cowpi_directory}/CowPi_V1.0_16S_precalculated.tab" "ko_table: ${cowpi_directory}/CowPi_V1.0_ko_precalc1.tab" 
"16s_sequence_table: ${cowpi_directory}/CowPi_V1.0_all_rumen_16S_combined.fas" "single_or_multiple_datasets:" "directory_of_datasets:" "threads:" "remove_chimeras:" "pre_clustered:")

yaml_pre_clust_configs_array=("copy_number_table_file: ${cowpi_directory}/CowPi_V1.0_16S_precalculated.tab" "ko_table: ${cowpi_directory}/CowPi_V1.0_ko_precalc1.tab" 
"16s_sequence_table: ${cowpi_directory}/CowPi_V1.0_all_rumen_16S_combined.fas" "single_or_multiple_datasets:" "directory_of_datasets:" "threads:" "remove_chimeras:" "pre_clustered: true" 
"pre_clustered_files:" "  fastq_cluster_file_path:" "  cluster_table_path:")

# Define the output file names
yaml_config_output_file_1="${cowpi_directory}/raw-data.yml"
yaml_config_output_file_2="${cowpi_directory}/preclustered-data.yml"

# Write the first array to the first output file
for config in "${yaml_configs_array[@]}"
do
    echo "${config}" >> "${yaml_config_output_file_1}"
done

# Write the second array to the second output file
for config in "${yaml_pre_clust_configs_array[@]}"
do
    echo "${config}" >> "${yaml_config_output_file_2}"
done


if [ -f "${cowpi_directory}/CowPi_V1.0_all_rumen_16S_combined.renamed.fas" ]; then
rm "${cowpi_directory}/CowPi_V1.0_all_rumen_16S_combined.renamed.fas"
fi
