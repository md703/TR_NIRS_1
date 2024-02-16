%{
Split the pathlength of simulations into time gates and store in each simulation folder

Ting-Yi Kuo
Last update: 2023/3/20
Version: 4.41
%}

clear;close all;

sbj_arr = {'KB'};
for sbj = 1
    mus_table = load(fullfile(sbj_arr{sbj},'mus_table.txt'));
    
    for sim = 1:size(mus_table,1)
        if ~exist(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'PL_2.mat'),'file')
            
            load(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'PL_1.mat'));
            load(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'cfg_1.mat'));
            PL_arr = SDS_detpt_arr{1};

            cfg.tend = 5E-9;
            cfg.tstep = 5E-10;

            temp_arr = {};
            detp.ppath = 10*PL_arr; % turn cm into mm
            tof=mcxdettime(detp,cfg.prop);
            [tempcounts, idx]=histc(tof,0:cfg.tstep:cfg.tend);
            for gate = 1:(cfg.tend/cfg.tstep)
                index = find(idx==gate);
                temp_arr{gate} = PL_arr(index,:);
            end
            SDS_detpt_arr = temp_arr;
            save(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'PL_2.mat'),'each_photon_weight_arr','SDS_detpt_arr','-v7.3');
        end
        fprintf(['Finish sim ' num2str(sim) '/' num2str(size(mus_table,1)) '\n']); 
    end
    
end
fprintf('Finish splitting into time gates!\n');
    