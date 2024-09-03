%{
Calculate DTOF of each simulation and store in each simulation folder if needed.

Ting-Yi Kuo
Last update: 2024/3/29
%}

clear;close all;
%% param
sbj_arr={'KB'};

num_SDS=5;
num_gate=10;

%% init
for sbj=1:length(sbj_arr)
    mus_table = load(fullfile(sbj_arr{sbj},'mus_table.txt'));
    step=1;

    for sim=1:size(mus_table,1)
        %% Calculate reflectance
        load(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'PL_1.mat'));
        
        target_mua=[1.2158005e-01	   2.0923927e-01	   4.2000000e-02	   4.7030481e-01];
        target_mua(:,5)=target_mua(:,4)*0.5;
        target_mua(:,6)=0;
        
        dtof=zeros(1,num_SDS*num_gate);
        index=1;
        for s=1:num_SDS
            for g=1:num_gate
                if size(SDS_detpt_arr{g,s},1)>0
                    dtof(index)=1/each_photon_weight_arr(s)*sum(exp(-1*sum(double(SDS_detpt_arr{g,s}).*target_mua,2)),1);%*(true_r/sim_set.detector_r).^2;
                else
                    dtof(index)=0;
                end
                index=index+1;
            end
        end
        
%         figure;
%         semilogy(dtof,'Linewidth',2);
        
        to_save=[target_mua(1:4) mus_table(sim,1:4) dtof];
        save(fullfile(sbj_arr{sbj},['DTOF_' num2str(step) '.mat']),'to_save');
        step=step+1;

        fprintf(['Finish sim ' num2str(sim) '/' num2str(size(mus_table,1)) '\n']);
    end
        
    fprintf('Done!\n');
    
end


    