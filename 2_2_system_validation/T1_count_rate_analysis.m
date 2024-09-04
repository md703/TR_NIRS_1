%{
Evaluate the influence of different count rate

Ting-Yi Kuo
Last update: 2024/06/11
%}

%% Infleuence of count rate on IRFs
clc;clear;close all;

folderPath='20240527-2_IRF_count_rate';
sim_folder='20240502/cal_reflectance_200';

fitting_phantom=[2 3];
used_intensity={'460','460'};
fitting_SDS=[1 2];

for p=1:6
    sim_TPSF(:,:,p)=load(fullfile(sim_folder,['phantom_' num2str(p) '_TPSF.txt']));
end

IRF_file={'IRF_460_1','IRF_460_2'};
for i=1:length(IRF_file)
    IRF(:,:,i)=load(fullfile(folderPath,IRF_file{i},'IRF_orig_TPSF.txt'));
end

legend_name(1,:)={'10^4 s^{-1}','10^5 s^{-1}'};
legend_name(2,:)={'10^3 s^{-1}','10^4 s^{-1}'};

index=1;
for p=fitting_phantom
    figure('Units','pixels','Position',[0 0 700 400]); %[0,0,640,360]
    ti=tiledlayout(1,2,'TileSpacing','compact','Padding','none');
    
    exp_TPSF(:,:,p)=load(fullfile(folderPath,['phantom_' num2str(p) '_' used_intensity{index}],'SDS_orig_TPSF.txt'));
    
    
    for s=fitting_SDS
        temp_sim_TPSF=sim_TPSF(:,s,p);
        temp_exp_TPSF=exp_TPSF(:,s,p);
        
        max_value=max(temp_sim_TPSF);
        temp_sim_TPSF=temp_sim_TPSF./max_value;
        
        max_value=max(temp_exp_TPSF);
        temp_exp_TPSF=temp_exp_TPSF./max_value;
        
        max_value=max(temp_exp_TPSF);
        start_value=max_value*0.5;
        end_value=max_value*0.005;

        temp_exp_TPSF=smooth(temp_exp_TPSF);

        start_index=find(temp_exp_TPSF>=start_value,1);
        end_index=find(temp_exp_TPSF>=end_value,1,'last');
        
        legend_arr={'simulation','experiment'};
        
        nexttile;
        plot(0:0.025:0.025*(length(temp_sim_TPSF)-1),temp_sim_TPSF,'Linewidth',2);
        hold on
        plot(0:0.025:0.025*(length(temp_exp_TPSF)-1),temp_exp_TPSF,'Linewidth',2);
        for irf=1:length(IRF_file)
            calib_sim_TPSF=conv(temp_sim_TPSF,IRF(:,s,irf));
            
            max_value=max(calib_sim_TPSF);
            calib_sim_TPSF=calib_sim_TPSF./max_value;
            
            error=(temp_exp_TPSF(start_index:end_index)-calib_sim_TPSF(start_index:end_index))./calib_sim_TPSF(start_index:end_index);
            RMSPE=sqrt(mean(error.^2));
            legend_arr(end+1)={['count rate = ' legend_name{irf,s} ' , RMSPE = ' num2str(100*RMSPE) '%']};
            
            plot(0:0.025:0.025*(length(calib_sim_TPSF)-1),calib_sim_TPSF,'Linewidth',2);
        end
        
        xlabel('time (ns)');
        xlim([0 10]);
        ylim([end_value*10^(-2) 1]);
        ylabel('normalized counts');
        xline(start_index*0.025,'--','Color',[0.9290 0.6940 0.1250],'LineWidth', 2);
        xline(end_index*0.025,'--','Color',[0.9290 0.6940 0.1250],'LineWidth', 2);

        title(['SDS ' num2str(s)]);
        legend(legend_arr,'Location','southoutside','Orientation','vertical'); %
        set(gca,'Yscale','log','FontName', 'Times New Roman','Fontsize',12);
    end
    title(ti,['phantom ' num2str(p)]);
    set(gca,'FontName', 'Times New Roman','Fontsize',12);
    print(fullfile('results',['IRF_count_rate_analysis_phantom_' num2str(p) '.png']),'-dpng','-r200');
    
    index=index+1;
