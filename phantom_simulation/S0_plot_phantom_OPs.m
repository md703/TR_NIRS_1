%{
Simulate the MCML lookup table (for using different mua and mus to forward the phantom spectrum)
please compile a 'mus_to_sim.txt' in the output dir

Benjamin Kao
Last update: 2021/01/05
%}

clc;clear;close all;

%% param
OP_dir='epsilon';
mua_file='mua_FDA_cm.txt';
mus_file='musp_cm.txt';
num_phantom=6;

fontSize=18;
lineWidth=2;

%% main
legend_arr={};
for i=1:num_phantom
    legend_arr{i}=['phantom ' num2str(i)];
end

figure('Units','pixels','position',[0 0 1000 500]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none'); 

% mua
nexttile();
temp_param=load(fullfile(OP_dir,mua_file));
plot(temp_param(:,1),temp_param(:,2:end),'LineWidth',lineWidth);
legend(legend_arr,'Location','northwest');
% title('\mu_a (1/cm)');
grid on;
xlabel('wavelength(nm)');
ylabel('\mu_a (1/cm)');
set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');

% musp
nexttile();
temp_param=load(fullfile(OP_dir,mus_file));
plot(temp_param(:,1),temp_param(:,2:end),'LineWidth',lineWidth);
legend(legend_arr,'Location','northeast');
grid on;
xlabel('wavelength(nm)');
ylabel('\mu_s''(1/cm)');
set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');

print(fullfile(OP_dir,'plot_phantom_OP.png'),'-dpng','-r200');