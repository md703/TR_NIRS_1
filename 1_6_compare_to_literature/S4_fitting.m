%{
Fit the baseline target TPSF with two-layered head model.

Ting-Yi Kuo
Last update: 2024/07/01
%}

clc;clear;close all;

%% param
global num_SDS num_gate tr_net tr_param_range target_TPSF start_index end_index fitting_SDS temp_fitted_TPSF temp_fitting_error temp_fitted_param sim_PL_arr_1 sim_PL_arr_2 sim_each_photon_weight_arr lkt_dir
lkt_dir='KB';
fitting_SDS=[2 3 4 5];

output_dir=['test_fitting_' datestr(datetime('now'),'yyyy-mm-dd-HH-MM-ss')];
save_folder='fittingSDS_';
for i=fitting_SDS
    save_folder=[save_folder num2str(i)];
end
save_dir=fullfile(output_dir,save_folder);
mkdir(output_dir,save_folder);

num_SDS=5;
num_gate=10;

%% init
target_TPSF=[];
OP_ans=[0.3 160 0.2 125 0.042 23 0.2 150];

% load(fullfile('model_arrange',[lkt_dir '_tr_model']));  %tr_net tr_param_range
% temp_target_TPSF=fun_ANN_forward(OP_ans,1);

target_info=load(fullfile(lkt_dir,'DTOF.txt'));
OP_ans_arrange=target_info(:,1:8);
temp_target_TPSF=target_info(:,9:end);
for t=1:size(temp_target_TPSF,1)
    for i=1:num_SDS
        target_TPSF_arrange(:,i,t)=temp_target_TPSF(t,(i-1)*num_gate+1:i*num_gate)';
    end
end

%% main
for tr=1:size(target_TPSF_arrange,3)
    for tc=1:size(target_TPSF_arrange,2)
        start_value=max(target_TPSF_arrange(:,tc,tr))*0.5;
        end_value=max(target_TPSF_arrange(:,tc,tr))*0.0001;
        start_index_arrange(tr,tc)=find(target_TPSF_arrange(:,tc,tr)>=start_value,1);
        end_index_arrange(tr,tc)=find(target_TPSF_arrange(:,tc,tr)>=end_value,1,'last');
    end
end

fun_load_lkt_table(lkt_dir);
%%
mus_to_fit=[40 60 80 100 120 140 160 180];
for t=28:size(target_TPSF_arrange,3)
    target_TPSF=target_TPSF_arrange(:,:,t);
    start_index=start_index_arrange(t,:);
    end_index=end_index_arrange(t,:);
    
    for mus=1:length(mus_to_fit)
        [init_param,final_param]=fun_auto_fitting(mus);
        fitted_param(:,:,mus)=temp_fitted_param;
        fitted_TPSF(:,:,mus)=temp_fitted_TPSF;
        fitting_error(:,:,mus)=temp_fitting_error;

        output=fun_forward_calError_chooseSDS(init_param);
        init_TPSF(:,:,mus)=temp_fitted_TPSF;
        init_error(:,:,mus)=temp_fitting_error;
    end
    
    mean_RMSPE=squeeze(mean(fitting_error(1,fitting_SDS,:),2));
    [~,min_index]=min(mean_RMSPE);
    best_fitted_param=fitted_param(:,:,min_index);

%     OP_ans=OP_ans([1 3 5 7 2 4 6 8]);
    OP_ans=OP_ans_arrange(t,:);
    mua_brain_error=abs((best_fitted_param(2)-OP_ans(4))./OP_ans(4));

    save(fullfile(save_dir,['fitting_info_' num2str(t) '.mat']),'target_TPSF','start_index','end_index','init_param','init_TPSF','init_error','fitted_param','fitted_TPSF','fitting_error','min_index','OP_ans','mua_brain_error');

end

%% Plot
% load(fullfile('test_fitting_2024-07-02-17-13-15','fittingSDS_2345','fitting_info.mat'));

xlabelname={'','\mu_{a,scalp}','\mu_{a,skull}','\mu_{a,CSF}','\mu_{a,GM}','','\mu_{s,scalp}','\mu_{s,skull}','\mu_{s,CSF}','\mu_{s,GM}',''};
figure;
tiledlayout('flow');
nexttile;
hold on
yyaxis right
bar(7,100*mua_brain_error,'Linestyle','none','FaceAlpha',0.5);
ylabel('error(%)');
yyaxis left
plot([1 3 5 7],OP_ans(1:4),'--o','LineWidth',1);
plot([2 7],best_fitted_param,'o','Color',[0.8500 0.3250 0.0980],'LineWidth',2);
ylabel('(1/cm)')

