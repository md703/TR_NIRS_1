%{
Compare the spectrum of subject and phantom

Benjamin Kao
Last update: 2020/12/23
%}

clc;clear;close all;

%% param
input_dir='extracted_subject_spec_2'; % the folder of the experiment
simulate_folder='phantom_simulation_MCML_FDA_7EK_2_dilated'; % the folder of the phantom simulation spectrum
target_name_arr={'p1','p2','p3','p4','p5','p6','tc','ww','wh','yf','kb'}; % the name of phantom and subject
use_anonymous=1; % =1 to use subject index
num_SDS=6; % number of SDS
SDS_dist_arr=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm
num_of_phantoms=6; % the former n targets are phantoms
sim_ph_index=[1 2 3 4 5 6]; % the index of the simulated phantom corresponding to the measured phantom
sim_SDS_index=[1 2 3 4 5 6]; % the SDS in the simulated spectrum correspond to the measured spectrum

% about plot
lineWidth=2;
fontSize=18;
lgdFontSize=18;
lgdNumCol=11;

subplot_height=300; % pixel, the height of subplot
subplot_width=450; % pixel, the width of subplot
left_spacing=80; % pixel, the space between subplot and the left things
right_spacing=50; % pixel, the space right of the last column of subplot
upper_spacing=70; % pixel, the space between subplot and the upper things
lower_spacing=30; % pixel, the space below the legend box
legend_height=50; % pixel, the height of legend box

plot_n_col=3; % the column number of subplot
plot_n_row=2; % the row number of subplot

%% init
phantom_colormap_arr=copper(num_of_phantoms);
target_colormap_arr=jet(length(target_name_arr)-num_of_phantoms);
colormap_arr=[phantom_colormap_arr;target_colormap_arr];

assert(length(sim_ph_index)==num_of_phantoms,'Error! the number of the phantom not match the ''sim_ph_index'' setting!');
assert(length(sim_SDS_index)==num_SDS,'Error! the number of the SDS not match the ''sim_SDS_index'' setting!');

legend_arr={};
if use_anonymous==0
    for i=1:length(target_name_arr)
        legend_arr{end+1}=target_name_arr{i};
    end
else
    for i=1:num_of_phantoms
        legend_arr{end+1}=target_name_arr{i};
    end
    for i=1:length(target_name_arr)-num_of_phantoms
        legend_arr{end+1}=['subject ' num2str(i)];
    end
end

%% main
% load the calibrated (simulation) spectrum
all_calibration_spec_arr={};
max_spec_arr={};
min_spec_arr={};
for i=1:length(target_name_arr)
    if i<=num_of_phantoms
        all_calibration_spec_arr{i}=load(fullfile(simulate_folder,['phantom_' num2str(sim_ph_index(i)) '_spec.txt']));
        all_calibration_spec_arr{i}=all_calibration_spec_arr{i}(:,[1 sim_SDS_index+1]);
    else
        all_calibration_spec_arr{i}=load(fullfile(input_dir,[target_name_arr{i} '_mean.txt']));
        max_spec_arr{i}=load(fullfile(input_dir,[target_name_arr{i} '_max.txt']));
        min_spec_arr{i}=load(fullfile(input_dir,[target_name_arr{i} '_min.txt']));
    end
end

%% plot calibrated (simulation) spectrum
fprintf('Plot the calibrated targets and phantom together.\n');
fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');
for s=1:num_SDS
    row_index=ceil(s/plot_n_col);
    col_index=s-(row_index-1)*plot_n_col;
    subplot(plot_n_row,plot_n_col,s)
    hold on;
    plt_arr=[];
    for i=1:length(target_name_arr)
        if i<=num_of_phantoms
            plt_arr(end+1)=plot(all_calibration_spec_arr{i}(:,1),all_calibration_spec_arr{i}(:,s+1),'--','Color',colormap_arr(i,:),'LineWidth',lineWidth);
        else
            plt_arr(end+1)=plot(all_calibration_spec_arr{i}(:,1),all_calibration_spec_arr{i}(:,s+1),'Color',colormap_arr(i,:),'LineWidth',lineWidth);
            plot(all_calibration_spec_arr{i}(:,1),max_spec_arr{i}(:,s+1),':','Color',colormap_arr(i,:),'LineWidth',lineWidth);
            plot(all_calibration_spec_arr{i}(:,1),min_spec_arr{i}(:,s+1),':','Color',colormap_arr(i,:),'LineWidth',lineWidth);
        end
    end
    hold off;
    if s==num_SDS
        lgd=legend(plt_arr,legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
    end
    title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm']);
    grid on;
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);
end
print(fullfile(input_dir,'compare_calib_target_phantom.png'),'-dpng','-r200');
close all;

disp('Done!');