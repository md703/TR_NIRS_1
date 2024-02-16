%{
Forward the spectrum using initial value generated by previous step

Ting-Yi Kuo
Last update: 2023/11/1
%}


global lambda cw_net cw_param_range tr_net tr_param_range;


%% param
model_dir='model_arrange'; % the folder of the models
subject_name_arr={'KB'}; % the name of the subjects
num_SDS_cw=7;
num_SDS_tr=5;
num_gate=10; % the number of SDS, in the ANN

fitting_wl=(700:4:900)';
fitting_wl_tr=810;
fitting_wl=[fitting_wl; fitting_wl_tr];
fitting_wl=unique(fitting_wl_tr);

lambda=fitting_wl;

%% forward the spectrum
for sbj_i=1:length(subject_name_arr)
    fun_init_param_to_mu_spec(); % load the epsilon for target wl
    
    % load init_value_arr
    load(fullfile(model_dir,'init_value_arr.mat'));
    
    % load ANN model
    load(fullfile(model_dir,[subject_name_arr{sbj_i} '_cw_model.mat'])); % cw_net, cw_param_range
    load(fullfile(model_dir,[subject_name_arr{sbj_i} '_tr_model.mat'])); % tr_net, tr_param_range
    
    init_spec_arr=zeros(length(lambda),num_SDS_cw,length(init_value_arr));
    init_dtof_arr=zeros(num_gate,num_SDS_tr,length(init_value_arr));

    % for each target spec
    for init_i=1:size(init_value_arr,1)
        fprintf('Subject %d spec %d\n',sbj_i,init_i);

        %% generate init value and spec
        [OP_arr,~]=fun_param_to_mu(init_value_arr(init_i,:),0);

        init_spec_arr(:,:,init_i)=fun_ANN_forward(OP_arr,0);
        
        temp_OP_arr=[lambda OP_arr];
        OP_arr=interp1(temp_OP_arr(:,1),temp_OP_arr(:,2:end),fitting_wl_tr,'pchip');
        
        target_dtof_=fun_ANN_forward(OP_arr,1);
        
        for i=1:num_SDS_tr
            target_dtof(:,i)=target_dtof_((i-1)*num_gate+1:i*num_gate)';
        end
        
        init_dtof_arr(:,:,init_i)=target_dtof;
        
    end

    save(fullfile(output_dir,[subject_name_arr{sbj_i} '_DB.mat']),'init_spec_arr','init_dtof_arr','init_value_arr','fitting_wl','fitting_wl_tr');
end

disp('Done!');