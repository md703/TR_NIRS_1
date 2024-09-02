%{
Split the pathlength results into certain gates if needed.
(The 10-gates results are already obtained after simulations.)

Ting-Yi Kuo
Last update: 2024/3/29
%}
clear;close all;

global num_gate;
%% param
sbj_arr={'CT','BY'};

num_SDS=5;
tend=5E-9;
tstep=25E-12;
num_gate=tend/tstep;

%% init
for sbj=1:length(sbj_arr)
    sbj_name=sbj_arr{sbj};
    mus_table=load(fullfile(sbj_name,'mus_table.txt'));
    
    for m=1:size(mus_table,1)
        load(fullfile(sbj_name,['sim_' num2str(m)],'PL_1.mat'));
        load(fullfile(sbj_name,['sim_' num2str(m)],'cfg_1.mat'));
        
        cfg.tend=tend;
        cfg.tstep=tstep;
        
        PL_arr=cell(1,num_SDS);
        for s=1:num_SDS
            for g=1:size(SDS_detpt_arr,1)
                temp_PL_arr=SDS_detpt_arr{g,s};
                PL_arr{1,s}(end+1:end+size(temp_PL_arr,1),:)=temp_PL_arr;
            end
            
        end
        
        detPL_arr_time=cell(num_gate,num_SDS);
        for g=1:num_gate
            for s=1:num_SDS
                detPL_arr_time{g,s}=[];
            end
        end
        
        for s=1:num_SDS
            temp_detPL_time=fun_MCX_det_time(PL_arr{s},cfg);
            for g=1:num_gate
                detPL_arr_time{g,s}=[detPL_arr_time{g,s};temp_detPL_time{g,1}];
            end
        end
        save(fullfile(sbj_name,['sim_' num2str(m)],'PL_1.mat'),'SDS_detpt_arr','detPL_arr_time','each_photon_weight_arr');
        fprintf(['Finish sim ' num2str(m) '/' num2str(size(mus_table,1)) '\n']);
    end
end



