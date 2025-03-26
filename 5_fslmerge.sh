input=/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/1st_level/pe_MNI
output=/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/2nd_level/all_copes
subjects="sub-7T0111CI110124 sub-7T0111LC031523 sub-7T0407CI110824 sub-7T1813CI071624 sub-FM004 sub-FM006 sub-FM007 sub-FM008 sub-FM009 sub-FM010 sub-FM013 sub-FM018"
tasks="ContinuousStimCorrected"

source ~/.bash_profile

for subj in $subjects; do
	for task in $tasks; do

		#2. concatenate each task together over time to create one image

		fslmerge -t /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/2nd_level/all_copes/cope1_"${task}"-rest_diff_summary_concat.nii.gz /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/2nd_level/all_copes/cope1*_"${task}"-rest_diff_summary.nii.gz


	done
done

