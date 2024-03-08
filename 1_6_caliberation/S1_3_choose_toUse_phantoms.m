%{
Plot which shots of a phantom to use and merge them

Benjamin Kao
Last update: 2020/12/08
%}

clc;clear;close all;

%% param
input_dir='20201209_test_14'; % the folder of the experiment
output_folder='extracted_spec'; % the folder of the extracted spectrum
to_choose_phantom_name={'p1','p2','p3','p4','p5','p6'}; % the name of the phantoms
max_phantom_index=100; % the max index of the phantom sould be less than this value, e.g., 'p1_39' is taken, so max_phantom_index sould be larger than 39

%% main
for i=1:length(to_choose_phantom_name)
    % find which index are there
    available_index_arr=[];
    for j=1:max_phantom_index
        if exist(fullfile(input_dir,output_folder,[to_choose_phantom_name{i} '_' num2str(j) '.txt']),'file')~=0
            available_index_arr(1,end+1)=j;
        end
    end
    fprintf('The available index for phantom %s are:\n',to_choose_phantom_name{i});
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
            temp_phantom_spec=load(fullfile(input_dir,output_folder,[to_choose_phantom_name{i} '_' num2str(ph_choose_index(j)) '.txt']));
            for s=1:(size(temp_phantom_spec,2)-1)
                phantom_spec_arr{s}(:,j)=temp_phantom_spec(:,s+1);
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
                plot(temp_phantom_spec(:,1),phantom_spec_arr{s});
                legend(legend_arr,'Location','best');
            end
        end
        
        fprintf('Please change ''ph_choose_index'' for phantom %d, and set ''phokay=1'' if done.\n',i);
        keyboard();
    end
    
    % save
    mean_spec=temp_phantom_spec(:,1);
    for s=1:length(phantom_spec_arr)
        mean_spec(:,s+1)=mean(phantom_spec_arr{s},2);
    end
    
    save(fullfile(input_dir,output_folder,['phantom_' to_choose_phantom_name{i} '.txt']),'mean_spec','-ascii','-tabs');
    save(fullfile(input_dir,output_folder,['phantom_' to_choose_phantom_name{i} '_choosed_index.txt']),'ph_choose_index','-ascii','-tabs');
    
    close all;
end

disp('Done!');
