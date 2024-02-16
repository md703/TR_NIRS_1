%{
Split the pathlength of simulations into time gates, calculate DTOF of each simulation, 
and store in each simulation folder

Ting-Yi Kuo
Last update: 2023/3/29
Version: 4.41
%}

%clear;close all;


num_SDS=5;
num_gate=10;

sbj_arr = {'KB_test'};
for sbj = 1
    mus_table = load(fullfile(sbj_arr{sbj},'mus_table.txt'));


    for sim = 1:size(mus_table,1)
        SDS_detpt_arr={};
        if ~exist(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'DTOF.mat'),'file')
            
            load(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'PL_1.mat'));

            %% Calculate reflectance
            target_OP=load('target_OP_to_sim.txt');
    %         target_mua=target_OP(sim,1:4);
            target_mua=[ 4.6000000e-01	   2.3501063e-01	   4.2000000e-02	   4.2879307e-01];
            target_mua(:,5)=target_mua(:,4)*0.5;
            target_mua(:,6)=0;

            dtof=zeros(num_gate,num_SDS);
            for s=1:num_SDS
                for g=1:num_gate
                    if size(SDS_detpt_arr{g,s},1)>0
                        dtof(g,s)=sum(exp(-1*sum(double(SDS_detpt_arr{g,s}).*target_mua,2)),1);%*(true_r/sim_set.detector_r).^2;
                    else
                        dtof(g,s)=0;
                    end
                end
            end
            %1/each_photon_weight_arr(1)*

%             to_save=[target_mua(1:4) mus_table(sim,1:4) dtof];
            save(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'DTOF.mat'),'dtof');
        end

%         fprintf(['Finish sim ' num2str(sim) '/' num2str(size(mus_table,1)) '\n']);
    end
    fprintf('Done!\n');
    
end

figure;
semilogy(dtof(:,4))

    