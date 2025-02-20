#!/usr/bin/env bash

# Directories
paths_base="/Volumes/T7/AMPB"
paths_main="${paths_base}/analysis"
paths_local="${paths_base}/code"  # Adjust if needed
paths_freesurfer="/Applications/freesurfer/7.4.1/subjects"

# Load subject list from a file
paths_sublist="${paths_base}/subjects/EB_subjects.txt"

# Check if the subject list file exists
if [ ! -f "$paths_sublist" ]; then
    echo "Subject list file not found: $paths_sublist"
    exit 1
fi

# Define parameters
hemi_label="L"  # Change to "R" for right hemisphere
label_name="PT"  # Label name
template="MNI152NLin2009cAsym"

# Define the source label file in MNI space
# mni_label_dir="${paths_local}/mpm/roi/${template}_${hemi_label}_label-${label_name}/averaged_${label_name}_mask.label"
mni_label_file="/Volumes/T7/AMPB/code/mpm/roi/MNI152NLin2009cAsym_L_label-PT/averaged_PT_mask.label"
# Check if the MNI label file exists
if [ ! -f "$mni_label_file" ]; then
    echo "MNI label file not found: $mni_label_file"
    exit 1
fi

# Read subjects from file line by line
while read subject; do
    echo "Processing subject: $subject"
    
    # Convert hemisphere label to FreeSurfer format
    fs_hemi=$(echo "$hemi_label" | tr '[:upper:]' '[:lower:]')h  # "L" -> "lh", "R" -> "rh"
    
    # Define output filename in subject's fsnative space
    subject_label_file="${paths_local}/mpm/roi/${template}_${hemi_label}_label-${label_name}/${subject}_hemi-${hemi_label}_mni-space_label-${label_name}_mask.label"

    # Convert MNI-space label to subject-specific space
    mri_label2label \
        --sd "${paths_freesurfer}" \
        --srcsubject "${template}" \
        --srclabel "${mni_label_file}" \
        --trgsubject "${subject}" \
        --trglabel "${subject_label_file}" \
        --regmethod surface \
        --hemi "${fs_hemi}"

    # Check if the command executed successfully
    if [ $? -eq 0 ]; then
        echo "✅ Successfully converted MNI label to subject ${subject}'s surface."
    else
        echo "❌ Error converting label for subject ${subject}."
    fi
    
    echo "Finished processing subject: $subject"
    echo "----------------------------------------"

done < "$paths_sublist"

echo "🎯 All subjects processed successfully."
