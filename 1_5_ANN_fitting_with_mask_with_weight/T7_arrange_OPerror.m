%{
arrange the calculated OP error meam, std or confidence interval

Benjamin Kao
Last update: 2021/03/29
%}

clc;clear;close all; clearvars -global;

%% param
% fitting_dir_arr={'test_fitting_2023-12-12-11-59-43'};
% fitting_SDS_dir_arr={'fitting_tr1_gate12','fitting_tr1_gate1234','fitting_tr1_gate123456','fitting_tr1_gate12345678', ...
%                     'fitting_tr12_gate12','fitting_tr12_gate1234','fitting_tr12_gate123456','fitting_tr12_gate12345678', ...
%                     'fitting_tr123_gate12','fitting_tr123_gate1234','fitting_tr123_gate123456','fitting_tr123_gate12345678' ...
%                     'fitting_tr1234_gate12','fitting_tr1234_gate1234','fitting_tr1234_gate123456','fitting_tr1234_gate12345678'};
% fitting_dir_index=ones(1,16);  %[1 1 1 1 1 1];
% add_noise_arr=zeros(1,16);  %0 0 0 0 0 0];
% fitting_name_arr={'1','2','3','4','1','2','3','4','1','2','3','4','1','2','3','4'}; %'SDS 12 merged no noise',

% fitting_dir_arr={'test_fitting_2024-06-16-00-59-47'};
% fitting_SDS_dir_arr={'fitting_tr1234_gate123456'};
% 
% fitting_dir_index=[1 1];
% add_noise_arr=[0 0];
% fitting_name_arr={'',''}; %'SDS 12 merged no noise',

fitting_dir_arr={'test_fitting_2024-06-16-00-59-47'};
fitting_SDS_dir_arr={'fitting_cw123456','fitting_tr1234_gate123456'};

fitting_dir_index=[1 1];  %[1 1 1 1 1 1];
add_noise_arr=[0 0];   %0 0 0 0 0 0];
fitting_name_arr={'CW','CW & TR'}; %'SDS 12 merged no noise',

OP_param={'\mu_{a,scalp}','\mu_{s,scalp}','\mu_{a,skull}','\mu_{s,skull}','\mu_{a,GM}','\mu_{s,GM}'};

%% main
std_arr=[];
mean_arr=[];
RMSE_arr=[];
ci_arr={};
for i=1:3
    ci_arr{i}=[];
end

for i=1:length(fitting_SDS_dir_arr)
    if add_noise_arr(i)==0                                                                                     
        to_load_name='OP_error_arr_noError.mat';
    else
        to_load_name='OP_error_arr_Error.mat';
    end
    error_info=load(fullfile(fitting_dir_arr{fitting_dir_index(i)},'arrangement',fitting_SDS_dir_arr{i},to_load_name));
    
    RMSE_arr(i,:)=sqrt(mean(error_info.OP_error_arr.^2,[1 3]));
    mean_arr(i,:)=mean(abs(error_info.OP_error_arr),[1 3]);
    std_arr(i,:)=std(abs(error_info.OP_error_arr),[],[1 3]);
    
    for opi=1:6
        for ci_l=1:1 % confidence level
            for j=1:2
                ci_arr{ci_l}(i,opi,j)=error_info.OP_error_CI{opi}(ci_l,j);
            end
        end
%         std_arr(i,opi)=error_info.total_std_error_arr(opi);
%         mean_arr(i,opi)=error_info.total_mean_OP_error_arr(opi);
    end
end

%% output the mean error
fprintf('mean error:\n');
fprintf('| op | mua1 | mus1 | mua2 | mus2 | mua4 | mus4 |\n|:------ | ---- | ---- | ---- |:---- | ---- |:---- |\n'); % header
for i=1:length(fitting_SDS_dir_arr)
    fprintf('|%s',fitting_name_arr{i});
    for opi=1:6
        fprintf('|%.2f%%',mean_arr(i,opi)*100);
    end
    fprintf('|\n');
end

%% output the error std
fprintf('\nerror std:\n');
fprintf('| op | mua1 | mus1 | mua2 | mus2 | mua4 | mus4 |\n|:------ | ---- | ---- | ---- |:---- | ---- |:---- |\n'); % header
for i=1:length(fitting_SDS_dir_arr)
    fprintf('|%s',fitting_name_arr{i});
    for opi=1:6
        fprintf('|%.2f%%',std_arr(i,opi)*100);
    end
    fprintf('|\n');
end

%% output the RMSPE
fprintf('\nRMSPE:\n');
fprintf('| op | mua1 | mus1 | mua2 | mus2 | mua4 | mus4 |\n|:------ | ---- | ---- | ---- |:---- | ---- |:---- |\n'); % header
for i=1:length(fitting_SDS_dir_arr)
    fprintf('|%s',fitting_name_arr{i});
    for opi=1:6
        fprintf('|%.2f%%',RMSE_arr(i,opi)*100);
    end
    fprintf('|\n');
