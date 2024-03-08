%{
plot the subject CV spec

Benjamin Kao
Last update: 2021/01/21
%}

clc;clear;close all;

%% param
input_dir='extracted_subject_spec_2';
% target_name_arr={'tc','ww','wh','yf','kb'}; % the targets
target_name_arr={'tc','ww','yf'}; % the targets
num_SDS=6;
SDS_length_arr=[0.8 1.5 2.12 3 3.35 4.5]; % cm

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
CV_spec_arr=[];

hb_spec=load('epsilon/Hb_1_cm_um_mua.txt');
hbo_spec=load('epsilon/HbO_1_cm_um_mua.txt');

% legend_arr={};
% for i=1:length(target_name_arr)
%     legend_arr{i}=['subject ' num2str(i)];
% end

legend_arr={'subject 1','subject 2','subject 4'};


%% main

% load the CV spec
for i=1:length(target_name_arr)
    CV_spec_arr(:,:,i)=load(fullfile(input_dir,[target_name_arr{i} '_CV.txt']));    
end

% plot the CV
fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
set(fig, 'visible', 'off');
for s=1:num_SDS
    row_index=ceil(s/plot_n_col);
    col_index=s-(row_index-1)*plot_n_col;
    axes;
    hold on;
    for i=1:length(target_name_arr)
        plot(CV_spec_arr(:,1,i),CV_spec_arr(:,s+1,i)*100,'LineWidth',lineWidth);
    end
    xlabel('wavelength(nm)');
    ylabel('CV(%)');
    title(['SDS ' num2str(SDS_length_arr(s)) ' cm']);
    grid on;
    xlim([700 900]);
%     xlim([min(CV_spec_arr{i}(:,1)) max(CV_spec_arr{i}(:,1))]);
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    if s==num_SDS
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
    end
    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);

end
print(fullfile(input_dir,'subjectCV_2.png'),'-dpng','-r200');
close all;
disp('Done!');