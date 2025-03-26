randomise -i cope1_ContinuousStimCorrected-rest_diff_summary_concat.nii.gz \
          -o GroupComparison_DiseasevsControl \
          -d design.mat \
          -t design.con \
          -m all_medulla_mni_bin.nii.gz \
          -n 5000 \
          -T