end

% plot RMSPE in bar chart
% RMSE_arr=[RMSE_arr; 0.1839 0.0747 0.3852 0.1419 0.2665 0.6902];
figure('Position',[0 0 640 480]);
y=100*RMSE_arr';
colormap_arr=unique(colormap(slanCM('paired')),'rows');

b=bar(y,'FaceColor','flat');
for k = 1:size(y,2)
    b(k).CData = colormap_arr(k,:);
end

xticklabels(OP_param);
ylabel('RMSPE (%)');
legend([fitting_name_arr 'CW'],'Location','northwest');
set(gca,'fontsize',14,'FontName','Times New Roman');
mkdir('results')
print(fullfile('results','OP_result_RMSE_bar.png'),'-dpng','-r200');


% plot mean and std in bar chart
figure('Position',[0 0 640 480]);
y=100*mean_arr';
colormap_arr=unique(colormap(slanCM('paired')),'rows');

b=bar(y,'FaceColor','flat');
hold on
for k = 1:size(y,2)
    b(k).CData = colormap_arr(k,:);
end

[ngroups,nbars] = size(y);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end
errorbar(x',y,zeros(size(y)),100*std_arr','k','linestyle','none');

xticklabels(OP_param);
ylabel('error (%)');
legend([fitting_name_arr],'Location','southoutside','Orientation','horizontal');
legend box off
set(gca,'fontsize',14,'FontName','Times New Roman');
mkdir('results')
print(fullfile('results','OP_result_mean_std_bar.png'),'-dpng','-r200');



% % plot RMSPE in line chart
% % RMSE_arr=[RMSE_arr; 0.1839 0.0747 0.3852 0.1419 0.2665 0.6902];
% figure('Position',[0 0 600 600]);
% line_prop={'--*','-x','--square','-diamond','--pentagram','-v'};
% y=100*RMSE_arr;
% for p=1:size(RMSE_arr,2)
%     plot(y(:,p),line_prop{p},'Linewidth',1.2);
%     hold on
% end
% xticks(1:6);
% xlabel('number of SDS');
% ylabel('RMSPE (%)');
% legend(OP_param,'Location','southoutside','fontsize',20,'NumColumns',3)
% legend boxoff
% set(gca,'fontsize',18);
% mkdir('results')
% print(fullfile('results','OP_result_RMSE_line.png'),'-dpng','-r200');


% % heatmap for TR data (num_SDS and num_gate used for fitting)
% sub_index=[1 4 2 5 3 6];
% fig=figure('Position',[0 0 1920 1080]);
% ti=tiledlayout(fig,2,3,'TileSpacing','compact');
% h=gobjects(6,1);
% for p=1:size(RMSE_arr,2)
%     ax=nexttile(sub_index(p));
%     temp_to_plot=100*RMSE_arr(:,p);
%     to_plot=reshape(temp_to_plot,4,4);
% %     h=redbluecmap(to_plot);
%     h(p)=heatmap(to_plot,'Colormap', parula,'YData', ["2" "4" "6" "8"],'ColorbarVisible','off','FontSize',14);
%     title(OP_param{p});
%     xlabel('number of SDS');
%     ylabel('number of gate');
%     h(p).YDisplayData=flipud(h(p).YDisplayData);
%     grid off
%     set(gca,'fontsize',20);
% end
% 
% colorLims=vertcat(h.ColorLimits);
% globalColorLim=[min(colorLims(:,1)), max(colorLims(:,2))];
% set(h,'ColorLimits', globalColorLim);
% 
% ax=axes(ti,'visible','off','Colormap',h(1).Colormap,'CLim',globalColorLim,'FontSize',14);
% cb=colorbar(ax);
% ylabel(cb,'(%)','FontSize',20,'Rotation',270);
% cb.Label.Position(1) = 5;
% cb.Layout.Tile='East';
% print(fullfile('results',['OP_result_RMSE_bar_op.png']),'-dpng','-r200');


%% output the confidence interval
fprintf('\nconfidence interval:\n');
for ci_l=1:1
    fprintf('confidence level %f:\n',error_info.confidence_arr(ci_l));
    fprintf('| op | mua1 | mus1 | mua2 | mus2 | mua4 | mus4 |\n|:------ | ---- | ---- | ---- |:---- | ---- |:---- |\n'); % header
    for i=1:length(fitting_SDS_dir_arr)
        fprintf('|%s',fitting_name_arr{i});
        for opi=1:6
            fprintf('|');
            for j=1:2
                fprintf('%.2f%%',ci_arr{ci_l}(i,opi,j)*100);
                if j==1
                    fprintf('~');
                end
            end
        end
        fprintf('|\n');
    end
end