end
            
            
%% Infleuence of count rate on phantom measurements
clc;clear;close all;

blue=[0 0.4470 0.7410];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
light_blue=[0.3010 0.7450 0.9330];
green=[0.4660 0.6740 0.1880];
color_arr={blue,orange,yellow};

folderPath={'20240611-10^4','20240611-10^5'};
sim_folder='20240502/cal_reflectance_200_8ns';

fitting_phantom=3;
used_intensity={'470','600'};
fitting_SDS=[1 2 3 4];

for p=1:6
    sim_TPSF(:,:,p)=load(fullfile(sim_folder,['phantom_' num2str(p) '_TPSF.txt']));
end

for i=1:length(folderPath)
    IRF(:,:,i)=load(fullfile(folderPath{i},['phantom_3_' used_intensity{i}],'IRF_orig_TPSF.txt'));
    exp_TPSF(:,:,i)=load(fullfile(folderPath{i},['phantom_3_' used_intensity{i}],'SDS_orig_TPSF.txt'));
end

legend_name(1,:)={'10^4 s^{-1}','10^5 s^{-1}'};


%% Convolution
figure('Units','pixels','Position',[0 0 1080 900]); %[0,0,640,360]
ti=tiledlayout(2,2,'TileSpacing','compact','Padding','none');

for s=fitting_SDS
    nexttile;
    temp_sim_TPSF=sim_TPSF(:,s,fitting_phantom);
    max_value=max(temp_sim_TPSF);
    temp_sim_TPSF=temp_sim_TPSF./max_value;
    p(1)=plot(0:0.025:0.025*(length(temp_sim_TPSF)-1),temp_sim_TPSF,'Linewidth',2,'Color',color_arr{1});
    hold on
    legend_arr={'simulation'};
    for f=1:length(folderPath)
        temp_exp_TPSF=exp_TPSF(:,s,f);
        temp_exp_TPSF=smooth(temp_exp_TPSF);
        temp_IRF=IRF(:,s,f);
        
        calib_sim_TPSF=conv(temp_sim_TPSF,temp_IRF);

        max_value=max(temp_exp_TPSF);
        temp_exp_TPSF=temp_exp_TPSF./max_value;

        max_value=max(temp_exp_TPSF);
        start_value=max_value*0.5;
        end_value=max_value*0.005;

        start_index=find(temp_exp_TPSF>=start_value,1);
        end_index=find(temp_exp_TPSF>=end_value,1,'last');
        
        max_value=max(calib_sim_TPSF);
        calib_sim_TPSF=calib_sim_TPSF./max_value;
        
        error=(temp_exp_TPSF(start_index:end_index)-calib_sim_TPSF(start_index:end_index))./calib_sim_TPSF(start_index:end_index);
        RMSPE=sqrt(mean(error.^2));
        legend_arr(end+1)={['count rate = ' legend_name{f} ' , RMSPE = ' num2str(100*RMSPE) '%']};
        
        plot(0:0.025:0.025*(length(temp_exp_TPSF)-1),temp_exp_TPSF,'--','Linewidth',2,'Color',color_arr{f+1});
        p(f+1)=plot(0:0.025:0.025*(length(calib_sim_TPSF)-1),calib_sim_TPSF,'Linewidth',2,'Color',color_arr{f+1});
        xline(start_index*0.025,':','Color',color_arr{f+1},'LineWidth', 2);
        xline(end_index*0.025,':','Color',color_arr{f+1},'LineWidth', 2);
    end
    xlabel('time (ns)');
    xlim([0 10]);
    ylim([end_value*10^(-2) 1]);
    ylabel('normalized counts');

    
    title(['SDS ' num2str(s)]);
    legend(p,legend_arr,'Location','southoutside','Orientation','vertical'); %
    set(gca,'Yscale','log','FontName', 'Times New Roman','Fontsize',12);