xticks([0 1 3 5 7 8]);
xticklabels(xlabelname(1:6));

nexttile;
hold on
plot([1 3 5 7],OP_ans(5:8),'--o','LineWidth',1);
plot(repmat(4,1,length(mus_to_fit)),mus_to_fit,'--o','Color',[0.8500 0.3250 0.0980],'LineWidth',1);
plot(4,mus_to_fit(min_index),'o','Color',[0.8500 0.3250 0.0980],'LineWidth',3);
ylabel('(1/cm)')
xticks([0 1 3 5 7 8]);
xticklabels(xlabelname(6:10));
print(fullfile(save_dir,'fitted_param.png'),'-dpng','-r200');


%% TEST
figure;
tiledlayout('flow');
for s=1:num_SDS
    nexttile;
    semilogy(target_TPSF(:,s));
    hold on;
    semilogy(squeeze(init_TPSF(:,s,min_index)));
    semilogy(squeeze(fitted_TPSF(:,s,min_index)));
    title(['SDS ' num2str(s)]);
    xlabel('time gate');
    ylabel('reflectance');
end
legend('target','initial','fitted');
print(fullfile(save_dir,'fitted_result.png'),'-dpng','-r200');

% % error=(fitted_TPSF(:,:,6)-target_TPSF)./target_TPSF;
% error=[];
% RMSPE=[];
% fprintf('RMSPE: ');
% for s=1:num_SDS
%     error=(log_fitted_TPSF(start_index(s):end_index(s),s,6)-log_target_TPSF(start_index(s):end_index(s),s))./log_target_TPSF(start_index(s):end_index(s),s);
%     RMSPE(:,s)=sqrt(mean(error.^2));
%     fprintf('%.2f%%, ',100*RMSPE(:,s));
% end
% fprintf(', total=\n');
% 
% error=[];
% RMSPE=[];
% fprintf('RMSPE: ');
% for s=1:num_SDS
%     error=(log_init_TPSF(start_index(s):end_index(s),s)-log_target_TPSF(start_index(s):end_index(s),s))./log_target_TPSF(start_index(s):end_index(s),s);
%     RMSPE(:,s)=sqrt(mean(error.^2));
%     fprintf('%.2f%%, ',100*RMSPE(:,s));
% end
% fprintf(', total=');

%% functions
function [param_init, param_final]=fun_auto_fitting(mus)
global scale_size final sim_PL_arr_1 lkt_dir num_SDS num_gate sim_each_photon_weight_arr
lkt_mus_table=load(fullfile([lkt_dir '_lookup'],'mus_table.txt'));
fprintf(['Loading ' num2str(mus) '/' num2str(size(lkt_mus_table,1)) '\n']);

sim_PL_arr_1={};
temp_PL=load(fullfile([lkt_dir '_lookup'],['sim_' num2str(mus)],'PL_1.mat'));
for s=1:num_SDS
    sim_PL_arr_1(1,num_gate*(s-1)+1:num_gate*s)=temp_PL.SDS_detpt_arr(:,s)';
end
sim_each_photon_weight_arr(1,:)=temp_PL.each_photon_weight_arr;

         % mus mua1 mua1 mua2 mua2 mua2
param_init=[0.25 0.2];
% param_init=[10  0.09];
Ubound=    [0.5 0.5];
Lbound=    [0.01 0.01];
scale_size=[0.1 0.1];

init_param=param_init./scale_size;
LLbound=Lbound./scale_size;
UUbound=Ubound./scale_size;

% options = optimoptions('fmincon','Algorithm','sqp','Display','iter','DiffMinChange',5*10^-4,'OptimalityTolerance',1e-7,'ConstraintTolerance',1e-9,'StepTolerance',1e-10,'MaxFunctionEvaluations',round(100*length(param_init)*1.5)); % increase the min step size for finding gradients

options = optimoptions('fmincon','Algorithm','sqp','Display','iter','DiffMinChange',5*10^-2,'OptimalityTolerance',1e-7,'ConstraintTolerance',1e-9,'StepTolerance',1e-5,'MaxFunctionEvaluations',round(100*length(param_init)*1.5)); % increase the min step size for finding gradients

param_final=fmincon(@fun_scale_param_error,init_param,[],[],[],[],LLbound,UUbound,[],options);

