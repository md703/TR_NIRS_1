%{
Compared the experimental data with predicted values which are obtained by
doing convolution with simulation data and measured IRF data.

Ting-Yi Kuo
Last update: 2024/06/01
%}

clc;clear;close all;
%% param
folderPath='20240502';
sim_folder='1_ph_info';

fitting_phantom=[1];
fitting_SDS=[1 2];


for p=1:6
    sim_TPSF(:,:,p)=load(fullfile(sim_folder,['phantom_' num2str(p) '_TPSF.txt']));
end

for p=fitting_phantom
    
    figure;
    ti=tiledlayout('flow');
    
    IRF=load(fullfile(folderPath,['phantom_' num2str(p)],'IRF_orig_TPSF.txt'));
    
    exp_TPSF(:,:,p)=load(fullfile(folderPath,['phantom_' num2str(p)],'SDS_orig_TPSF.txt'));
    for s=fitting_SDS
        temp_sim_TPSF=sim_TPSF(:,s,p);
        temp_exp_TPSF=exp_TPSF(:,s,p);
        
        calib_sim_TPSF=conv(temp_sim_TPSF,IRF(:,1));
        
        max_value=max(temp_sim_TPSF);
        temp_sim_TPSF=temp_sim_TPSF./max_value;
        
        max_value=max(calib_sim_TPSF);
        calib_sim_TPSF=calib_sim_TPSF./max_value;
        
        max_value=max(temp_exp_TPSF);
        temp_exp_TPSF=temp_exp_TPSF./max_value;
        
        max_value=max(temp_exp_TPSF);
        start_value=max_value*0.5;
        end_value=max_value*0.0001;
        
        start_index=find(temp_exp_TPSF>=start_value,1);
        end_index=find(temp_exp_TPSF>=start_value,1,'last');

        error=(temp_exp_TPSF(start_index:end_index)-calib_sim_TPSF(start_index:end_index))./calib_sim_TPSF(start_index:end_index);
%         error=abs(error);
        RMSPE=sqrt(mean(error.^2));
        
        nexttile;
        plot(0:0.025:0.025*(length(temp_sim_TPSF)-1),temp_sim_TPSF,'Linewidth',2);
        hold on
        plot(0:0.025:0.025*(length(calib_sim_TPSF)-1),calib_sim_TPSF,'Linewidth',2);
        plot(0:0.025:0.025*(length(temp_exp_TPSF)-1),temp_exp_TPSF,'Linewidth',2);
        xlabel('time (ns)');
        xlim([0 10]);
        ylabel('normalized counts');
        xline(start_index*0.025, '--r', 'LineWidth', 2);
        xline(end_index*0.025, '--r', 'LineWidth', 2);
        set(gca,'FontName', 'Times New Roman','Fontsize',12);
%         yyaxis right
%         plot(error*100,'-');
%         ylabel('error(%)')
        title(['SDS ' num2str(s) ', RMSPE=' num2str(100*RMSPE) '%']);
%         title(['RMSPE=' num2str(100*RMSPE) '%']);
        legend('simulation','calibrate','experiment');
    end
    
end

print(fullfile(folderPath,'compare_sim_with_exp.png'),'-dpng','-r200');

%% for deconvolution (not ready yet)

% for p=fitting_phantom
%     
%     figure;
%     ti=tiledlayout('flow');
%     
%     IRF=load(fullfile(folderPath,['phantom_' num2str(p)],'IRF_orig_TPSF.txt'));
%     
%     exp_TPSF(:,:,p)=load(fullfile(folderPath,['phantom_' num2str(p)],'SDS_orig_TPSF.txt'));
%     for s=fitting_SDS
%         temp_sim_TPSF=sim_TPSF(:,s,p);
%         temp_exp_TPSF=exp_TPSF(:,s,p);
%         
% %         calib_sim_TPSF=deconv(temp_exp_TPSF,IRF);
%         [calib_sim_TPSF,~]=deconv(temp_exp_TPSF,IRF);
%         
%         max_value=max(temp_sim_TPSF);
%         temp_sim_TPSF=temp_sim_TPSF./max_value;
%         
%         max_value=max(calib_sim_TPSF);
%         calib_sim_TPSF=calib_sim_TPSF./max_value;
%         
%         max_value=max(temp_exp_TPSF);
%         temp_exp_TPSF=temp_exp_TPSF./max_value;
%         
%         max_value=max(temp_exp_TPSF);
%         start_value=max_value*0.5;
%         end_value=max_value*0.0001;
%         
%         start_index=find(temp_exp_TPSF>=start_value,1);
%         end_index=find(temp_exp_TPSF>=start_value,1,'last');
% 
%         error=(calib_sim_TPSF(start_index:end_index)-temp_sim_TPSF(start_index:end_index))./temp_sim_TPSF(start_index:end_index);
% %         error=abs(error);
%         RMSPE=sqrt(mean(error.^2));
%         
%         nexttile;
%         plot(temp_sim_TPSF,'Linewidth',2);
%         hold on
%         plot(calib_sim_TPSF,'Linewidth',2);
%         plot(temp_exp_TPSF,'Linewidth',2);
%         xline(start_index, '--r', 'LineWidth', 2);
%         xline(end_index, '--r', 'LineWidth', 2);
% %         yyaxis right
% %         plot(error*100,'-');
% %         ylabel('error(%)')
%         title(['SDS ' num2str(s) ', RMSPE=' num2str(100*RMSPE) '%']);
%         legend('simulation','calibrate','experiment');
%     end
%     
% end
