#!/bin/bash
declare -x FSLOUTPUTTYPE=NIFTI_GZ

# Base directories
base_dir="/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem"
feat_dir="$base_dir/1st_level"
fmriprep="/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fmriprep"
output_dir="$base_dir/FEAT_MNI_transform"
output_pe="$base_dir/pe_MNI"
task="restCorrected"
pe_num="1 2 3"
session="01"

brain=1  # Enable whole-brain processing
pe=1  # Enable PE image processing

# Loop through all .feat directories inside Feat-1st_level
for feat_folder in "$feat_dir"/*.feat; do
    subj=$(basename "$feat_folder" .feat)  # Extract subject ID
    echo "Processing subject: $subj"

    for task in "restCorrected"; do
        for num in $pe_num; do

            mkdir -p "$output_dir/${subj}/${task}"
            mkdir -p "$output_pe/${subj}/${task}"

            # brainstem processing
            if [ $brain -eq 1 ] ; then
                echo "Converting $subj cope1.nii.gz for whole-brain $task to MNI"
                /usr/pubsw/packages/ANTS/2.3.5/bin/antsApplyTransforms \
                    -i "$feat_folder/stats/cope1.nii.gz" \
                    -r "$fmriprep/${subj}/ses-${session}/func/${subj}_ses-${session}_task-${task}_run-01_space-MNI152NLin2009cAsym_res-1_boldref.nii.gz" \
                    -o "$output_dir/${subj}/${task}/cope1_MNI.nii.gz" \
                    -t "$fmriprep/${subj}/ses-${session}/anat/${subj}_ses-${session}_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5"

                echo "Converting $subj varcope1.nii.gz for whole-brain $task to MNI"
                /usr/pubsw/packages/ANTS/2.3.5/bin/antsApplyTransforms \
                    -i "$feat_folder/stats/varcope1.nii.gz" \
                    -r "$fmriprep/${subj}/ses-${session}/func/${subj}_ses-${session}_task-${task}_run-01_space-MNI152NLin2009cAsym_res-1_boldref.nii.gz" \
                    -o "$output_dir/${subj}/${task}/varcope1_MNI.nii.gz" \
                    -t "$fmriprep/${subj}/ses-${session}/anat/${subj}_ses-${session}_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5"
            fi

            # Processing PE images
            if [ $pe -eq 1 ] ; then
                echo "Converting $subj pe$num.nii.gz for task $task to MNI"
                /usr/pubsw/packages/ANTS/2.3.5/bin/antsApplyTransforms \
                    -i "$feat_folder/stats/pe${num}.nii.gz" \
                    -r "$fmriprep/${subj}/ses-${session}/func/${subj}_ses-${session}_task-${task}_run-01_space-MNI152NLin2009cAsym_res-1_boldref.nii.gz" \
                    -o "$output_pe/${subj}/${task}/pe${num}_MNI.nii.gz" \
                    -t "$fmriprep/${subj}/ses-${session}/anat/${subj}_ses-${session}_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5"
            fi
        done
    done
done
