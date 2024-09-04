%{
Fit the target TPSF with convolution of simulated TPSF and IRF.

Ting-Yi Kuo
Last update: 2024/05/03
%}

clc;clear;close all;

%% param
global num_SDS num_gate target_TPSF lkt_mus_table scale_size IRF start_index end_index fitting_SDS  sim_PL_arr_1 sim_PL_arr_2 sim_each_photon_weight_arr RMSPE
lkt_dir='../2_1_phantom_simulation/MCML_sim_lkt';
target_folder='20240612/phantom_3_10_6_530';
fitting_phantom=3;

fitting_SDS=[1 2];

num_SDS=2;
num_gate=200;

%% init
output_dir='fittingSDS_';
for s=1:length(fitting_SDS)
    output_dir=[output_dir num2str(fitting_SDS(s))];
end
mkdir(fullfile(target_folder,output_dir));

% lkt_mus_table=load(fullfile('../phantom_simulation/MCML_sim_lkt','mus_to_sim.txt'));
lkt_mus_table=load(fullfile(lkt_dir,'mus_to_sim.txt'));
lkt_mus_table=lkt_mus_table';

         % mus1 mua1
init_param=[20  0.08];
Ubound=    [40  0.14];
Lbound=    [1   0.02];
scale_size=[0.5  0.1];

param_init=init_param./scale_size;
LLbound=Lbound./scale_size;
UUbound=Ubound./scale_size;

target_TPSF=load(fullfile(target_folder,'SDS_orig_TPSF.txt'));
max_value=max(target_TPSF);
target_TPSF=target_TPSF./max_value;

IRF=load(fullfile(target_folder,'IRF_orig_TPSF.txt'));

%% main
for t=1:size(target_TPSF,2)
    start_value=1*0.5;
    end_value=1*0.005;
    start_index(1,t)=find(target_TPSF(:,t)>=start_value,1);
    end_index(1,t)=find(target_TPSF(:,t)>=start_value,1,'last');
end

sim_PL_arr_1={};
sim_PL_arr_2={};
for lkt_index=1:size(lkt_mus_table,1)
    fprintf(['Loading ' num2str(lkt_index) '/' num2str(size(lkt_mus_table,1)) '\n'])
    temp_PL=load(fullfile(lkt_dir,['run_' num2str(lkt_index)],'sim_PL_merge.mat'));
    if lkt_index<=20
        for s=1:num_SDS
            sim_PL_arr_1(lkt_index,num_gate*(s-1)+1:num_gate*s)=temp_PL.PL_arr(:,s)';
        end
    else
        for s=1:num_SDS
            sim_PL_arr_2(lkt_index,num_gate*(s-1)+1:num_gate*s)=temp_PL.PL_arr(:,s)';
        end
    end
%     sim_PL_arr(:,:,lkt_index)=temp_PL.PL_arr;
    sim_each_photon_weight_arr(lkt_index,:)=temp_PL.each_photon_weight_arr;
end
%%
[init_TPSF,~]=fun_forward_calError_chooseSDS(init_param);
init_error=RMSPE;

%%
% options = optimoptions('fmincon','Algorithm','sqp','Display','iter','DiffMinChange',5*10^-4,'OptimalityTolerance',1e-7,'ConstraintTolerance',1e-9,'StepTolerance',1e-10,'MaxFunctionEvaluations',round(100*length(param_init)*1.5)); % increase the min step size for finding gradients
options = optimoptions('fmincon','Algorithm','sqp','Display','iter','DiffMinChange',5*10^-2,'OptimalityTolerance',1e-7,'ConstraintTolerance',1e-9,'StepTolerance',1e-5,'MaxFunctionEvaluations',round(100*length(param_init)*1.5)); % increase the min step size for finding gradients
% options = optimoptions('fmincon','Algorithm','sqp','Display','iter','DiffMinChange',5*10^-5,'OptimalityTolerance',1e-7,'ConstraintTolerance',1e-9,'StepTolerance',1e-10,'MaxFunctionEvaluations',round(100*length(param_init)*1.5)); % increase the min step size for finding gradients
fitted_param=fmincon(@fun_scale_param_error,param_init,[],[],[],[],LLbound,UUbound,[],options);

