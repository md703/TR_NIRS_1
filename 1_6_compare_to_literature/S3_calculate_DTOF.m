%{
Split the pathlength of simulations into time gates, calculate DTOF of each simulation, 
and store in each simulation folder

Ting-Yi Kuo
Last update: 2023/3/29
Version: 4.41
%}

% clear;close all;


num_SDS=5;
num_gate=10;

layer_mua={[0.2:0.1:0.4],[0.1:0.1:0.3],0.042,[0.15:0.1:0.35]};
       
target_mua=[];
for i=1:length(layer_mua{1})
    for j=1:length(layer_mua{2})
        for k=1:length(layer_mua{3})
            for l=1:length(layer_mua{4})
                target_mua=[target_mua; layer_mua{1}(i) layer_mua{2}(j) layer_mua{3}(k) layer_mua{4}(l) layer_mua{4}(l)*0.5 0];
            end
        end
    end
end

% target_mua(:,5)=target_mua(:,4)*0.5;
% target_mua(:,6)=0;

sbj_arr={'KB'};
for sbj=1
    mus_table=load(fullfile(sbj_arr{sbj},'mus_table.txt'));
    step=1;

    for sim=1:size(mus_table,1)
        %% Calculate reflectance
        load(fullfile(sbj_arr{sbj},['sim_' num2str(sim)],'PL_1.mat'));
        
        for i=1:size(target_mua,1)
            temp_dtof=zeros(1,num_SDS*num_gate);
            index=1;
            for s=1:num_SDS
                for g=1:num_gate
                    if size(SDS_detpt_arr{g,s},1)>0
                        temp_dtof(index)=1/each_photon_weight_arr(s)*sum(exp(-1*sum(double(SDS_detpt_arr{g,s}).*target_mua(i,:),2)),1);%*(true_r/sim_set.detector_r).^2;
                    else
                        temp_dtof(index)=0;
                    end
                    index=index+1;
                end
            end

%             figure;
%             semilogy(dtof,'Linewidth',2);

            DTOF(step,:)=[target_mua(i,1:4) mus_table(sim,1:4) temp_dtof];
            fprintf(['Finish sim ' num2str(step) '/' num2str(size(mus_table,1)*size(target_mua,1)) '\n']);
            step=step+1;
        end
    end
    save(fullfile(sbj_arr{sbj},'DTOF.txt'),'DTOF','-ascii','-tabs');
    fprintf('Done!\n');
end


    