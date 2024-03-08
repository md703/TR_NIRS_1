%{
Simulate the MCML lookup table (for using different mua and mus to forward the phantom spectrum)
please compile a 'mus_to_sim.txt' in the output dir

Benjamin Kao
Last update: 2020/10/15
%}

clc;clear;close all;

%% param
output_dir='MCML_sim_lkt'; % the already exist output folder, which containing the mus to simuilate
g=0;
n=1.457;
use_multiple_GPU=1; % =1 if you want to use multi-GPU to simulate
GPU_available=[1 1]; % which GPU on the multi-GPU computer to use
do_GPU_setting=0; % =1 if you don't use multi-GPU, and want to use certain GPU
GPU_index=0; % the index of certain GPU to use, start from 0
to_sim_index=1:6; % the index to simulate

sim_setting_file='sim_setup_new_param.json';


%% init
mus_to_sim=load(fullfile(output_dir,'mus_to_sim.txt'));
assert(max(to_sim_index)<=length(mus_to_sim),'to sim index set error!');
mother_dir=pwd;

%% main

if use_multiple_GPU==1
    %% multi-GPU
    simed_index=zeros(length(to_sim_index),1);
    GPU_sim_num_count=zeros(1,length(GPU_available));
    can_use_GPU_index=find(GPU_available==1);
    
    p=parpool('local',1+length(can_use_GPU_index));
    
    spmd
        if labindex==1
            target_lab_index=2;
            while target_lab_index<=numlabs
                if labProbe(target_lab_index)~=0 % target lab is sending message
                    receive_data=labReceive(target_lab_index);
                    if receive_data>1 % if the simulation is finished
                        GPU_sim_num_count(can_use_GPU_index(receive_data-1))=GPU_sim_num_count(can_use_GPU_index(receive_data-1))+1;
                        target_sim_index=find(simed_index==0);
                        if length(target_sim_index)==0
                            break;
                        end
                        if exist('stop_flag.txt','file')~=0
                            temp_flag=load('stop_flag.txt');
                            if temp_flag==1
                                break;
                            end
                        end
                        target_sim_index=target_sim_index(1);
                        labSend(to_sim_index(target_sim_index),target_lab_index); % send the to simulate index to the target lab
                        simed_index(target_sim_index)=1;
                    end
                end
                
                target_lab_index=target_lab_index+1;
                if target_lab_index>numlabs
                    target_lab_index=2;
                end
                pause(0.3);
            end
            for target_lab_index=2:numlabs % send the terminate simulation signal
                if labProbe(target_lab_index)==1
                    labReceive(target_lab_index);
                end
                labSend(-2,target_lab_index);
            end
        else
            labSend(labindex,1); % send simulated complete signal to lab 1
            temp_sim_index=labReceive(1);
            while temp_sim_index~=-2
                fprintf('simulate wl %d using GPU %d\n',temp_sim_index,can_use_GPU_index(labindex-1));
                wl_folder=fullfile(output_dir,['run_'  num2str(temp_sim_index)]);
                mkdir(wl_folder);
                temp_param=[0 mus_to_sim(temp_sim_index) n g];
                cd(wl_folder);
                fid=fopen('GPUMC_input.txt','w');
                fprintf(fid,'%f\t%f\t%f\t%f',0,mus_to_sim(temp_sim_index),n,g);
                fclose(fid);
                if isunix
                    [~,~]=system(['../../MCML_GPU ../../' sim_setting_file ' GPUMC_input.txt GPUMC_output.txt -G ' num2str(can_use_GPU_index(labindex-1)-1) ' -R -P -B']); % -1 because cuda GPU start from 0
                elseif ispc
                    [~,~]=system(['..\..\MCML_GPU.exe ..\..\' sim_setting_file ' GPUMC_input.txt GPUMC_output.txt -G ' num2str(can_use_GPU_index(labindex-1)-1) ' -R -P -B']); % -1 because cuda GPU start from 0
                end
                cd(mother_dir);
                labSend(labindex,1);
                temp_sim_index=labReceive(1);
            end
        end
    end
    
    GPU_sim_num_count=GPU_sim_num_count{1};
    
    delete(gcp); % close the parpool
    
else
    %% single-GPU
    for wl=to_sim_index
        fprintf('sim wl %d\n',wl);
        wl_folder=fullfile(output_dir,['run_'  num2str(wl)]);
        mkdir(wl_folder);
        temp_param=[0 mus_to_sim(wl) n g];
        cd(wl_folder);
        save('GPUMC_input.txt','temp_param','-ascii','-tabs');
        if isunix
            if do_GPU_setting
                [~,~]=system(['../../MCML_GPU ../../' sim_setting_file ' GPUMC_input.txt GPUMC_output.txt -G ' num2str(GPU_index) ' -R -P -B']);
            else
                [~,~]=system(['../../MCML_GPU ../../' sim_setting_file ' GPUMC_input.txt GPUMC_output.txt -R -P -B']);
            end
        elseif ispc
            if do_GPU_setting
                [~,~]=system(['..\..\MCML_GPU.exe ..\..\' sim_setting_file ' GPUMC_input.txt GPUMC_output.txt -G ' num2str(GPU_index) ' -R -P -B']);
            else
                [~,~]=system(['..\..\MCML_GPU.exe ..\..\' sim_setting_file ' GPUMC_input.txt GPUMC_output.txt -R -P -B']);
            end
        end
        cd(mother_dir);
    end
    
end

copyfile(sim_setting_file,fullfile(output_dir,sim_setting_file));
disp('Done!');