fitted_param=fitted_param.*scale_size;
fprintf(['mus=' num2str(fitted_param(1)) ' ,mua=' num2str(fitted_param(2)) '\n']);
[fitted_TPSF,~]=fun_forward_calError_chooseSDS(fitted_param);
fitting_error=RMSPE;

mua_ans=load(fullfile('20240502','cal_reflectance_200','mua_FDA_cm.txt'));
mus_ans=load(fullfile('20240502','cal_reflectance_200','musp_cm.txt'));

wavelength=800;
op_ans(1,1)=interp1(mus_ans(:,1),mus_ans(:,fitting_phantom+1),wavelength);
op_ans(1,2)=interp1(mua_ans(:,1),mua_ans(:,fitting_phantom+1),wavelength);

OP_error=(fitted_param-op_ans)./op_ans;
fprintf('OP error=%.2f%%, %.2f%%\n',100*OP_error(1),100*OP_error(2));

save(fullfile(target_folder,output_dir,'fitting_info.mat'),'target_TPSF','start_index','end_index','init_param','init_TPSF','init_error','fitted_param','fitted_TPSF','fitting_error','OP_error')
fprintf('Done!\n');



function output=fun_scale_param_error(param_init)
global scale_size;
[~,output]=fun_forward_calError_chooseSDS(param_init.*scale_size);
end

function [pred_TPSF,output]=fun_forward_calError_chooseSDS(param_arr)
global num_SDS num_gate lkt_mus_table IRF target_TPSF start_index end_index fitting_SDS sim_PL_arr_1 sim_PL_arr_2 sim_each_photon_weight_arr RMSPE
for lkt_index=1:size(lkt_mus_table,1)
%     temp_PL=load(fullfile(lkt_dir,['run_' num2str(lkt_index)],'sim_PL_merge.mat'));
%     for s=1:num_SDS
%         sim_PL_arr(num_gate*(s-1)+1:num_gate*s)=temp_PL.PL_arr(:,s)';
%     end
% 
%     for s=1:num_SDS*num_gate
%         ref_arr(lkt_index,s)=sum(sim_PL_arr{s}(:,1).*exp(-1*sim_PL_arr{s}(:,2).*param_arr(2)),1)./each_photon_weight_arr(1);
%     end
    if lkt_index<=20
        for s=1:num_SDS*num_gate
            ref_arr(lkt_index,s)=sum(sim_PL_arr_1{lkt_index,s}(:,1).*exp(-1*sim_PL_arr_1{lkt_index,s}(:,2).*param_arr(2)),1)./sim_each_photon_weight_arr(lkt_index,ceil(s/num_gate));
        end
    else
        for s=1:num_SDS*num_gate
            ref_arr(lkt_index,s)=sum(sim_PL_arr_2{lkt_index,s}(:,1).*exp(-1*sim_PL_arr_2{lkt_index,s}(:,2).*param_arr(2)),1)./sim_each_photon_weight_arr(lkt_index,ceil(s/num_gate));
        end
    end
end

temp_interp_TPSF=interp1(lkt_mus_table,ref_arr,param_arr(1));
    
for s=1:num_SDS
    interp_TPSF(:,s)=temp_interp_TPSF(num_gate*(s-1)+1:num_gate*s);
    pred_TPSF(:,s)=conv(interp_TPSF(:,s),IRF(:,s));
end

max_value=max(pred_TPSF);
pred_TPSF=pred_TPSF./max_value;

RMSPE=[];
fprintf('RMSPE: ');
for i=fitting_SDS
    error=(target_TPSF(start_index(i):end_index(i),i)-pred_TPSF(start_index(i):end_index(i),i))./pred_TPSF(start_index(i):end_index(i),i);
    RMSPE(end+1)=sqrt(mean(error.^2));
    fprintf('%.2f%%, ',100*RMSPE(:,i));
end
fprintf(', total=');

mean_RMSPE=mean(RMSPE);
fprintf('%.2f%%\n',100*mean_RMSPE);

output=mean_RMSPE;
end
