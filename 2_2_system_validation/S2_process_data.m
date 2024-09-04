%{
Find the start point, normalize, and mean the data.

[save_name '_orig_TPSF.txt']: results of original TPSF after mean.

Ting-Yi Kuo
Last update: 2024/05/01
%}

clc;clear;close all;
%% param
motherfolder='20240612';
folderPath='IRF_530';
folderNames={'IRF1','IRF2'};

first_time_flag=0; % 1:first time processing the data (if you don't know where the starting point is, please set this to 1)
start_point=105;   % if first_time_flag=0, please set the start point you want to use.

for_IRF=1;
do_any_plot=1;


save_name=folderNames{1}(1:3); %IRF or SDS

for f=1:length(folderNames)
    %% init
    folderName=folderNames{f};
    load(fullfile(motherfolder,folderPath,folderName,[folderName '_info_record.mat']));
    load(fullfile(motherfolder,folderPath,folderName,[folderName '_TPSF_collect.mat']));

    total_bins=500; % 500:for 80MHz

    %% main
    %% find start point and end point
    true_flag=0;
    if for_IRF && first_time_flag
        true_flag=1;
    end
    
    while first_time_flag || true_flag
        nexttile;
        TPSF_collect=TPSF_collect(1:total_bins,:);
        plot(TPSF_collect);
        title('Raw data');
        fprintf('Please change ''start_point'' ,set ''first_time_flag=0'' if done.\n');
        keyboard();
        close all;
    end

    time_to_show=6;  % show 6ns data
    end_point=time_to_show/0.025;
    
    TPSF_collect=TPSF_collect(start_point:end,:);
    TPSF_collect=TPSF_collect(1:end_point,:);

    %% Normalized
    for t=1:size(TPSF_collect,2)
        temp_TPSF=TPSF_collect(:,t);
        max_value=max(temp_TPSF);
        norm_TPSF_collect(:,t)=temp_TPSF./max_value;
    end
    
    final_TPSF(:,f)=mean(norm_TPSF_collect,2);
    
    %% Do binning: 20->1
%     total_bins=floor(size(norm_TPSF_collect,1)/20);
%     binning_TPSF=zeros(total_bins,size(norm_TPSF_collect,2));
%     for t=1:size(norm_TPSF_collect,2)
%         for i=1:total_bins
%             binning_TPSF(i,t)=sum(norm_TPSF_collect(1+20*(i-1):20*i,t));
%         end
%     end
%     
%     final_binning_TPSF(:,f)=mean(binning_TPSF,2);
    

    %% Calculate FWHM for IRF
    if for_IRF
        temp_TPSF=final_TPSF(:,f);
        [max_y, max_index]=max(temp_TPSF);
        half_max=max_y/2;
        
        left_index=find(temp_TPSF(1:max_index)<half_max,1,'last');
        right_index=find(temp_TPSF(max_index:end)<half_max,1)+max_index-1;

        FWHM(:,f)=right_index-left_index;
    end
    
    %% Plot 
    if do_any_plot
        figure;
        ti=tiledlayout('flow');
        % original TPSFs
        nexttile;
        to_plot=TPSF_collect;
        semilogy(to_plot);
        xticks(0:40:length(to_plot)); %
        xticklabels(0:0.025*40:0.025*(length(to_plot)+2));
        ylabel('Counts');
        yyaxis right
        plot(100*std(to_plot,[],2)./mean(to_plot,2));
        ylabel('CV (%)');
        xlabel('time(ns)');
        title('Raw data');
        
        % normalized TPSFs
        nexttile;
        to_plot=norm_TPSF_collect;
        semilogy(to_plot);
        xticks(0:40:length(to_plot)); %
        xticklabels(0:0.025*40:0.025*(length(to_plot)+2));
        ylabel('Counts');
        yyaxis right
        plot(100*std(to_plot,[],2)./mean(to_plot,2));
        ylabel('CV (%)');
        xlabel('time(ns)');
        title('Normalized data');

%         % final TPSF
%         nexttile;
%         semilogy(final_TPSF);
%         xticks(0:50:length(final_TPSF));
%         xticklabels(0:0.025*50:0.025*length(final_TPSF));
%         xlabel('time(ns)');
%         ylabel('Counts');

%         % binning TPSF and its CV value for each gate
%         nexttile;
%         semilogy(binning_TPSF);
%         xticks(0:3:length(binning_TPSF));
%         xticklabels(0:0.5*3:0.5*length(binning_TPSF));
%         xlabel('time(ns)');
%         ylabel('Counts');
%         hold on
%         yyaxis right
%         ylabel('CV (%)');
%         CV=100*std(binning_TPSF,[],2)./mean(binning_TPSF,2);
%         plot(CV);
%         xline(10, '--r', 'LineWidth', 2);

%         % final binning TPSF
%         nexttile;
%         semilogy(final_binning_TPSF);
%         xticks(0:3:length(binning_TPSF));
%         xticklabels(0:0.5*3:0.5*length(binning_TPSF));
%         xlabel('time(ns)');
%         ylabel('Counts');

        print(fullfile(motherfolder,folderPath,folderName,[folderName '_TPSF.png']),'-dpng','-r200');
        save(fullfile(motherfolder,folderPath,folderName,[folderName '_norm_TPSF_collect.txt']),'norm_TPSF_collect','-ascii','-tabs')
    end
end


%% Save
save(fullfile(motherfolder,folderPath,[save_name '_orig_TPSF.txt']),'final_TPSF','-ascii','-tabs');
% save(fullfile(folderPath,[save_name '_TPSF.txt']),'final_binning_TPSF','-ascii','-tabs');


% save the IRF data to the phantom folder which use the same intensity to measure
if for_IRF
    folderList=dir(motherfolder);
    isSubFolder=[folderList.isdir];
    subFolders=folderList(isSubFolder);
    subFolderNames={subFolders.name};
    subFolderNames=subFolderNames(~ismember(subFolderNames, {'.', '..',folderPath}));
    for i=1:length(subFolderNames)
        if folderPath(end-2:end)==subFolderNames{i}(end-2:end)
            copyfile(fullfile(motherfolder,folderPath,'IRF_orig_TPSF.txt'),fullfile(motherfolder,subFolderNames{i},'IRF_orig_TPSF.txt'));
        end
    end
end
