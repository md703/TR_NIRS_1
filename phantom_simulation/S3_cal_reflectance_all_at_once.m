%{
Calculate the reflectance from simulated phantom spec using WMC and all phantom at once.
( find the unique musp to simulate )

Benjamin Kao
Last update: 2021/01/17
%}

clc;clear;close all;

%% param
num_SDS=5;
num_gate=10;
num_to_sim=6; % how many mus set had been simulated
sim_g=0.0; % the g used to simulate the table

input_dir='MCML_sim_lkt_2'; % the simulated lookup table folder
output_dir='cal_reflectance_2'; % the output dir to put the reflectance in

sim_wl=800; % the wavelength to output simulate DTOF
% sim_wl=(650:2:1000)'; % the wavelength to output simulate spectrum

SDS_dist_arr=[1.5 2.2 2.9 3.6 4.3]; % cm

param_dir='epsilon'; % the folder containing the OPs of phantoms
using_mua_file='mua_FDA_cm.txt'; % the mua file for the phantoms
using_mus_file='musp_cm.txt'; % the mus file for the phantoms

use_par_mode=0; % use parallel mode to calculate the reflectance

%% init
sim_mus_arr=load(fullfile(input_dir,'mus_to_sim.txt'));

assert(length(sim_mus_arr)==num_to_sim);

ph_mua_arr=load(fullfile(param_dir,using_mua_file));
ph_mus_arr=load(fullfile(param_dir,using_mus_file));

ph_mua_arr=interp1(ph_mua_arr(:,1),ph_mua_arr(:,2:end),sim_wl);
ph_mus_arr=interp1(ph_mus_arr(:,1),ph_mus_arr(:,2:end),sim_wl);
ph_mus_arr=ph_mus_arr./(1-sim_g);

num_phantom=size(ph_mua_arr,2);

fprintf('Starting loading files: ');
load_timer=tic;
sim_PL_arr=cell(length(sim_mus_arr),num_gate,num_SDS);
each_photon_weight_arr=[];

for mus=1:length(sim_mus_arr)
    temp=load(fullfile(input_dir,['run_' num2str(mus)],'sim_PL_merge.mat'));
    for s=1:num_SDS
        for g=1:num_gate
            sim_PL_arr{mus,g,s}=temp.PL_arr{g,s};
        end
    end
    each_photon_weight_arr(mus,:)=temp.each_photon_weight_arr;
end
load_timer=toc(load_timer);
fprintf('... Done! Cost %.2f secs.\n',load_timer);

%% main
ph_spec_arr=cell(1,num_phantom);
for i=1:num_phantom
    ph_spec_arr=[];
end

figure('Units','pixels','Position',[0 0 1920 360]);
ti=tiledlayout(1,num_SDS);
for s=1:num_SDS
    nexttile;
    fprintf('run SDS %d\n',s);
    for i=1:num_phantom
        for g=1:num_gate
            ref_arr(i,g,s)=sum(sim_PL_arr{i,g,s}(:,1).*exp(-1*sim_PL_arr{i,g,s}(:,2).*transpose(ph_mua_arr(:,i))),1)./each_photon_weight_arr(i,s);
        end

        plot(1:1:num_gate,ref_arr(i,:,s),'Linewidth',2);
        hold on
        set(gca,'YScale','log');
        ph_dtof_arr{i}(:,s)=squeeze(ref_arr(i,:,s));
        
    end
    title(['SDS ' num2str(SDS_dist_arr(s)) ' cm']);
    xlabel('Time gate');
    ylabel('reflectance');
    legend('ph1','ph2','ph3','ph4','ph5','ph6');
end
print(fullfile(input_dir,'plot_phantom_spec.png'),'-dpng','-r200');

%% save
mkdir(input_dir,output_dir);
for i=1:num_phantom
    to_save=ph_dtof_arr{i};
    save(fullfile(input_dir,output_dir,['phantom_' num2str(i) '_TPSF.txt']),'to_save','-ascii','-tabs');
end

copyfile(fullfile(param_dir,using_mua_file),fullfile(input_dir,output_dir,using_mua_file));
copyfile(fullfile(param_dir,using_mus_file),fullfile(input_dir,output_dir,using_mus_file));

disp('Done!');