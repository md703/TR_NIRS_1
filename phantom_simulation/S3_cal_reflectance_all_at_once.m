%{
Calculate the reflectance from simulated phantom spec using WMC and all phantom at once.
( find the unique musp to simulate )

Benjamin Kao
Last update: 2021/01/17
%}

clc;clear;close all;

%% param
num_SDS=7;
num_to_sim=70; % how many mus set had been simulated
sim_g=0.0; % the g used to simulate the table

input_dir='MCML_sim_lkt'; % the simulated lookup table folder
output_dir='cal_reflectance_2'; % the output dir to put the reflectance in

sim_wl=(650:2:1000)'; % the wavelength to output simulate spectrum

param_dir='epsilon_add7EK'; % the folder containing the OPs of phantoms
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
sim_PL_arr=cell(length(sim_mus_arr),num_SDS);
each_photon_weight_arr=[];

for mus=1:length(sim_mus_arr)
    temp=load(fullfile(input_dir,['run_' num2str(mus)],'sim_PL_merge.mat'));
    for s=1:num_SDS
        sim_PL_arr{mus,s}=temp.PL_arr{s};
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

for s=1:num_SDS
    fprintf('run SDS %d\n',s);
    for i=1:num_phantom
        temp_mus_ref_arr=zeros(length(sim_mus_arr),length(ph_mua_arr(:,i))); % sim lut mus * num of ph mua;
        for mus=1:length(sim_mus_arr)
            temp_mus_ref_arr(mus,:)=sum(sim_PL_arr{mus,s}(:,1).*exp(-1*sim_PL_arr{mus,s}(:,2).*transpose(ph_mua_arr(:,i))),1)./each_photon_weight_arr(mus,s);
        end
        for wl=1:length(sim_wl)
            fprintf('\tph %d wl %d\n',i,wl);
            temp_mus_ref=smooth(temp_mus_ref_arr(:,wl));
            int_ref=interp1(sim_mus_arr,temp_mus_ref,ph_mus_arr(wl,i),'pchip');
            plot(sim_mus_arr,temp_mus_ref,ph_mus_arr(wl,i),int_ref,'x');
            title(['ph ' num2str(i) ' wl ' num2str(wl) ' SDS ' num2str(s)]);
            set(gca,'YScale','log');
            drawnow;
            ph_spec_arr{i}(wl,s)=int_ref;
        end
    end
end

%% save
mkdir(input_dir,output_dir);
for i=1:num_phantom
    to_save=[sim_wl ph_spec_arr{i}];
    save(fullfile(input_dir,output_dir,['phantom_' num2str(i) '_spec.txt']),'to_save','-ascii','-tabs');
end

copyfile(fullfile(param_dir,using_mua_file),fullfile(input_dir,output_dir,using_mua_file));
copyfile(fullfile(param_dir,using_mus_file),fullfile(input_dir,output_dir,using_mus_file));

disp('Done!');