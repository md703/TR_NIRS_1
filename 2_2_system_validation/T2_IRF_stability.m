%{
Evaluate the stability of IRF.
Run 'S1_read_phu.m' before this code.

Ting-Yi Kuo
Last update: 2024/05/01
%}

clc;clear;close all;

mother_folder='20240501_IRF_analysis';
folderName={'fiber_1','fiber_2','fiber_3','fiber_4'};
save_name='IRF';

sim_folder='1_ph_info';
sim_TPSF=load(fullfile(sim_folder,['phantom_' num2str(3) '_TPSF.txt']));

start_index=98;

for i=1:length(folderName)
    load(fullfile(mother_folder,folderName{i},[save_name '_info_record.mat']));
    load(fullfile(mother_folder,folderName{i},[save_name '_TPSF_collect.mat']));
    
    TPSF_collect=TPSF_collect(start_index:500,:);
    
    total_counts(i,:)=info_record{:,3};
    peak_counts(i,:)=info_record{:,4};

    % normalized
    for t=1:size(TPSF_collect,2)
        temp_TPSF=TPSF_collect(:,t);
        max_value=max(temp_TPSF);
        TPSF_collect_norm(:,t)=temp_TPSF./max_value;
    end
    
    TPSF(:,i)=mean(TPSF_collect_norm,2);
    [max_y, max_index]=max(TPSF(:,i));
    half_max=max_y/2;
    left_index=find(TPSF(1:max_index,i)<half_max,1,'last');
    right_index=find(TPSF(max_index:end,i)<half_max,1)+max_index-1;
    FWHM(i)=right_index-left_index;
    
    pred_TPSF(:,i)=conv(sim_TPSF(:,1),TPSF(:,i));
    for j=1:size(pred_TPSF,2)
        temp_TPSF=pred_TPSF(:,j);
        max_value=max(temp_TPSF);
        pred_TPSF(:,j)=temp_TPSF./max_value;
    end
    % move max to same point
    for j=1:size(pred_TPSF,2)
        [max_value,max_first]=max(pred_TPSF(:,1));
        for j=1:size(pred_TPSF,2)-1
            temp=pred_TPSF(:,j+1);
            [~, max_now]=max(temp);
            x_shift=max_now-max_first;
            pred_TPSF(:,j+1)=circshift(temp,-x_shift);
        end
    end
    
    legend_arr_1{i}=[strrep(folderName{i}, '_', ' ') ', FWHM = ' num2str(FWHM(i)*0.025*1000) ' ps'];
    legend_arr_2{i}=[strrep(folderName{i}, '_', ' ')];
end


figure('Units','pixel','Position',[0 0 1080 360]);
ti=tiledlayout(1,2);

nexttile;
plot(0:0.025:0.025*(size(TPSF,1)-1),TPSF,'Linewidth',2);
xlabel('time (ns)')
ylabel('Normalized counts')
legend(legend_arr_1);
set(gca,'YScale','log','FontName','Times New Roman')

legend_arr_2=[legend_arr_2 legend_arr_2(2:end)];
nexttile;
plot(0:0.025:0.025*(size(pred_TPSF,1)-1),pred_TPSF,'Linewidth',2);
ylabel('Normalized counts')
xlabel('time (ns)')
set(gca,'YScale','log');
yyaxis right
relative_error=(pred_TPSF(:,2:end)-pred_TPSF(:,1))./pred_TPSF(:,1);
plot(0:0.025:0.025*(size(relative_error,1)-1),abs(100*relative_error),'Linewidth',2);
ylabel('relative error compared to the first (%)')
ylim([0 50])
legend(legend_arr_2);
set(gca,'FontName','Times New Roman')

title(ti,'IRF influenced by different fiber');
print(fullfile(mother_folder,'fiber_difference_influence.png'),'-dpng','-r300');

%% intensity, place, continuous measurement
mother_folder='20240612-IRF';

% title(ti,'IRF influenced by intensity');
% print(fullfile(mother_folder,'intensity_influence.png'),'-dpng','-r300');

% title(ti,'IRF influenced by fiber bundle distance');
% print(fullfile(mother_folder,'fiber_bundle_distance_influence.png'),'-dpng','-r300');

