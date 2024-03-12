%{
Plot the calibrated error and RR of the calibration

Benjamin Kao
Last update: 2021/01/06
%}


clc; clear; close all;

%% param
input_dir='20201209_test_14'; % the folder of the experiment
num_SDS=5;
num_gate=10;

SDS_dist_arr=[1.5 2.2 2.9 3.6 4.3]; % cm

calib_mode=1; % 1=MCML, 2=MCX

output_folder_arr={'calibration_MCML_2','calibration_MCX'};
calib_mode_arr={'MCML','MCX'};

fontSize=14;
lineWidth=2;

%% main
calib_result=load(fullfile(input_dir,output_folder_arr{calib_mode},'calib_factors.mat'));

legend_arr={};
for s=1:num_SDS
    legend_arr{s}=['SDS = ' num2str(SDS_dist_arr(s)) ' cm'];
end

fig=figure('Units','pixels','position',[0 0 1000 600]);
set(fig, 'visible', 'off');
ti=tiledlayout(1,2,'TileSpacing','compact','Padding','none');

% RMSPE
nexttile();
plot(1:num_gate,calib_result.all_RMSPE_arr(:,:,end),'LineWidth',lineWidth);
xlabel('Wavelength(nm)');
ylabel('Calibrated RMSPE');
% ytickformat('%.2f%%');
set(gca, 'YScale', 'log');
grid on;
legend(legend_arr,'Location','north');
set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');

%% RR
nexttile();
plot(1:num_gate,calib_result.RR_arr(:,:,end),'LineWidth',lineWidth);
xlabel('Wavelength(nm)');
ylabel('Calibrated r^2 value');
grid on;
legend(legend_arr,'Location','southwest');
set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');

print(fullfile(input_dir,output_folder_arr{calib_mode},'calib_effect.png'),'-dpng','-r200');
disp('Done!');