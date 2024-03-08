%{
Plot which shots of BG to use and merge them

Benjamin Kao
Last update: 2020/12/09
%}

clc;clear;close all;

%% param
input_dir='20201209_test_14'; % the folder of the experiment
BG_name='bg';
max_BG_index=100; % the max index of the phantom sould be less than this value, e.g., 'p1_39' is taken, so max_phantom_index sould be larger than 39

%% main

% find which index are there
available_index_arr=[];
for j=1:max_BG_index
    if exist(fullfile(input_dir,['SDS_spec_arr_' BG_name '_' num2str(j) '.mat']),'file')~=0
        available_index_arr(1,end+1)=j;
    end
end
fprintf('The available index for %s are:\n',BG_name);
fprintf('\t%d',available_index_arr);
fprintf('\n');

ph_choose_index=available_index_arr;
phokay=0;

figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none');

while phokay==0
    % load the choosed phantoms
    phantom_spec_arr={};
    for j=1:length(ph_choose_index)
        if sum(find(available_index_arr==ph_choose_index(j)))==0
            warning(['index ' num2str(ph_choose_index(j)) ' is not available']);
            break;
        end
        temp_phantom_spec=load(fullfile(input_dir,['SDS_spec_arr_' BG_name '_' num2str(ph_choose_index(j)) '.mat']));
        for s=1:size(temp_phantom_spec.SDS_spec_arr,2)
            phantom_spec_arr{s}(:,j)=mean(medfilt1(double(temp_phantom_spec.SDS_spec_arr{s})),2);
        end
    end

    % plot the figure
    if length(phantom_spec_arr)~=0
        legend_arr={};
        for j=1:length(ph_choose_index)
            legend_arr{end+1}=num2str(ph_choose_index(j));
        end
        for s=1:length(phantom_spec_arr)
            nexttile(s);
            plot(phantom_spec_arr{s});
            legend(legend_arr,'Location','best');
        end
    end

    fprintf('Please change ''ph_choose_index'' for %s, and set ''phokay=1'' if done.\n',BG_name);
    keyboard();
end

% save
mean_spec=[];
for s=1:length(phantom_spec_arr)
    mean_spec(:,s)=mean(phantom_spec_arr{s},2);
end

save(fullfile(input_dir,['merged_' BG_name '.txt']),'mean_spec','-ascii','-tabs');
save(fullfile(input_dir,['merged_' BG_name '_choosed_index.txt']),'ph_choose_index','-ascii','-tabs');

close all;

disp('Done!');
