%{
Compare the extracted spectrum of target and phantom, also plot the calibration result compares to the phantom

Benjamin Kao
Last update: 2021/01/17
%}

clc;clear;close all;

%% param
input_dir='20201209_test_14'; % the folder of the experiment
extracted_folder='extracted_spec'; % the folder of the extracted spectrum
calib_dir='calibration_MCML_2'; % the folder of the calibration result
simulate_folder='phantom_simulation_MCML_FDA_7EK_2_dilated'; % the folder of the phantom simulation spectrum
target_name_arr={'p1','p2','p3','p4','p5','p6','tc_1','tc_2','tc_3','tc_4','tc_5','tc_6'}; % 14
using_anonymous_index=1; % if ~=0, use this as the subject index; if ==0, use the original name of the subject
num_SDS=6; % number of SDS
SDS_dist_arr=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm
num_of_phantoms=6; % the former n targets are phantoms
sim_ph_index=[1 2 3 4 5 6]; % the index of the simulated phantom corresponding to the measured phantom
sim_SDS_index=[1 2 3 4 5 6]; % the SDS in the simulated spectrum correspond to the measured spectrum

% about plot
lineWidth=2;
fontSize=18;
lgdFontSize=18;
lgdNumCol=6;

subplot_height=250; % pixel, the height of subplot
subplot_width=450; % pixel, the width of subplot
left_spacing=80; % pixel, the space between subplot and the left things
right_spacing=50; % pixel, the space right of the last column of subplot
upper_spacing=70; % pixel, the space between subplot and the upper things
lower_spacing=30; % pixel, the space below the legend box
legend_height=100; % pixel, the height of legend box

plot_n_col=3; % the column number of subplot
plot_n_row=2; % the row number of subplot

%% init
phantom_colormap_arr=copper(num_of_phantoms);
target_colormap_arr=jet(length(target_name_arr)-num_of_phantoms);
colormap_arr=[phantom_colormap_arr;target_colormap_arr];

assert(length(sim_ph_index)==num_of_phantoms,'Error! the number of the phantom not match the ''sim_ph_index'' setting!');
assert(length(sim_SDS_index)==num_SDS,'Error! the number of the SDS not match the ''sim_SDS_index'' setting!');

legend_arr={};
if using_anonymous_index==0
    for i=1:length(target_name_arr)
        legend_arr{end+1}=strrep(target_name_arr{i},'_',' ');
    end
else
    for i=1:num_of_phantoms
        legend_arr{end+1}=strrep(target_name_arr{i},'_',' ');
    end
    for i=1:length(target_name_arr)-num_of_phantoms
        legend_arr{end+1}=['subject\_' num2str(using_anonymous_index) '_' num2str(i)];
    end
end

%% main
% load the measured spectrum
all_measure_spec_arr={};
for i=1:length(target_name_arr)
    if i<=num_of_phantoms
        all_measure_spec_arr{i}=load(fullfile(input_dir,extracted_folder,['phantom_' target_name_arr{i} '.txt']));
    else
        all_measure_spec_arr{i}=load(fullfile(input_dir,extracted_folder,[target_name_arr{i} '.txt']));
    end
end

% load the calibrated (simulation) spectrum
all_calibration_spec_arr={};
for i=1:length(target_name_arr)
    if i<=num_of_phantoms
        all_calibration_spec_arr{i}=load(fullfile(simulate_folder,['phantom_' num2str(sim_ph_index(i)) '_spec.txt']));
        all_calibration_spec_arr{i}=all_calibration_spec_arr{i}(:,[1 sim_SDS_index+1]);
    else
        all_calibration_spec_arr{i}=load(fullfile(input_dir,calib_dir,[target_name_arr{i} '.txt']));
    end
end

