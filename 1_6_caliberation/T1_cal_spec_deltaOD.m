%{
calculate the delta OD of the extracted measured spectrum

Benjamin Kao
Last update: 2021/02/07
%}

clc;clear;close all;

%% param
input_dir='20201209_test_14'; % the folder of the experiment
target_name_prefix='tc_'; % the name of the target to plot
target_index=[6:10]; % the index to plot
output_name='tc_dOD_6_10'; % the saved picture name
num_SDS=6; % number of SDS
to_plot_SDS=[2 4]; % the index of the SDS to plot
wavelength_boundary=[536.0026 1094.5]; % the min and max wavelength of the camera
to_plot_wl=[700 800 900]; % the wavelength range to output spectrum, calculate CV or plot the figure
camera_x_pixel=160;

%% init
wavelength=interp1([1 camera_x_pixel],wavelength_boundary,1:camera_x_pixel)';

target_spec_arr=cell(1,num_SDS);
for s=1:num_SDS
    target_spec_arr{s}=[];
end

%% main
each_measure_times_arr=[];
for i=1:length(target_index)
    temp_measure_spec=load(fullfile(input_dir,['SDS_spec_arr_' target_name_prefix num2str(target_index(i)) '.mat']));
    for s=1:num_SDS
        if i==1
            each_measure_times_arr(s)=size(temp_measure_spec.SDS_spec_arr{s},2);
        end
        target_spec_arr{s}=[target_spec_arr{s} double(temp_measure_spec.SDS_spec_arr{s})];
    end
end

dOD_arr=cell(1,num_SDS);
for s=1:num_SDS
    target_spec_arr{s}=interp1(wavelength,target_spec_arr{s},to_plot_wl);
    dOD_arr{s}=log(target_spec_arr{s}./target_spec_arr{s}(:,1));
end

to_plot_point_arr={};
for s=1:num_SDS
    for i=1:length(target_index)
        to_plot_point_arr{s}(i,:)=(each_measure_times_arr(s)*(i-1)+1):(each_measure_times_arr(s)*i);
    end
end

legend_arr={};
for i=1:length(target_index)
    legend_arr{i}=['measure ' num2str(i)];
end

%% plot
figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
for s=1:length(to_plot_SDS)
    for wl=1:length(to_plot_wl)
        nexttile();
        hold on;
        for i=1:length(target_index)
            plot(to_plot_point_arr{to_plot_SDS(s)}(i,:),dOD_arr{to_plot_SDS(s)}(wl,to_plot_point_arr{to_plot_SDS(s)}(i,:)),'o-');
        end
        lgd=legend(legend_arr,'Location','southoutside');
        lgd.NumColumns = length(target_index);
        title([num2str(to_plot_wl(wl)) ' nm, SDS ' num2str(to_plot_SDS(s))]);
        ylabel('\DeltaOD');
        grid on;
    end
end

print(fullfile(input_dir,[output_name '.png']),'-dpng','-r300');
% saveas(gcf,fullfile(input_dir,[output_name '.png']));
close all;
disp('Done!');