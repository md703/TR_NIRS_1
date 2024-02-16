%{
Replot the training error histogram

Benjamin Kao
Last update: 2020/12/23
%}

clc;clear;close all;

%% param
subject_name_arr={'KB'}; % the name of the subject
input_dir_arr={'KB_2024-01-21-09-59-40'};
num_SDS=7;
SDS_dist_arr=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm

fontSize=12;
marker_size=20;
line_width=2;

for sbj_i=1:length(input_dir_arr)
    input_dir=input_dir_arr{sbj_i};
    %% init
    fprintf('Processing %s\n',input_dir);
    load(fullfile(input_dir,'ANN__train_info.mat'));
    
    error_mean=mean(abs(error),1);
    error_std=std(error,[],1);
    error_rmspe=sqrt(mean(error.^2,1));
    
    %% main
    fig=figure('Units','pixels','position',[0 0 1600 900]);
    set(fig, 'visible', 'off');
    ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
    for s=1:num_SDS
        nexttile();
        [a,b]=hist(error(:,s),50);
        bar(b,a+1);
        set(gca, 'YScale', 'log');
        grid on;
        xlabel('Error');
        ylabel('testing data number');
        title({['SDS = ' num2str(SDS_dist_arr(s)) ' cm testing error histogram'],['mean=' num2str(error_mean(s)*100,'%.2f%%') ', std=' num2str(error_std(s)*100,'%.2f%%') ', rmspe=' num2str(error_rmspe(s)*100,'%.2f%%')]});
        set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
        fprintf('---- error= %2.4f%%, rmse= %2.4f%%, std=%2.4f%%\n',error_mean(s)*100,error_rmspe(s)*100,error_std(s)*100);
    end
    title(ti,[subject_name_arr{sbj_i} ' training result'], 'FontName', 'Times New Roman');

    print(fullfile(input_dir,['testing_error_histogram.png']),'-dpng','-r200');
    close all;
    %% Plot each SDS result in one figure
    fig=figure('Units','pixels','position',[0 0 400 400]);
%     ti=tiledlayout(1,5,'TileSpacing','compact','Padding','none');
    
    max_error=0.1;
    min_error=-0.1;
    bin_size=(max_error-min_error)/100;
    bins=min_error:bin_size:max_error;
    
    colormap_arr=jet(6);
    for s=1:num_SDS-1
        hold on
        [a,b]=hist(error(:,s),bins);
        f=fill(b,a,colormap_arr(s,:),'FaceAlpha',0.15);
        
        f.EdgeColor=colormap_arr(s,:);
    end
    
    rmspe=sqrt(mean(error(:,1:6).^2,'all'));
    
    xlabel('Error');
    ylabel('testing data number');
    box on
    title({['RMSPE = ' num2str(100*rmspe) '%']},'FontWeight','Normal');
    legend('SDS 1','SDS 2','SDS 3','SDS 4','SDS 5','SDS 6');
    set(gca,'fontsize',17);
    
    print(fullfile(input_dir,['testing_error_histogram_total.png']),'-dpng','-r200');

end

disp('Done!');