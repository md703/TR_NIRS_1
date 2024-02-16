%{
Plot the result of MCML simulation

Benjamin Kao
Last update: 2021/01/05
%}

clc;clear;close all;

%% param
input_dir='MCML_sim_lkt/dilated'; % the folder containing the phantom spectra
num_ph=6;
num_SDS=6;
SDS_dist_arr=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm

fontSize=18;
lineWidth=2;
lgdFontSize=18;
lgdNumCol=11;

subplot_height=300; % pixel, the height of subplot
subplot_width=450; % pixel, the width of subplot
left_spacing=80; % pixel, the space between subplot and the left things
right_spacing=50; % pixel, the space right of the last column of subplot
upper_spacing=110; % pixel, the space between subplot and the upper things
lower_spacing=20; % pixel, the space below the legend box
legend_height=45; % pixel, the height of legend box
plot_n_col=3; % the column number of subplot
plot_n_row=2; % the row number of subplot
%% main
legend_arr={};
for i=1:num_ph
    legend_arr{i}=['phantom ' num2str(i)];
end

spec_arr={};
for i=1:num_ph
    spec_arr{i}=load(fullfile(input_dir,['phantom_' num2str(i) '_spec.txt']));
end

% colormap_arr=jet(num_ph);

fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');
% ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
for s=1:num_SDS
    row_index=ceil(s/plot_n_col);
    col_index=s-(row_index-1)*plot_n_col;
    axes;
    hold on;
    to_plot_arr=[];
    for i=1:num_ph
        to_plot_arr(:,i)=spec_arr{i}(:,s+1);
    end
    plot(spec_arr{1}(:,1),to_plot_arr,'LineWidth',lineWidth);
    title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm']);
    grid on;
    xlabel('wavelength(nm)');
    ylabel('reflectance');
    if s==num_SDS
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
    end
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);
end

print(fullfile(input_dir,'plot_phantom_spec.png'),'-dpng','-r200');
close all;
disp('Done!');