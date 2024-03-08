%{
Compare the extracted (minus BG) phantom spectrum of the same target, and find the error shift trend of each SDS

Benjamin Kao
Last update: 2021/03/30
%}

clc;clear;close all;

%% param
input_dir='20201209_test_14'; % the folder of the experiment
extracted_folder='extracted_spec'; % the folder of the extracted spectrum
calib_dir='calibration_MCML_2';
target_name_prefix='tc_'; % the name of the target to plot
target_index=load(['extracted_subject_spec_2/' target_name_prefix 'used_index.txt']); % the index to plot
output_name=[target_name_prefix 'errorShift']; % the saved picture name
% output_name='takeUp_tc'; % the saved picture name
reset_legend_name=1; % =1 to rename the index to [1 2 ......]
reset_subject_name='subject 1';
num_SDS=6; % number of SDS
SDS_length_arr=[0.8 1.5 2.12 3 3.35 4.5]; % cm
CV_maxVal=30; % in %, the max CV to show, if the CV is larger than this value, the larger part will be shrink

plot_wl_interval=[700 890];

% about plot
lineWidth=2;
fontSize=18;
lgdFontSize=18;
lgdNumCol=14;

subplot_height=250; % pixel, the height of subplot
subplot_width=400; % pixel, the width of subplot
left_spacing=120; % pixel, the space between subplot and the left things
right_spacing=80; % pixel, the space right of the last column of subplot
upper_spacing=100; % pixel, the space between subplot and the upper things
lower_spacing=30; % pixel, the space below the legend box
legend_height=50; % pixel, the height of legend box

plot_n_col=3; % the column number of subplot
plot_n_row=2; % the row number of subplot


%% init
target_name_arr={};
for i=1:length(target_index)
    target_name_arr{i}=[target_name_prefix num2str(target_index(i))];
end

color_arr=jet(length(target_name_arr));
legend_arr={};
for i=1:length(target_name_arr)-1
    if reset_legend_name==1
%         legend_arr{i}=[strrep(target_name_prefix,'_',' ') num2str(i)];
        legend_arr{i}=[reset_subject_name '_{' num2str(i+1) '}'];
    else
        legend_arr{i}=strrep(target_name_arr{i},'_',' ');
    end
end
% legend_arr={'water_1','water_2','water_3','gel_1','gel_2','gel_3'};
% legend_arr{end+1}='CV';

%% main
BG_spec_arr={};
for i=1:length(target_name_arr)
    temp=load(fullfile(input_dir,calib_dir,[target_name_arr{i} '.txt']));
    if i==1
        plot_wl=temp(:,1);
    end
    for s=1:num_SDS
        BG_spec_arr{s}(:,i)=temp(:,s+1);
    end
end

error_spec_arr={};
for s=1:num_SDS
    error_spec_arr{s}=BG_spec_arr{s}(:,2:end)./BG_spec_arr{s}(:,1)-1;
end

%% plot mean
fprintf('Plot the measured targets.\n');
fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');

for s=1:num_SDS
    row_index=ceil(s/plot_n_col);
    col_index=s-(row_index-1)*plot_n_col;
    subplot(plot_n_row,plot_n_col,s)
    hold on;
    for i=1:length(target_name_arr)-1
        plot(plot_wl,error_spec_arr{s}(:,i),'Color',color_arr(i,:),'LineWidth',lineWidth);
    end
    xlabel('wavelength');
    ylabel('Reflectance error');
    
    if s==num_SDS
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
    end
    
    xlim(plot_wl_interval);
    
    title(['SDS ' num2str(SDS_length_arr(s)) ' cm']);
    grid on;
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);
end
print(fullfile(input_dir,[output_name '.png']),'-dpng','-r200');

close all;

disp('Done!');