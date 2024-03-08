%{
plot the subject range as delta OD, also plot the Hb and HbO mua spec

Benjamin Kao
Last update: 2021/01/16
%}

clc;clear;close all;

%% param
input_dir='20201209_test_14';
target_name_arr={'tc_6','tc_7','tc_8','tc_9','tc_10'}; % the target not take up
num_SDS=6;
SDS_dist_arr=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm

calib_dir='calibration_MCML_2';

lineWidth=2;
fontSize=18;
lgdFontSize=12;
lgdNumCol=10;

subplot_height=300; % pixel, the height of subplot
subplot_width=450; % pixel, the width of subplot
left_spacing=190; % pixel, the space between subplot and the left things
right_spacing=120; % pixel, the space right of the last column of subplot
upper_spacing=100; % pixel, the space between subplot and the upper things
lower_spacing=30; % pixel, the space below the legend box
legend_height=50; % pixel, the height of legend box

plot_n_col=3; % the column number of subplot
plot_n_row=2; % the row number of subplot


%% init
spec_arr={};

hb_spec=load('epsilon/Hb_1_cm_um_mua.txt');
hbo_spec=load('epsilon/HbO_1_cm_um_mua.txt');

legend_arr={};
for i=1:length(target_name_arr)
%     legend_arr{i}=strrep(target_name_arr{i},'_',' ');
    legend_arr{i}=['subject 5_' num2str(i)];
end
legend_arr{end+1}='Hb';
legend_arr{end+1}='HbO';


%% main

% load the spec
for i=1:length(target_name_arr)
    spec_arr{i}=load(fullfile(input_dir,calib_dir,[target_name_arr{i} '.txt']));    
end

% use the first spec as the baseline
baseline_spec=spec_arr{1};
delta_OD_arr={};
for i=1:length(target_name_arr)
    delta_OD_arr{i}=log(spec_arr{i}./baseline_spec);
end

% plot the delta OD
fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');
for s=1:num_SDS
    row_index=ceil(s/plot_n_col);
    col_index=s-(row_index-1)*plot_n_col;
    axes;
    hold on;
    for i=1:length(target_name_arr)
        plot(spec_arr{i}(:,1),delta_OD_arr{i}(:,s+1),'LineWidth',lineWidth);
    end
    xlabel('wavelength(nm)');
    ylabel('\DeltaOD');
    title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm']);
    grid on;
    yyaxis right;
    plot(hb_spec(:,1),hb_spec(:,2));
    plot(hbo_spec(:,1),hbo_spec(:,2));
    ylabel('\mu_a');
    xlim([min(spec_arr{i}(:,1)) max(spec_arr{i}(:,1))]);
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    if s==num_SDS
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
    end
    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);

end
print(fullfile(input_dir,calib_dir,'deltaOD_2.png'),'-dpng','-r200');
close all;
disp('Done!');