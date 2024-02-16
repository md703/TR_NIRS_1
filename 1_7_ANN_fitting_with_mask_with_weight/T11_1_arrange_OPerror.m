%{
Same as "T11_arrange_op_result.m", 
but plot two kinds of bar chart: with different noised, with different OPs
setting (for conference)
only calculate with noised case.

arrange the calculated OP error meam, std or confidence interval

Ting-Yi Kuo
Last update: 2023/01/10
%}

clc;clear;%close all; clearvars -global;

%% param

fitting_dir='test_fitting_2024-01-13-15-46-39_same_noise';
fitting_SDS_dir='fitting_cw123456_tr234'; %'fitting_cw123456',

subject_name_arr={'KB','WH','ZJ'};
num_anser_to_generate=10; % number of target spec (true answer)
num_error_to_generate=15; % number of adding noise to the same, the first one will have no error

OP_param={'\mu_{a,scalp}','\mu_{s,scalp}','\mu_{a,skull}','\mu_{s,skull}','\mu_{a,GM}','\mu_{s,GM}'};

%% main
to_load_name='OP_error_arr_Error.mat';
error_info=load(fullfile(fitting_dir,'arrangement',fitting_SDS_dir,to_load_name));

to_load_name='OP_error_arr_noError.mat';
no_error_info=load(fullfile(fitting_dir,'arrangement',fitting_SDS_dir,to_load_name));

error_per_target=abs(error_info.OP_error_arr);
no_error_per_target=abs(no_error_info.OP_error_arr);


total_target=length(subject_name_arr)*(num_error_to_generate-1)*num_anser_to_generate;
num_target_set=total_target/(num_error_to_generate-1);

% preparing data
mean_one_target_no_noise(1,:)=mean(no_error_per_target(:,:,1),[1 3]);
std_one_target_no_noise(1,:)=std(no_error_per_target(:,:,1),[],[1 3]);

mean_one_target_with_noise(1,:)=mean(error_per_target(:,:,1:14),[1 3]);
std_one_target_with_noise(1,:)=std(error_per_target(:,:,1:14),[],[1 3]);

mean_targets_no_noise(1,:)=mean(no_error_per_target(:,:,1:10),[1 3]);
std_targets_no_noise(1,:)=std(no_error_per_target(:,:,1:10),[],[1 3]);

mean_targets_with_noise(1,:)=mean(error_per_target(:,:,1:140),[1 3]);
std_targets_with_noise(1,:)=std(error_per_target(:,:,1:140),[],[1 3]);

for sbj=1:size(subject_name_arr,2)
    mean_per_subject(sbj,:)=mean(error_per_target(:,:,1+140*(sbj-1):140*sbj),[1 3]);
    std_per_subject(sbj,:)=std(error_per_target(:,:,1+140*(sbj-1):140*sbj),[],[1 3]);
end

mean_all_sbj(1,:)=mean(error_per_target,[1 3]);
std_all_sbj(1,:)=std(error_per_target,[],[1 3]);



mean_plot_in_one_figure(1,:)=mean_one_target_no_noise;
std_plot_in_one_figure(1,:)=std_one_target_no_noise;

mean_plot_in_one_figure(2,:)=mean_one_target_with_noise;
std_plot_in_one_figure(2,:)=std_one_target_with_noise;

mean_plot_in_one_figure(3,:)=mean_targets_no_noise;
std_plot_in_one_figure(3,:)=std_targets_no_noise;

% mean_plot_in_one_figure(4,:)=mean_targets_with_noise;
% std_plot_in_one_figure(4,:)=std_targets_with_noise;


%% 寄給老師的version1
figure('Position',[0 0 1920 480]);
ti=tiledlayout(1,3,'TileSpacing','Compact','Padding','Compact');

% plot mean and std between 1 target without noise/14 targets with
% noise/10 targets without noise
nexttile;
y=100*mean_plot_in_one_figure';
b=bar(y,'grouped');
hold on;
[ngroups,nbars] = size(y);
colormap_arr=unique(colormap(slanCM('paired')),'rows');
for k = 1:nbars
    b(k).FaceColor = colormap_arr(k,:);
end

x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorbar(x',y,zeros(size(y)),100*std_plot_in_one_figure','k','linestyle','none');
legend('without additional noise','with additional noise','different OP sets without additional noise','Location','southoutside','Orientation','horizontal','Numcolumns',2)  %,'different OP sets with same additional noise'
legend box off;

set(gca, 'XTickLabel', OP_param,'fontsize',14);
ylabel('error (%)');
title('The effect of noise and selected optical parameter set');


% plot quantified error with different head model 
nexttile;
y=100*mean_per_subject';
b=bar(y,'grouped');
hold on;
[ngroups,nbars] = size(y);
colormap_arr=unique(colormap(slanCM('paired')),'rows');
for k = 1:nbars
    b(k).FaceColor = colormap_arr(k,:);
end

