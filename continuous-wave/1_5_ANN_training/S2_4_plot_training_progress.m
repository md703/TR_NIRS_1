%{
plot the progress of training

Benjamin Kao
Last update: 2020/12/29
%}

clc;clear;close all;

%% param
subject_name_arr={'ZJ','YH','YF','WW','WH','SJ','SC','KB','BT'}; % the name of the subject
input_dir_arr={'ZJ_2020-12-22-12-36-51','YH_2020-12-22-22-44-50','YF_2020-12-22-15-14-33','WW_2020-12-23-18-41-36','WH_2020-12-22-20-37-29','SJ_2020-12-22-18-48-01','SC_2020-12-23-02-22-28','KB_2020-12-23-16-36-17','BT_2020-12-23-00-35-30'};
num_SDS=7;

fontSize=18;
marker_size=20;
line_width=2;

%% init

%% main
for sbj=1:length(input_dir_arr)
    info=load(fullfile(input_dir_arr{sbj},'ANN__train_info.mat'), 'info');
    info=info.info;
    
    fig=figure('Units','pixels','position',[0 0 1600 900]);
    set(fig, 'visible', 'off');
    hold on;
    plot(info.TrainingRMSE,'LineWidth',line_width);
    
    % find the validation not NAN
    validation_nonNAN_index=find(~isnan(info.ValidationRMSE));
    
    plot(validation_nonNAN_index,info.ValidationRMSE(validation_nonNAN_index),'LineWidth',line_width);
    
    xlabel('iteration');
    ylabel('RMSE')
    legend({'training','validation'},'Location','northeast');
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    grid on;

    print(fullfile(input_dir_arr{sbj},'training_progress.png'),'-dpng','-r200');
    close all;
end

disp('Done!');