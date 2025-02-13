#!/usr/bin/env bash

# directories 
paths_base="/Users/woonjupark/Library/CloudStorage/OneDrive-UW/AMPB"
paths_main="${paths_base}/data/analysis"
paths_local="/Users/woonjupark/Documents/code/ampb"
paths_freesurfer="${paths_base}/data/derivatives/freesurfer"

# load subjects
paths_sublist="${paths_local}/subjects/study2_subjects.txt"
if [ -f "$paths_sublist" ]; then # check if the file exists
    subjects=() # initialize an empty array
    while IFS= read -r line; do # read the file line by line and append each line to the array
        subjects+=("$line")
    done < "$paths_sublist"
fi

# input
subject=${subjects[0]}
hemi_label="L"
label_name="T1T2xMT"

# target id
template="MNI152NLin2009cAsym"

# source label
fname="${paths_main}/${subject}/roi/${subject}_hemi-${hemi_label}_space-fsnative_label-${label_name}_mask.label"

# hemi
fs_hemi=$(echo "$hemi_label" | tr '[:upper:]' '[:lower:]')
fs_hemi="${fs_hemi}h"

# output directory and filename
dname="${template}_${hemi_label}_label-${label_name}" 
paths_save="${paths_local}/mpm/roi/${dname}"
if [[ ! -d "${paths_save}" ]]; then mkdir -p "${paths_save}"; fi
sname="${paths_save}/${subject}_hemi-${hemi_label}_space-mni_label-${label_name}_mask.label"

# fsnative to mni
mri_label2label \
    --sd "${paths_freesurfer}" \
    --srcsubject "${subject}" \
    --srclabel "${fname}" \
    --trgsubject "${template}" \
    --trglabel "${paths_save}/${sname}" \
    --regmethod surface \
    --hemi "${fs_hemi}" 

