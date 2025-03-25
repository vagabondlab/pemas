#!/bin/bash

### 1) SETUP ENVIRONMENT
export FREESURFER_HOME=/usr/local/freesurfer/7.4.1
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Point SUBJECTS_DIR and mask_input
export SUBJECTS_DIR=/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/freesurfer
mask_input=/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/freesurfer

# Read subject list from a text file
mapfile -t SUBJECTS < SubjectListfmriprep.txt

# SLURM array index (if you are using array jobs)
subjects=${SUBJECTS[$SLURM_ARRAY_TASK_ID]}

# List of task/bold names
boldlist="restCorrected"

# Optionally change into the SUBJECTS_DIR
cd "$SUBJECTS_DIR" || exit

### 2) LOOP OVER SUBJECT(S) AND BOLDLIST
for subj in "${SUBJECTS[@]}"; do
  for bold in $boldlist; do

    echo "========================================"
    echo "SUBJECT: ${subj}, TASK: ${bold}"
    echo "========================================"

    mkdir /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/brainstem-masks/${subj}
    mkdir /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}
    mkdir /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT_input/brainstem/${subj}/
    mkdir /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT_input/medulla/${subj}/


    ##################################################
    # 1) Convert brainstem mask from mgz to nifti
    ##################################################
    echo "${subj} ${bold} | Converting brainstem mask from mgz to NIFTI..."

    mri_convert \
      "$mask_input/${subj}/mri/brainstemSsLabels.v13.FSvoxelSpace.mgz" \
      "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/brainstem-masks/${subj}/${subj}_ses-01_task-${bold}_brainstem.nii.gz"

    ##################################################
    # 2) Resample the brainstem mask to match BOLD
    ##################################################
    echo "${subj} ${bold} | Resampling brainstem mask..."

    3dresample \
      -input  "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/brainstem-masks/${subj}/${subj}_ses-01_task-${bold}_brainstem.nii.gz" \
      -master "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fmriprep/${subj}/ses-01/func/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold.nii.gz" \
      -prefix "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/brainstem-masks/${subj}/${subj}_ses-01_task-${bold}_brainstem_bin.nii"

    wait

    ##################################################
    # 3) Mask the BOLD image with the resampled brainstem mask
    ##################################################
    echo "${subj} ${bold} | Masking BOLD image with brainstem mask..."

    fslmaths \
      "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fmriprep/${subj}/ses-01/func/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold.nii.gz" \
      -mas "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/brainstem-masks/${subj}/${subj}_ses-01_task-${bold}_brainstem_bin.nii" \
      "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/brainstem-masks/${subj}/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold_bsmasked.nii.gz"

    wait

    ##################################################
    # 4) Convert medulla mask (label 175) from mgz to nifti
    ##################################################
    echo "${subj} ${bold} | Converting medulla mask from mgz to NIFTI..."

    mri_binarize \
      --i "$mask_input/${subj}/mri/brainstemSsLabels.v13.FSvoxelSpace.mgz" \
      --o "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_task-${bold}_medulla.nii.gz" \
      --match 175

    ##################################################
    # 5) Resample the medulla mask to match BOLD
    ##################################################
    echo "${subj} ${bold} | Resampling medulla mask..."

    3dresample \
      -input  "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_task-${bold}_medulla.nii.gz" \
      -master "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fmriprep/${subj}/ses-01/func/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold.nii.gz" \
      -prefix "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_task-${bold}_medulla_bin.nii"

    wait

    ##################################################
    # 6) Mask the BOLD image with the medulla mask
    ##################################################
    echo "${subj} ${bold} | Masking BOLD image with medulla mask..."

    fslmaths \
      "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fmriprep/${subj}/ses-01/func/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold.nii.gz" \
      -mas "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_task-${bold}_medulla_bin.nii" \
      "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold_medulla_masked.nii.gz"

    wait

    ##################################################
    # 7) (Optional) Copy outputs to a different folder
    ##################################################
    # Uncomment and edit paths if you have a specific FEAT input folder:
    #
    echo "${subj} ${bold} | Copying masked outputs to FEAT input folder..."

    cp "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/brainstem-masks/${subj}/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold_bsmasked.nii.gz" "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT_input/brainstem/${subj}/${bold}/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold_bsmasked.nii.gz"  
    cp "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold_medulla_masked.nii.gz" "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT_input/medulla/${subj}/${bold}/${subj}_ses-01_task-${bold}_run-01_space-T1w_desc-preproc_bold_medulla_masked.nii.gz"
    
    wait
    
    ##################################################
    # 8) Create medulla MNI mask
    ##################################################
    echo "${subj} | Creating medulla MNI mask..."

    # Extract medulla mask (label 175) from the brainstem mgz file and save as NIfTI
    mri_binarize \
	  --i "$mask_input/${subj}/mri/brainstemSsLabels.v13.FSvoxelSpace.mgz" \
	  --o "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_medulla.nii.gz" \
	  --match 175
	

    # Apply transformation to bring the medulla mask to MNI space
    antsApplyTransforms \
	  -i "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_ses-01_medulla.nii.gz" \
	  -r "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/codes/templates/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz" \
	  -t "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fmriprep/${subj}/ses-01/anat/${subj}_ses-01_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5" \
	  -o "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_medulla_mni.nii.gz"

    # Binarize the transformed medulla mask in MNI space
    fslmaths \
	  "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_medulla_mni.nii.gz" \
	  -bin "/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/medulla-masks/${subj}/${subj}_medulla_mni_bin.nii.gz"

  done
done

