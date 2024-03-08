%{
Output the mean, max, min and CV of the selected spectrum for each subject

Benjamin Kao
Last update: 2020/12/23
%}

clc;clear;close all;

%% param
subject_name='tc'; % the name of the subject
input_dir='20201209_test_14'; % the measure and calibration folder
calib_dir='calibration_MCML_2'; % the folder of the calibration result
output_dir='extracted_subject_spec_2'; % the folder to save the extracted spectrum
to_use_index=[1:6]; % use these index of the calibrated spectrum

%% init
if exist(output_dir,'dir')==0
    mkdir(output_dir);
end

%% main
save(fullfile(output_dir,[subject_name '_used_index.txt']),'to_use_index','-ascii','-tabs');

spec_arr=[];
for i=1:length(to_use_index)
    temp_spec=load(fullfile(input_dir,calib_dir,[subject_name '_' num2str(to_use_index(i)) '.txt']));
    spec_arr(:,:,i)=temp_spec;
end

mean_spec=mean(spec_arr,3);
max_spec=max(spec_arr,[],3);
min_spec=min(spec_arr,[],3);
std_spec=std(spec_arr,[],3);
CV_spec=std_spec./mean_spec;
CV_spec(:,1)=mean_spec(:,1);

save(fullfile(output_dir,[subject_name '_mean.txt']),'mean_spec','-ascii','-tabs');
save(fullfile(output_dir,[subject_name '_min.txt']),'min_spec','-ascii','-tabs');
save(fullfile(output_dir,[subject_name '_max.txt']),'max_spec','-ascii','-tabs');
save(fullfile(output_dir,[subject_name '_CV.txt']),'CV_spec','-ascii','-tabs');

disp('Done!');