
clear all;

phantom=3;
min=3;
max_counts=70430;
CV=0.92;

input_dir='./MCML_sim_lkt_2/cal_reflectance_2';
phantom=1:6;

for i=phantom
    TPSF=load(fullfile(input_dir,['phantom_' num2str(i) '_TPSF.txt']));
    peak_counts(i,:)=max(TPSF);
end


load('head_TPSF.mat');
peak_counts(end+1,:)=max(head_TPSF);

time_to_spend=peak_counts(3,1)./peak_counts.*min; % to achievce same CV
acquire_CV=sqrt(peak_counts(3,1)./peak_counts).*CV; % to use same acquisition time



