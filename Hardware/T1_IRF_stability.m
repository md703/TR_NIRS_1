%{
Evaluate the stability of IRF.
Run 'S1_read_phu.m' and 'S2_process_data.m' before this code.

Ting-Yi Kuo
Last update: 2024/05/01
%}

clc;clear;close all;

mother_folder='20240501-2';
% folderName={'intensity_350','intensity_380','intensity_400'};
% folderName={'fiber_bundle_distance_3.5','fiber_bundle_distance_13.5','fiber_bundle_distance_23.5'};
% folderName={'fiber_1','fiber_2','fiber_3','fiber_4','fiber_5'};
folderName={'duration_1s','duration_2s','duration_3s'};
save_name='IRF';

for i=1:length(folderName)
    load(fullfile(mother_folder,folderName{i},[save_name '_info_record.mat']));
    load(fullfile(mother_folder,folderName{i},[save_name '_TPSF_collect.mat']));
    
    TPSF_collect=TPSF_collect(1:500,:);
    
    total_counts(i,:)=info_record{:,3};
    peak_counts(i,:)=info_record{:,4};
    
    for j=1:size(TPSF_collect,2)
        TPSF=TPSF_collect(:,j);
        [max_y, max_index]=max(TPSF);
        half_max=max_y/2;
        
        left_index=find(TPSF(1:max_index)<half_max,1,'last');
        right_index=find(TPSF(max_index:end)<half_max,1)+max_index-1;

        FWHM(i,j)=right_index-left_index;
    end
    
    % normalized
    for t=1:size(TPSF_collect,2)
        temp_TPSF=TPSF_collect(:,t);
        max_value=max(temp_TPSF);
        TPSF_collect_norm(:,t)=temp_TPSF./max_value;
    end
    
    total_counts_norm(i,:)=sum(TPSF_collect_norm);
    peak_counts_norm(i,:)=max(TPSF_collect_norm);
    
    for j=1:size(TPSF_collect,2)
        TPSF=TPSF_collect_norm(:,j);
        [max_y, max_index]=max(TPSF);
        half_max=max_y/2;
        
        left_index=find(TPSF(1:max_index)<half_max,1,'last');
        right_index=find(TPSF(max_index:end)<half_max,1)+max_index-1;

        FWHM_norm(i,j)=right_index-left_index;
    end
    
    folderName{i}=strrep(folderName{i}, '_', ' ');
end


figure('Units','pixel','Position',[0 0 1980 1080]);
ti=tiledlayout(2,1);
tt=tiledlayout(ti,1,4);
tt.Layout.Tile=1;

nexttile(tt);
semilogy(TPSF_collect);
xticklabels(0:2.5:12.5);
ylabel('Counts');
yyaxis right
plot(100*std(TPSF_collect,[],2)./mean(TPSF_collect,2));
ylabel('CV(%)');
xlabel('time(ns)');
title(['Impulse response function (' folderName{end} ')']);

nexttile(tt);
plot(1:1:size(info_record,1),total_counts,'-o','Linewidth',2);
xlabel('#Test');
ylabel('Total counts');
% yyaxis right
nexttile(tt);
plot(1:1:size(info_record,1),peak_counts,'-o','Linewidth',2);
ylabel('Peak counts');
xlabel('#Test');
legend(folderName);

nexttile(tt);
plot(1:1:size(info_record,1),FWHM*0.025*1000,'-o','Linewidth',2);
ylabel('FWHM (ps)');
xlabel('#Test');
title(tt,'Before normalized');

tt=tiledlayout(ti,1,4);
tt.Layout.Tile=2;
nexttile(tt);
semilogy(TPSF_collect_norm);
xticklabels(0:2.5:12.5);
ylabel('Counts');
yyaxis right
plot(100*std(TPSF_collect_norm,[],2)./mean(TPSF_collect_norm,2));
ylabel('CV(%)');
xlabel('time(ns)');
title(['Impulse response function (' folderName{end} ')']);

nexttile(tt);
plot(1:1:size(info_record,1),total_counts_norm,'-o','Linewidth',2);
ylabel('Total counts');
xlabel('#Test');
nexttile(tt);
% yyaxis right
plot(1:1:size(info_record,1),peak_counts_norm,'-o','Linewidth',2);
ylabel('Peak counts');
xlabel('#Test');
legend(folderName);

nexttile(tt);
plot(1:1:size(info_record,1),FWHM_norm*0.025*1000,'-o','Linewidth',2);
ylabel('FWHM (ps)');
xlabel('#Test');

title(tt,'After normalized');

% title(ti,'IRF influenced by intensity');
% print(fullfile(mother_folder,'intensity_influence.png'),'-dpng','-r300');

% title(ti,'IRF influenced by fiber bundle distance');
% print(fullfile(mother_folder,'fiber_bundle_distance_influence.png'),'-dpng','-r300');

% title(ti,'IRF influenced by different fiber');
% print(fullfile(mother_folder,'fiber_difference_influence.png'),'-dpng','-r300');

title(ti,'IRF influenced by acquisition time');
print(fullfile(mother_folder,'acquisition_time_influence.png'),'-dpng','-r300');
