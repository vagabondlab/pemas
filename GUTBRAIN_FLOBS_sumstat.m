clearvars

% Define the full path to the folder containing design.mat and PE files
data_folder = '/autofs/cluster/vagabond/USERS/MARIO/Projects/7T/sourcedata/derivatives/fsl-regressed/FEAT/brainstem/pe_MNI/sub-7T1813CI071624/restCorrected';

try
    % Display processing info
    disp('')
    disp(['Processing folder: ' data_folder]);
    disp('')
    
    % Load design matrix
    design_path = fullfile(data_folder, 'design.mat');
    fileID = fopen(design_path, 'r');
    matrix = textscan(fileID, '%f\t%f\t%f\t\n', 'HeaderLines', 5);
    fclose(fileID);
    a1 = rms(matrix{1,1})^2;  
    a2 = rms(matrix{1,2})^2;  
    a3 = rms(matrix{1,3})^2;
    
    % Load PEs images from the same folder
    img1 = load_nifti(fullfile(data_folder, 'pe1_MNI.nii.gz'));    pe1 = img1.vol;
    img2 = load_nifti(fullfile(data_folder, 'pe2_MNI.nii.gz'));    pe2 = img2.vol;
    img3 = load_nifti(fullfile(data_folder, 'pe3_MNI.nii.gz'));    pe3 = img3.vol;
    
    % Calculate summary statistic
    summary = zeros(size(pe1));
    for i = 1:size(pe1,1)
        for j = 1:size(pe1,2)
            for z = 1:size(pe1,3)
                summary(i,j,z) = sign(pe1(i,j,z)) * sqrt(a1 * pe1(i,j,z)^2 + ...
                    a2 * pe2(i,j,z)^2 + a3 * pe3(i,j,z)^2);
            end
        end
    end
    
    % Save result in the same folder
    new = img1;
    new.vol = summary;
    err = save_nifti(new, fullfile(data_folder, 'summary.nii.gz'));
    
catch exception
    disp('')
    disp(['Error processing folder: ' data_folder]);
    disp(['Error: ' exception.message]);
    disp('')
end
