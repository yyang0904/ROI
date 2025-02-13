#!/usr/bin/env bash

# Directories
paths_base="/Volumes/T7/AMPB"
paths_main="${paths_base}/analysis"
paths_local="${paths_base}/code"  # Adjust if needed
paths_freesurfer="/Applications/freesurfer/7.4.1/subjects"

# Load subject list from a file
paths_sublist="${paths_base}/subjects/mt_subjects.txt"

# Check if the subject list file exists
if [ ! -f "$paths_sublist" ]; then
    echo "Subject list file not found: $paths_sublist"
    exit 1
fi

# Define parameters
hemi_label="R"  # Change to "R" for right hemisphere
label_name="PT"  # Label name for the MT area
template="MNI152NLin2009cAsym"

# Read subjects from mt_subjects.txt line by line
while read subject; do
    echo "Processing subject: $subject"
    
    # Define input label file path (fsnative space)
    fname="${paths_main}/${subject}/roi/${subject}_hemi-${hemi_label}_space-fsnative_label-${label_name}_mask.label"

    # Convert hemisphere label to FreeSurfer format
    fs_hemi=$(echo "$hemi_label" | tr '[:upper:]' '[:lower:]')h  # "L" -> "lh", "R" -> "rh"

    # Define output directory and filename
    dname="${template}_${hemi_label}_label-${label_name}" 
    paths_save="${paths_local}/mpm/roi/${dname}"

    # Create output directory if it does not exist
    if [[ ! -d "${paths_save}" ]]; then 
        mkdir -p "${paths_save}"
    fi

    # Define output filename (MNI space)
    sname="${paths_save}/${subject}_hemi-${hemi_label}_space-mni_label-${label_name}_mask.label"

    # Check if source label file exists before proceeding
    if [ -f "$fname" ]; then
        echo "Source label file found: $fname"
        echo "Target label file: $sname"

        # Convert fsnative to MNI space using FreeSurfer
        mri_label2label \
            --sd "${paths_freesurfer}" \
            --srcsubject "${subject}" \
            --srclabel "${fname}" \
            --trgsubject "${template}" \
            --trglabel "${sname}" \
            --regmethod surface \
            --hemi "${fs_hemi}"

        # Check if the command executed successfully
        if [ $? -eq 0 ]; then
            echo "mri_label2label completed successfully for subject ${subject}."
        else
            echo "Error running mri_label2label for subject ${subject}."
        fi
    else
        echo "Source label file not found: $fname"
    fi
    
    echo "Finished processing subject: $subject"
    echo "----------------------------------------"

done < mt_subjects.txt

echo "All subjects processed successfully."
