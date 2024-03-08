%{
Reorganizing and preprocessing the data (including finding the zero points and binning the TPSF)

Ting-Yi Kuo
Last update: 2024/03/08
%}

%% param
input_dir='20240306';

num_phantom=6;
num_SDS=5;
repeat_times=5; % how many times of measurements each phantom and SDS

time_bin_resolution_sim=0.5; % unit:ns

%% init
load(fullfile(input_dir,'TPSF_collect.mat'));   % TPSF_collect
load(fullfile(input_dir,'info_record.mat'));    % info_record
fileNames=info_record.Properties.RowNames;
num_bins=info_record{1,2};

time_bin_resolution=info_record{1,1}*1E9;   % s->ns
if time_bin_resolution_sim>=time_bin_resolution
    num_binning=time_bin_resolution_sim/time_bin_resolution;    % how many values to bin once
else
    error('Resolution of simulation can not be smaller than hardware resolution!');
end

%% main
% background
bg=[];
for s=1:num_SDS
    for t=1:repeat_times
        fid=find(fileNames==['bg_SDS' num2str(s) '_' num2str(t) '.phu']);
        temp_bg(:,t)=TPSF_collect(:,fid);
    end
    bg(:,s)=mean(temp_bg,2);
end

% IRF: IRF-bg -> find zero points
IRF=[];
for s=1:num_SDS
    for t=1:repeat_times
        fid=find(fileNames==['IRF_SDS' num2str(s) '_' num2str(t) '.phu']);
        temp_IRF(:,t)=TPSF_collect(:,fid);
        temp_IRF(:,t)=temp_IRF(:,t)-bg(:,s);    % substract the background
    end
    IRF(:,s)=mean(temp_IRF,2);
    
    non_zero_points=find(floor(IRF(:,s))~=0);
    zero_points(:,s)=min(non_zero_points);
end

% phantom data
TPSF_orig=[];
TPSF_binning=[];

for p=1:num_phantom
    for s=1:num_SDS
        for t=1:repeat_times
            fid=find(fileNames==['p' num2str(p) '_SDS' num2str(s) '_' num2str(t) '.phu']);
            temp_TPSF=TPSF_collect(:,fid);
            TPSF_orig{p,s}(:,t)=temp_TPSF;
            
            temp_TPSF=temp_TPSF-bg(:,s);                  % substract bg
            temp_TPSF=temp_TPSF(zero_points(:,s):end);    % start from zero points
            for i=1:floor(num_bins/num_binning)           % binning
                TPSF_binning{p,s}(i,t)=sum(temp_TPSF(1+num_binning*(i-1):num_binning*i));
            end
        end
    end
end

save(fullfile(input_dir,'processed_data.mat'),'bg','IRF','TPSF_orig','TPSF_binning');

