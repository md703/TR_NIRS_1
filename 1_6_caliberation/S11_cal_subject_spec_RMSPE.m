%{
Calculate the spectrum RMSPE of each subject

Benjamin Kao
Last update: 2021/03/24
%}

clc;clear;close all;

%% param
subject_name='tc'; % the name of the subject
input_dir='20201209_test_14'; % the measure and calibration folder
calib_dir='calibration_MCML_2'; % the folder of the calibration result
output_dir='extracted_subject_spec_2'; % the folder to save the extracted spectrum

%% init
to_use_index=load(fullfile(output_dir,[subject_name '_used_index.txt'])); % use these index of the calibrated spectrum

%% main

spec_arr=[];
for i=1:length(to_use_index)
    temp_spec=load(fullfile(input_dir,calib_dir,[subject_name '_' num2str(to_use_index(i)) '.txt']));
    spec_arr(:,:,i)=temp_spec;
end

mean_spec=mean(spec_arr,3);
spec_error_arr=(spec_arr-mean_spec)./mean_spec;
spec_rmspe=sqrt(mean(spec_error_arr.^2,3));
spec_rmspe(:,1)=mean_spec(:,1);
SDS_rmspe=sqrt(mean(spec_rmspe(:,2:end).^2,1));


save(fullfile(output_dir,[subject_name '_rmspe.txt']),'spec_rmspe','-ascii','-tabs');
save(fullfile(output_dir,[subject_name '_SDS_rmspe.txt']),'SDS_rmspe','-ascii','-tabs');

disp('Done!');