x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorbar(x',y,zeros(size(y)),100*std_per_subject','k','linestyle','none');
legend('head model 1','head model 2','head model 3','Location','southoutside','Orientation','horizontal')
legend box off;

set(gca, 'XTickLabel', OP_param,'fontsize',14);
ylabel('error (%)');
% title('The effect of selected head model');


% plot results of all situation 
nexttile;
y=100*mean_all_sbj';
b=bar(y,'grouped');
hold on;
[ngroups,nbars] = size(y);

x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorbar(x',y,zeros(size(y)),100*std_all_sbj','k','linestyle','none');

set(gca, 'XTickLabel', OP_param,'fontsize',14);
ylabel('error (%)');
title('The error considering noise and head models');

print(fullfile('results','compared_noise_and_different_op_set.png'),'-dpng','-r200');


% plot the results of 10 targets from different ops
figure;
y=100*squeeze(mean(no_error_per_target(:,:,1:10),1));
b=bar(y,'grouped');
hold on;
[ngroups,nbars] = size(y);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorbar(x',y,zeros(size(y)),100*squeeze(std(no_error_per_target(:,:,1:10),[],1)),'k','linestyle','none');
% legend('head model 1','head model 2','head model 3','Location','southoutside','Orientation','horizontal')
% legend box off;
set(gca, 'XTickLabel', OP_param,'fontsize',14);
ylabel('error (%)');
title(' ');

%% 寄給老師的version2

%% heatmap

% the relation between noise and wavelength
figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none');

for i=1:size(error_per_target,2)
    nexttile;
    to_plot=squeeze(error_per_target(:,i,1:14));
    plot(to_plot,'o');
end

% the relation between different noise and head models

RMSPE_arr=squeeze(sqrt(mean(error_per_target.^2,[1 2])));
RMSPE_arr=reshape(RMSPE_arr,14,10,3);


figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact');
choose=[1 15 29 43 57 71 85 99 113 127];

for i=1:14
    nexttile;
%     plot(squeeze(RMSPE_arr(choose,:)),'-o');
    h(i)=heatmap(squeeze(100*RMSPE_arr(i,:,:)),'ColorbarVisible','off','Colormap', turbo); %,'ColorbarVisible','off'
    choose=choose+1;
    title(['noise ' num2str(i)]);
    xlabel('head model');
    ylabel('OP sets');
end

colorLims = vertcat(h.ColorLimits);
globalColorLim = [min(colorLims(:,1)), max(colorLims(:,2))];
set(h, 'ColorLimits', globalColorLim)

ax = axes(ti,'visible','off','Colormap',h(1).Colormap,'CLim',globalColorLim);
cb = colorbar(ax);
ylabel(cb,'RMSPE (%)','FontSize',12,'Rotation',270);
cb.Label.Position(1) = 5;
cb.Layout.Tile = 'East';

figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact');
choose=1:14;

for i=1:10
    nexttile;
%     plot(squeeze(RMSPE_arr(choose,:)),'-o');
    h(i)=heatmap(squeeze(100*RMSPE_arr(:,i,:)),'ColorbarVisible','off','Colormap', turbo); %,'ColorbarVisible','off'
    choose=choose+14;
    title(['OP set ' num2str(i)]);
    xlabel('head model');
    ylabel('noise');
end

colorLims = vertcat(h.ColorLimits);
globalColorLim = [min(colorLims(:,1)), max(colorLims(:,2))];
set(h, 'ColorLimits', globalColorLim)

ax = axes(ti,'visible','off','Colormap',h(1).Colormap,'CLim',globalColorLim);
cb = colorbar(ax);
ylabel(cb,'RMSPE (%)','FontSize',12,'Rotation',270);
cb.Label.Position(1) = 5;
cb.Layout.Tile = 'East';

figure('Units','pixels','position',[0 0 1920 400]);
ti=tiledlayout('flow','TileSpacing','compact'); %,'Padding','none'

for i=1:3
    nexttile;
%     plot(squeeze(RMSPE_arr(choose,:)),'-o');
    h(i)=heatmap(100*RMSPE_arr(:,:,i),'ColorbarVisible','off','Colormap', turbo); %,'ColorbarVisible','off'
    choose=choose+14;
    title(['head model ' num2str(i)]);
    xlabel('OP sets');
    ylabel('noise');
end

colorLims = vertcat(h.ColorLimits);
globalColorLim = [min(colorLims(:,1)), max(colorLims(:,2))];
set(h, 'ColorLimits', globalColorLim)

ax = axes(ti,'visible','off','Colormap',h(1).Colormap,'CLim',globalColorLim);
cb = colorbar(ax);
ylabel(cb,'RMSPE (%)','FontSize',12,'Rotation',270);
cb.Label.Position(1) = 5;
cb.Layout.Tile = 'East';

%% scatter plot
% the relation between different noise and head models

max_value=max(RMSPE_arr,[],'all');
min_value=min(RMSPE_arr,[],'all');


figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact');
choose=[1 15 29 43 57 71 85 99 113 127];

for i=1:14
    nexttile;
%     plot(squeeze(RMSPE_arr(choose,:)),'-o');
    plot(squeeze(100*RMSPE_arr(i,:,:)),'-o');
    choose=choose+1;
    title(['noise ' num2str(i)]);
    xlabel('OP sets');
    ylabel('RMSPE (%)');
    ylim([0 100*max_value])
end
lgd=legend('head model 1','head model 2','head model 3');
% lgd.Layout.Tile='south';


figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact');
choose=1:14;

for i=1:10
    nexttile;
%     plot(squeeze(RMSPE_arr(choose,:)),'-o');
    plot(squeeze(100*RMSPE_arr(:,i,:)),'-o'); %,'ColorbarVisible','off'
    choose=choose+14;
    title(['OP set ' num2str(i)]);
    xlabel('noise');
    ylabel('RMSPE (%)');
    ylim([0 100*max_value])
end
lgd=legend('head model 1','head model 2','head model 3');
% lgd.Layout.Tile='south';


figure('Units','pixels','position',[0 0 1920 400]);
ti=tiledlayout('flow','TileSpacing','compact'); %,'Padding','none'

for i=1:3
    nexttile;
%     plot(squeeze(RMSPE_arr(choose,:)),'-o');
    plot(squeeze(100*RMSPE_arr(:,:,i)),'-o'); %,'ColorbarVisible','off'
    choose=choose+14;
    title(['head model ' num2str(i)]);
    xlabel('noise');
    ylabel('RMSPE (%)');
    ylim([0 100*max_value])
end

%% Find the relationship between actual value of each parameters and each quantified errors
sbj=1;

fitting_wl_tr=810;
fitting_wl=load(fullfile('epsilon','fitting_wl.txt'));
fitting_wl=[fitting_wl;fitting_wl_tr];
lambda=unique(fitting_wl);

OP_answer_arr=[];
for i=1:num_anser_to_generate
    temp_OP_arr=load(fullfile(fitting_dir,'answers',['OP_ans_' num2str(i) '.txt']));
    OP_answer_arr(:,:,i)=interp1(temp_OP_arr(:,1),temp_OP_arr(:,2:end),lambda);
end
mean_OP=squeeze(mean(OP_answer_arr,1));
mean_OP=mean_OP([1 2 3 4 7 8],:);

each_target_rmspe=squeeze(sqrt(mean(error_per_target.^2,1)));
each_target_rmspe=reshape(each_target_rmspe,6,14,10,3);

same_op_target_rmspe=squeeze(sqrt(mean((each_target_rmspe.^2),2)));


for i=1:6
    fig=figure('Units','pixels','position',[0 0 1920 1080]);
    ti=tiledlayout('flow','TileSpacing','Compact','Padding','Compact');
    [~,index]=sort(mean_OP(i,:));
    for j=1:6
        nexttile;
        plot(mean_OP(i,index),same_op_target_rmspe(j,index,sbj));  % mean(same_op_target_rmspe(j,index,:),3)
        xlabel(OP_param{i});
        ylabel('RMSPE (%)');
        title(OP_param{j});
    end
end
    
    
    
%%

% % plot result of comparing different noise
% nexttile;
% y=100*mean_arr_per_target;
% b=bar(y);
% hold on;
% errorbar(1:6,y,100*std_arr_per_target,'k','linestyle','none');
% set(gca, 'XTickLabel', OP_param,'fontsize',12);
% ylabel('error (%)');
% title('14 added-noise targets generated from 1 spectrum/TPSF');
% ylim([0 25]);
% 
% % plot result of comparing different noise, optical parameter set
% nexttile;
% y=100*mean_per_sbj;
% b=bar(y);
% hold on;
% errorbar(1:6,y,100*std_per_sbj,'k','linestyle','none');
% set(gca, 'XTickLabel', OP_param,'fontsize',12);
% ylabel('error (%)');
% title('140 added-noise targets generated from 10 spectra/TPSFs');
% ylim([0 25]);
% 
% % plot result of comparing different noise, headmodel
% nexttile;
% y=100*mean_all_sbj_per_target;
% b=bar(y);
% hold on;
% errorbar(1:6,y,100*std_all_sbj_per_target,'k','linestyle','none');
% set(gca, 'XTickLabel', OP_param,'fontsize',12);
% ylabel('error (%)');
% title('42 added-noise targets generated from 1 spectrum/TPSF for three subjects');
% ylim([0 25]);
% 
% % plot result of comparing different noise,optical parameter set,headmodel
% nexttile;
% y=100*mean_all_sbj;
% b=bar(y);
% hold on;
% errorbar(1:6,y,100*std_all_sbj,'k','linestyle','none');
% set(gca, 'XTickLabel', OP_param,'fontsize',12);
% ylabel('error (%)');
% title('420 added-noise targets generated from 10 spectra/TPSFs for three subjects');
% ylim([0 25]);
% 
% print(fullfile('results','opErrorResult_compared_different_situation_bar.png'),'-dpng','-r200');