end
title(ti,['phantom ' num2str(fitting_phantom)]);
set(gca,'FontName', 'Times New Roman','Fontsize',12);
print(fullfile('results',['measurement_count_rate_influence_convolution.png']),'-dpng','-r200');


%% deconvolution
% figure('Units','pixels','Position',[0 0 1080 900]); %[0,0,640,360]
% ti=tiledlayout(2,2,'TileSpacing','compact','Padding','none');
% 
% for s=fitting_SDS
%     nexttile;
%     temp_sim_TPSF=sim_TPSF(:,s,fitting_phantom);
%     max_value=max(temp_sim_TPSF);
%     temp_sim_TPSF=temp_sim_TPSF./max_value;
%     p(1)=plot(0:0.025:0.025*(length(temp_sim_TPSF)-1),temp_sim_TPSF,'Linewidth',2,'Color',color_arr{1});
%     hold on
%     legend_arr={'simulation'};
%     for f=1:length(folderPath)
%         temp_exp_TPSF=exp_TPSF(:,s,f);
%         temp_exp_TPSF=smooth(temp_exp_TPSF);
%         temp_IRF=IRF(:,s,f);
%         temp_exp_TPSF=smoothdata(temp_exp_TPSF,'gaussian',41);
%         temp_IRF=smoothdata(temp_IRF,'gaussian',41);
%         
%         num_iterations=100;
%         dampar=0.00001;%0.01; % 1
%         weight=ones(size(temp_exp_TPSF));
%         readout=0.1; %0.1
%         subsample=1;
%         calib_sim_TPSF=deconvlucy(temp_exp_TPSF,temp_IRF,num_iterations,dampar,weight,readout,subsample);
%         calib_sim_TPSF=smooth(calib_sim_TPSF);
%         
%         max_value=max(temp_exp_TPSF);
%         temp_exp_TPSF=temp_exp_TPSF./max_value;
%         
%         max_value=max(temp_exp_TPSF);
%         start_value=max_value*0.5;
%         end_value=max_value*0.005;
% 
%         start_index=find(temp_sim_TPSF>=start_value,1);
%         end_index=find(temp_sim_TPSF>=end_value,1,'last');
%         
%         max_value=max(calib_sim_TPSF);
%         calib_sim_TPSF=calib_sim_TPSF./max_value;
%         
%         [~, max_sim]=max(temp_sim_TPSF);
%         [~, max_calib]=max(calib_sim_TPSF);
%         x_shift=max_calib-max_sim;
%         calib_sim_TPSF=circshift(calib_sim_TPSF,-x_shift);
%         
%         error=(calib_sim_TPSF(start_index:end_index)-temp_sim_TPSF(start_index:end_index))./temp_sim_TPSF(start_index:end_index);
%         RMSPE=sqrt(mean(error.^2));
%         legend_arr(end+1)={['count rate = ' legend_name{f} ' , RMSPE = ' num2str(100*RMSPE) '%']};
%         
%         plot(0:0.025:0.025*(length(temp_exp_TPSF)-1),temp_exp_TPSF,'--','Linewidth',2,'Color',color_arr{f+1});
%         p(f+1)=plot(0:0.025:0.025*(length(calib_sim_TPSF)-1),calib_sim_TPSF,'Linewidth',2,'Color',color_arr{f+1});
%         xline(start_index*0.025,':','Color',color_arr{f+1},'LineWidth', 2);
%         xline(end_index*0.025,':','Color',color_arr{f+1},'LineWidth', 2);
%     end
%     xlabel('time (ns)');
%     xlim([0 10]);
%     ylim([end_value*10^(-2) 1]);
%     ylabel('normalized counts');
% 
%     
%     title(['SDS ' num2str(s)]);
%     legend(p,legend_arr,'Location','southoutside','Orientation','vertical'); %
%     set(gca,'Yscale','log','FontName', 'Times New Roman','Fontsize',12);
% end
% title(ti,['phantom ' num2str(fitting_phantom)]);
% set(gca,'FontName', 'Times New Roman','Fontsize',12);
% print(fullfile('results',['measurement_count_rate_influence_deconvolution.png']),'-dpng','-r200');
        

