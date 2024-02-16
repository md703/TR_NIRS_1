%{
Use the spectral resolution to dilate the simulation spectrum

Benjamin Kao
Last update: 2021/01/17
%}

clc;clear;close all;

%% param
input_dir='MCML_sim_lkt/cal_reflectance_2'; % the folder containing the simulated reflectance
output_dir='MCML_sim_lkt/dilated';
num_ph=6;
num_SDS=6;
spectralRes=3.8; % the spectral resolution (fwhm) in nm

fontSize=12;

%% init
mkdir(output_dir);

% make a spectral resolution kernal for convolution

x_axis=-10:0.01:10;
conv_kernal=normpdf(x_axis,0,spectralRes/2.355);
conv_kernal=conv_kernal/max(conv_kernal);
plot(x_axis,conv_kernal);
grid on;
hold on;
plot(spectralRes/2,interp1(x_axis,conv_kernal,spectralRes/2),'ro');
plot(-spectralRes/2,interp1(x_axis,conv_kernal,-spectralRes/2),'ro');
xline(spectralRes/2);
xline(-spectralRes/2);
yline(0.5);
xxticks=xticks();
xxticks=sort([xxticks spectralRes/2 -spectralRes/2]);
xticks(xxticks);
xlabel('wavelength(nm)');
print(fullfile(output_dir,['kernal_smooth.png']),'-dpng','-r200');


figure();
x_axis=-10:1:10;
conv_kernal=normpdf(x_axis,0,spectralRes/2.355);
conv_kernal=conv_kernal/sum(conv_kernal);
plot(x_axis,conv_kernal);
grid on;
hold on;
xline(spectralRes/2);
xline(-spectralRes/2);
yline(max(conv_kernal)/2);
xxticks=xticks();
xxticks=sort([xxticks spectralRes/2 -spectralRes/2]);
xticks(xxticks);
xlabel('wavelength(nm)');
print(fullfile(output_dir,['kernal_discrete.png']),'-dpng','-r200');

close all;

legend_arr={'original','convoluted'};

%% main
for i=1:num_ph
    orig_spec=load(fullfile(input_dir,['phantom_' num2str(i) '_spec.txt']));
    orig_spec=interp1(orig_spec(:,1),orig_spec,min(orig_spec(:,1)):max(orig_spec(:,1)));
    dilated_spec=orig_spec(:,1);
    figure('Position',[0 0 1600 900]);
    ti=tiledlayout('flow','TileSpacing','compact');
    for s=1:num_SDS
        nexttile();
        dilated_spec(:,s+1)=conv(orig_spec(:,s+1),conv_kernal,'same');
        plot(orig_spec(:,1),[orig_spec(:,s+1) dilated_spec(:,s+1)]);
        grid on;
        legend(legend_arr,'Location','northwest');
        title(['SDS ' num2str(s)]);
        ylabel('reflectance');
        xlabel('wavelength(nm)');
        set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
    end
    title(ti,['phantom ' num2str(i)], 'FontName', 'Times New Roman');
    print(fullfile(output_dir,['ph_' num2str(i) '.png']),'-dpng','-r200');
    close all;
    
    save(fullfile(output_dir,['phantom_' num2str(i) '_spec.txt']),'dilated_spec','-ascii','-tabs');
end

disp('Done!');