%% plot measured spectrum
fprintf('Plot the measured targets and phantom together.\n');
fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');
for s=1:num_SDS
    row_index=ceil(s/plot_n_col);
    col_index=s-(row_index-1)*plot_n_col;
    subplot(plot_n_row,plot_n_col,s)
    hold on;
    for i=1:length(target_name_arr)
        if i<=num_of_phantoms
            plot(all_measure_spec_arr{i}(:,1),all_measure_spec_arr{i}(:,s+1),'--','Color',colormap_arr(i,:),'LineWidth',lineWidth);
        else
            plot(all_measure_spec_arr{i}(:,1),all_measure_spec_arr{i}(:,s+1),'Color',colormap_arr(i,:),'LineWidth',lineWidth);
        end
    end
    hold off;
    if s==num_SDS
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
    end
    title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm']);
    grid on;
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);
end
if using_anonymous_index==0
    print(fullfile(input_dir,'compare_measure_target_phantom.png'),'-dpng','-r200');
else
    print(fullfile(input_dir,['compare_measure_target_phantom_' num2str(using_anonymous_index) '.png']),'-dpng','-r200');
end
close all;

%% plot calibrated (simulation) spectrum
fprintf('Plot the calibrated targets and phantom together.\n');
fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');
for s=1:num_SDS
    row_index=ceil(s/plot_n_col);
    col_index=s-(row_index-1)*plot_n_col;
    subplot(plot_n_row,plot_n_col,s)
    hold on;
    for i=1:length(target_name_arr)
        if i<=num_of_phantoms
            plot(all_calibration_spec_arr{i}(:,1),all_calibration_spec_arr{i}(:,s+1),'--','Color',colormap_arr(i,:),'LineWidth',lineWidth);
        else
            plot(all_calibration_spec_arr{i}(:,1),all_calibration_spec_arr{i}(:,s+1),'Color',colormap_arr(i,:),'LineWidth',lineWidth);
        end
    end
    hold off;
    if s==num_SDS
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
    end
    title(['SDS ' num2str(s)]);
    grid on;
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);
end
if using_anonymous_index==0
    print(fullfile(input_dir,'compare_calib_target_phantom.png'),'-dpng','-r200');
else
    print(fullfile(input_dir,['compare_calib_target_phantom_' num2str(using_anonymous_index) '.png']),'-dpng','-r200');
end
close all;

%% plot measured and calibrated spectrum
fprintf('Plot the measured and calibrated targets and phantom together.\n');
fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*2+right_spacing (upper_spacing+subplot_height)*num_SDS+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');
for s=1:num_SDS
    % measured
    subplot(num_SDS,2,2*s-1);
    hold on;
    for i=1:length(target_name_arr)
        if i<=num_of_phantoms
            plot(all_measure_spec_arr{i}(:,1),all_measure_spec_arr{i}(:,s+1),'--','Color',colormap_arr(i,:),'LineWidth',lineWidth);
        else
            plot(all_measure_spec_arr{i}(:,1),all_measure_spec_arr{i}(:,s+1),'Color',colormap_arr(i,:),'LineWidth',lineWidth);
        end
    end
    hold off;
    title(['measured SDS ' num2str(s)]);
    grid on;
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    set(gca,'Unit','pixels','Position',[left_spacing lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(num_SDS-s) subplot_width subplot_height]);
    
    % calibrated
    subplot(num_SDS,2,2*s);
    hold on;
    for i=1:length(target_name_arr)
        if i<=num_of_phantoms
            plot(all_calibration_spec_arr{i}(:,1),all_calibration_spec_arr{i}(:,s+1),'--','Color',colormap_arr(i,:),'LineWidth',lineWidth);
        else
            plot(all_calibration_spec_arr{i}(:,1),all_calibration_spec_arr{i}(:,s+1),'Color',colormap_arr(i,:),'LineWidth',lineWidth);
        end
    end
    hold off;
    if s==num_SDS
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing 2*subplot_width+left_spacing legend_height]);
    end
    title(['calibrated SDS ' num2str(s)]);
    grid on;
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    set(gca,'Unit','pixels','Position',[left_spacing*2+subplot_width lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(num_SDS-s) subplot_width subplot_height]);
end
if using_anonymous_index==0
    print(fullfile(input_dir,'compare_target_phantom.png'),'-dpng','-r200');
else
    print(fullfile(input_dir,['compare_target_phantom_' num2str(using_anonymous_index) '.png']),'-dpng','-r200');
end
close all;

disp('Done!');