param_final=param_final.*scale_size;
fprintf(['mus=' num2str(param_final(1)) ' ,mua1=' num2str(param_final(2)) ' ,mua2=' num2str(param_final(end)) '\n']);
final=1;
output=fun_forward_calError_chooseSDS(param_final);

end

function fun_load_lkt_table(lkt_dir)
global num_SDS num_gate  lkt_mus_table sim_PL_arr_1 sim_PL_arr_2 sim_each_photon_weight_arr
lkt_mus_table=load(fullfile(lkt_dir,'mus_table.txt'));
% lkt_mus_table=lkt_mus_table';

sim_PL_arr_1={};
sim_PL_arr_2={};
for lkt_index=1:size(lkt_mus_table,1)
    fprintf(['Loading ' num2str(lkt_index) '/' num2str(size(lkt_mus_table,1)) '\n'])
    temp_PL=load(fullfile(lkt_dir,['sim_' num2str(lkt_index)],'PL_1.mat'));
    if lkt_index<=3
        for s=1:num_SDS
            sim_PL_arr_1(lkt_index,num_gate*(s-1)+1:num_gate*s)=temp_PL.SDS_detpt_arr(:,s)';
        end
    else
        for s=1:num_SDS
            sim_PL_arr_2(lkt_index,num_gate*(s-1)+1:num_gate*s)=temp_PL.SDS_detpt_arr(:,s)';
        end
    end
%     sim_PL_arr(:,:,lkt_index)=temp_PL.PL_arr;
    sim_each_photon_weight_arr(lkt_index,:)=temp_PL.each_photon_weight_arr;
end
end

function output=fun_scale_param_error(param_init)
global scale_size;
output=fun_forward_calError_chooseSDS(param_init.*scale_size);
end

function output=fun_forward_calError_chooseSDS(param_arr)
global num_SDS num_gate lkt_mus_table target_TPSF start_index end_index fitting_SDS sim_PL_arr_1 sim_PL_arr_2 sim_each_photon_weight_arr final temp_fitted_TPSF temp_fitting_error temp_fitted_param
param=[repmat(param_arr(1),1,2) repmat(param_arr(2),1,3) 0];
% for lkt_index=1:size(lkt_mus_table,1)
%     if lkt_index<=3
        for s=1:num_SDS*num_gate
%             ref_arr(lkt_index,s)=sum(sim_PL_arr_1{lkt_index,s}(:,1).*exp(-1*sim_PL_arr_1{lkt_index,s}(:,2).*param_arr(2)),1)./sim_each_photon_weight_arr(lkt_index,ceil(s/num_gate));
            ref_arr(s)=1/sim_each_photon_weight_arr(1,ceil(s/num_gate))*sum(exp(-1*sum(double(sim_PL_arr_1{1,s}).*param,2)),1);
        end
%     else
%         for s=1:num_SDS*num_gate
% %             ref_arr(lkt_index,s)=sum(sim_PL_arr_2{lkt_index,s}(:,1).*exp(-1*sim_PL_arr_2{lkt_index,s}(:,2).*param_arr(2)),1)./sim_each_photon_weight_arr(lkt_index,ceil(s/num_gate));
%             ref_arr(lkt_index,s)=1/sim_each_photon_weight_arr(lkt_index,ceil(s/num_gate))*sum(exp(-1*sum(double(sim_PL_arr_2{lkt_index,s}).*[param_arr(2:end) 0],2)),1);
%         end
%     end
% end

% temp_interp_TPSF=interp1(lkt_mus_table,ref_arr,param_arr(1));
    
for s=1:num_SDS
    interp_TPSF(:,s)=ref_arr(num_gate*(s-1)+1:num_gate*s);
end

log_interp_TPSF=log10(interp_TPSF);
log_target_TPSF=log10(target_TPSF);


fprintf('RMSPE: ');
for s=1:num_SDS
    error=(log_interp_TPSF(start_index(s):end_index(s),s)-log_target_TPSF(start_index(s):end_index(s),s))./log_target_TPSF(start_index(s):end_index(s),s);
    RMSPE(:,s)=sqrt(mean(error.^2));
    fprintf('%.2f%%, ',100*RMSPE(:,s));
end
fprintf(', total=');

if final==1
    temp_fitted_param=param_arr;
    temp_fitted_TPSF=interp_TPSF;
    temp_fitting_error=RMSPE;
end

mean_RMSPE=mean(RMSPE(fitting_SDS));
fprintf('%.2f%%\n',100*mean_RMSPE);

output=mean_RMSPE;
end



