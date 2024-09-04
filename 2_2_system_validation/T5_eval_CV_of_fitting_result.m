%{
Evaluate the variation of fitted result by fitting the measured TPSFs
at same condition.

Ting-Yi Kuo
Last update: 2024/05/06
%}

clc;clear;close all;

%% param
global num_SDS num_gate target_TPSF lkt_mus_table scale_size IRF start_index end_index sim_PL_arr_1 sim_PL_arr_2 sim_each_photon_weight_arr final fitting_error
lkt_dir='../phantom_simulation/MCML_sim_lkt';
target_mother_folder='20240507/phantom_3';
target_folder={'SDS1_0.25s','SDS1_1.5s','SDS1_15s'}; %
fitting_phantom=3;

num_SDS=2;
num_gate=200;

%% init
% lkt_mus_table=load(fullfile('../phantom_simulation/MCML_sim_lkt','mus_to_sim.txt'));
lkt_mus_table=load(fullfile(lkt_dir,'mus_to_sim.txt'));
lkt_mus_table=lkt_mus_table';

         % mus1 mua1
param_init=[20  0.08];
Ubound=    [40  0.14];
Lbound=    [1   0.02];
scale_size=[0.5  0.1];

param_init=param_init./scale_size;
LLbound=Lbound./scale_size;
UUbound=Ubound./scale_size;

fitting_error=[];
OP_error=[];

%% main
%% Load PL data
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


%% load answer

mua_ans=load(fullfile('20240502','cal_reflectance_200','mua_FDA_cm.txt'));
mus_ans=load(fullfile('20240502','cal_reflectance_200','musp_cm.txt'));

wavelength=800;
op_ans(1,1)=interp1(mus_ans(:,1),mus_ans(:,fitting_phantom+1),wavelength);
op_ans(1,2)=interp1(mua_ans(:,1),mua_ans(:,fitting_phantom+1),wavelength);


%% Start fitting
for f=1:length(target_folder)
    % load target TPSF
    folder=target_folder{f};
    temp_target_TPSF=load(fullfile(target_mother_folder,folder,[folder '_norm_TPSF_collect.txt']));
    max_value=max(temp_target_TPSF);
    temp_target_TPSF=temp_target_TPSF./max_value;

    for t=1:size(temp_target_TPSF,2)
        start_value=1*0.5;
        end_value=1*0.0001;
        temp_start_index(1,t)=find(temp_target_TPSF(:,t)>=start_value,1);
        temp_end_index(1,t)=find(temp_target_TPSF(:,t)>=start_value,1,'last');
    end

    IRF=load(fullfile(target_mother_folder,'IRF_orig_TPSF.txt'));

    for i=1:size(temp_target_TPSF,2)
        final=0;
        target_TPSF=temp_target_TPSF(:,i);
        start_index=temp_start_index(1,i);
        end_index=temp_end_index(1,i);

        % options = optimoptions('fmincon','Algorithm','sqp','Display','iter','DiffMinChange',5*10^-4,'OptimalityTolerance',1e-7,'ConstraintTolerance',1e-9,'StepTolerance',1e-10,'MaxFunctionEvaluations',round(100*length(param_init)*1.5)); % increase the min step size for finding gradients
        options = optimoptions('fmincon','Algorithm','sqp','Display','iter','DiffMinChange',5*10^-2,'OptimalityTolerance',1e-7,'ConstraintTolerance',1e-9,'StepTolerance',1e-5,'MaxFunctionEvaluations',round(100*length(param_init)*1.5)); % increase the min step size for finding gradients
        param_final=fmincon(@fun_scale_param_error,param_init,[],[],[],[],LLbound,UUbound,[],options);

        param_final=param_final.*scale_size;
        fprintf(['mus=' num2str(param_final(1)) ' ,mua=' num2str(param_final(2)) '\n']);
        final=1;
        output=fun_forward_calError_chooseSDS(param_final);
        
        param(i,:)=param_final;
        OP_error(end+1,:)=(param_final-op_ans)./op_ans;
        fprintf('error=%.2f%%, %.2f%%\n',100*OP_error(end,1),100*OP_error(end,2));
    end

%     OP_error(f,:)=(param_final-op_ans)./op_ans;
    
    fitting_param_CV(f,:)=std(param,[],1)./mean(param,1);
    temp_TPSF_CV=std(temp_target_TPSF,[],2)./mean(temp_target_TPSF,2);
    TPSF_CV(f,:)=min(temp_TPSF_CV);
end

save(fullfile(target_mother_folder,'CV_value.txt'),'fitting_param_CV','-ascii','-tabs')

fprintf('Done!\n');

%% Plot
for f=1:length(target_folder)
    % load target TPSF
    folder=target_folder{f};
    load(fullfile(target_mother_folder,folder,'SDS1_info_record.mat'));
    temp_total_counts=info_record{:,'Integral count'};
    total_counts(f,:)=mean(temp_total_counts);
end

temp_total_counts=repmat(total_counts,1,5);
temp_total_counts=reshape(temp_total_counts',[],1);

figure('Units','Pixels','Position',[0 0 1920 360]);
ti=tiledlayout(1,4);
nexttile;
plot(total_counts,100*TPSF_CV,'Linewidth',2);
set(gca,'Xscale','log');
ylabel('Peak count CV (%)');
xlabel('total counts');

nexttile;
plot(temp_total_counts,100*fitting_error,'o','Linewidth',2);
set(gca,'Xscale','log');
ylabel('fitting error (%)');
xlabel('total counts');

nexttile;
plot(temp_total_counts,100*OP_error(:,1),'o','Linewidth',2)
ylabel('\mu_s error (%)');
yyaxis right
plot(total_counts,100*fitting_param_CV(:,1),'Linewidth',2);
set(gca,'Xscale','log');
xlabel('total counts');
ylabel('CV (%)');

nexttile;
plot(temp_total_counts,100*OP_error(:,2),'o','Linewidth',2)
ylabel('\mu_a error (%)');
yyaxis right
plot(total_counts,100*fitting_param_CV(:,2),'Linewidth',2);
set(gca,'Xscale','log');
xlabel('total counts');
ylabel('CV (%)');

title(ti,['phantom ' num2str(fitting_phantom)]);

print(fullfile(target_mother_folder,'evaluate_CV_of_fitted_result.png'),'-dpng','-r200');

%%
function output=fun_scale_param_error(param_init)
global scale_size;
output=fun_forward_calError_chooseSDS(param_init.*scale_size);
end

function output=fun_forward_calError_chooseSDS(param_arr)
global num_SDS num_gate lkt_mus_table IRF target_TPSF start_index end_index sim_PL_arr_1 sim_PL_arr_2 sim_each_photon_weight_arr final fitting_error
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
    calib_TPSF(:,s)=conv(interp_TPSF(:,s),IRF(:,s));
end

max_value=max(calib_TPSF);
calib_TPSF=calib_TPSF./max_value;

fprintf('RMSPE: ');

error=(target_TPSF(start_index:end_index,1)-calib_TPSF(start_index:end_index,1))./calib_TPSF(start_index:end_index,1);
RMSPE=sqrt(mean(error.^2));

if final==1
    fitting_error(end+1,:)=RMSPE;
end

fprintf('%.2f%%',100*RMSPE);

fprintf(', total=');

mean_RMSPE=mean(RMSPE);
fprintf('%.2f%%\n',100*mean_RMSPE);

output=mean_RMSPE;
end
