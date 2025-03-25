input=/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/1st_level/pe_MNI
output=/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/2nd_level/all_copes
subjects="sub-7T0111CI110124 sub-7T0111LC031523 sub-7T0407CI110824 sub-7T1813CI071624 sub-FM004 sub-FM006 sub-FM007 sub-FM008 sub-FM009 sub-FM010 sub-FM013 sub-FM018"
tasks="ContinuousStimCorrected"

source ~/.bash_profile

for subj in $subjects; do
	for task in $tasks; do
		#1. create the difference between the summaries within a subject (rest-each task) using fslmaths -sub function
		#fslmaths /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/1st_level/pe_MNI/"${subj}"/"${task}"/summary.nii.gz -sub /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/1st_level/pe_MNI/"${subj}"/restCorrected/summary.nii.gz /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/2nd_level/all_copes/cope1_sub-"${subj}"_"${task}"-rest_diff_summary.nii.gz
	
		#2. concatenate each task together over time to create one image

		#fslmerge -t /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/2nd_level/all_copes/cope1_"${task}"-rest_diff_summary_concat.nii.gz /autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/2nd_level/all_copes/cope1*_"${task}"-rest_diff_summary.nii.gz

		#3. randomise for 2nd level 
		
		#cd /autofs/space/ponyo_001/users/liz/GUTBRAIN_FreqMod/FEAT/brainstem/Feat-2nd_level/all_copes
		
		randomise -i cope1_"${task}"-rest_diff_summary_concat.nii.gz -o ../"${task}"-rest/"${task}"-rest -m ../all_medulla_mni_bin.nii.gz -1 -T -n 5000

	done
done

