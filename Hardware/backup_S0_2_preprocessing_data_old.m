%{
Evaluate the stability and preprocess the data of phantoms or targets

Ting-Yi Kuo
Last update: 2024/03/11
%}

clc;clear;close all;

%% param
input_dir='IRF';

num_phantom=2;
target_prefix={};
num_SDS=2;
repeat_times=2; % how many times of measurements each phantom and SDS
SDS_dist_arr=[1.5 2.2 2.9 3.6 4.3]; % cm

time_bin_resolution_sim=0.5; % unit:ns

lineWidth=2;
lgdFontSize=12;
lgdNumCol=6;

%% init
load(fullfile(input_dir,'info_record.mat'));    % info_record
% fileNames=info_record.Properties.RowNames;
num_bins=info_record{1,2};

time_bin_resolution=info_record{1,1}*1E9;   % s->ns
if time_bin_resolution_sim>=time_bin_resolution
    num_binning=time_bin_resolution_sim/time_bin_resolution;    % how many values to bin once
else
    error('Resolution of simulation can not be smaller than hardware resolution!');
end

color_arr=jet(repeat_times);
legend_arr={};
for i=1:repeat_times
    legend_arr{i}=num2str(i);
    i=i+1;
end
legend_arr{end+1}='CV';

%% main
load(fullfile(input_dir,'sys_TPSF_collect.mat'));
% background
figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none');

for s=1:num_SDS
    bg_mean(:,s)=mean(bg{s},2);
    bg_cv(:,s)=std(bg{s},[],2)./bg_mean(:,s);
    
    nexttile;
    hold on
    for t=1:repeat_times
        plot(bg{s}(:,t),'Color',color_arr(t,:),'LineWidth',lineWidth);
        hold on
    end
    xlabel('# of bins');
    ylabel('counts');
    set(gca,'YScale','log'); 
    yyaxis right
    plot(100*bg_cv(:,s))
    title(['SDS ' num2str(SDS_dist_arr(s)) ' cm']);
    ylabel('CV (%)');
    
    lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
    lgd.NumColumns = lgdNumCol;
end
title(ti,'Background');
print(fullfile(input_dir,'stability_background.png'),'-dpng','-r300');


% IRF
figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none');

for s=1:num_SDS
    IRF_mean(:,s)=mean(IRF{s},2);
    IRF_cv(:,s)=std(IRF{s},[],2)./IRF_mean(:,s);
    
    non_zero_points=find(floor(IRF_mean(:,s))~=0);
    zero_points(:,s)=min(non_zero_points);
    
    nexttile;
    hold on
    for t=1:repeat_times
        plot(IRF{s}(:,t),'Color',color_arr(t,:),'LineWidth',lineWidth);
        hold on
    end
    xlabel('# of bins');
    ylabel('counts');
    set(gca,'YScale','log'); 
    yyaxis right
    plot(100*IRF_cv(:,s))
    title(['SDS ' num2str(SDS_dist_arr(s)) ' cm']);
    ylabel('CV (%)');
    
    lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
    lgd.NumColumns = lgdNumCol;
end
title(ti,'IRF');
print(fullfile(input_dir,'stability_IRF.png'),'-dpng','-r300');

save(fullfile(input_dir,'sys_TPSF_processed.mat'),'bg_mean','IRF_mean');

% phantom data: -bg -> start from zero points -> binning
if num_phantom~=0
    load(fullfile(input_dir,'phantom_TPSF_collect.mat'));
    TPSF_binning=[];
    for p=1:num_phantom
        figure('Units','pixels','position',[0 0 1920 1080]);
        ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
        for s=1:num_SDS
            for t=1:repeat_times
                temp_TPSF=TPSF_orig{p,s}(:,t);
                temp_TPSF=temp_TPSF-bg_mean(:,s);           % substract bg
                temp_TPSF=temp_TPSF(zero_points(:,s):end);  % start from zero points
                for i=1:floor((num_bins-(zero_points(:,s)-1))/num_binning)  % binning
                    TPSF_binning{p,s}(i,t)=sum(temp_TPSF(1+num_binning*(i-1):num_binning*i));
                end
            end
            phantom_mean{p}(:,s)=mean(TPSF_binning{p,s},2);
            phantom_cv(:,s)=std(TPSF_binning{p,s},[],2)./phantom_mean{p}(:,s);

            nexttile;
            hold on
            for t=1:repeat_times
                plot(TPSF_binning{p,s}(:,t),'Color',color_arr(t,:),'LineWidth',lineWidth);
                hold on
            end
            xlabel('# of bins');
            ylabel('counts');
    %         set(gca,'YScale','log'); 
            yyaxis right
            plot(100*phantom_cv(:,s))
            title(['SDS ' num2str(SDS_dist_arr(s)) ' cm']);
            ylabel('CV (%)');

            lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        end
        title(ti,['phantom ' num2str(p)]);
        print(fullfile(input_dir,['stability_phantom_' num2str(p) '.png']),'-dpng','-r300');
    end
    save(fullfile(input_dir,'phantom_TPSF_processed.mat'),'phantom_mean');
end

% target data
if ~isempty(target_prefix)
    for i=1:length(target_prefix)
        load(fullfile(input_dir,[target_prefix{i} '_TPSF_collect.mat']));
        TPSF_binning=[];

        figure('Units','pixels','position',[0 0 1920 1080]);
        ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
        for s=1:num_SDS
            for t=1:repeat_times
                temp_TPSF=TPSF_orig{1,s}(:,t);
                temp_TPSF=temp_TPSF-bg_mean(:,s);           % substract bg
                temp_TPSF=temp_TPSF(zero_points(:,s):end);  % start from zero points
                for i=1:floor((num_bins-(zero_points(:,s)-1))/num_binning)  % binning
                    TPSF_binning{p,s}(i,t)=sum(temp_TPSF(1+num_binning*(i-1):num_binning*i));
                end
            end
            target_mean(:,s)=mean(TPSF_binning{p,s},2);
            target_cv(:,s)=std(TPSF_binning{p,s},[],2)./target_mean(:,s);

            nexttile;
            hold on
            for t=1:repeat_times
                plot(TPSF_binning{p,s}(:,t),'Color',color_arr(t,:),'LineWidth',lineWidth);
                hold on
            end
            xlabel('# of bins');
            ylabel('counts');
    %         set(gca,'YScale','log'); 
            yyaxis right
            plot(100*target_cv(:,s))
            title(['SDS ' num2str(SDS_dist_arr(s)) ' cm']);
            ylabel('CV (%)');

            lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        end
        title(ti,[target_prefix{i}]);
        print(fullfile(input_dir,['stability_' target_prefix{i} '_' num2str(p) '.png']),'-dpng','-r300');
        save(fullfile(input_dir,[target_prefix{i} '_TPSF_processed.txt']),'target_mean','-ascii','-tabs');
    end
end

disp('Done!');