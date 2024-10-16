%{
Evaluate system noise.

'Haven't finished yet.'

Ting-Yi Kuo
Last update: 2024/05/06
%}

clc;clear;%close all;

mother_folder='20240612-IRF';
folderName='SDS_measure_different_place'; %SDS_measure_3_times, SDS_measure_different_place
figure_name='Phantom position variance';  % probe repositioning, Phantom position variance
sub_folder={'1','2','3'};
save_name='SDS';

flag=0;
start_index=118;

%% load data and preprocessing
for i=1:3
    load(fullfile(mother_folder,folderName,sub_folder{i},[save_name '_info_record.mat']));
    load(fullfile(mother_folder,folderName,sub_folder{i},[save_name '_TPSF_collect.mat']));
    
    
    while flag
        figure;
        semilogy(TPSF_collect);
        title('Raw data');
        fprintf('Please change ''start_index'' and set ''flag=0'' \n');

        keyboard();
        close all;
    end
    
    TPSF_collect=TPSF_collect(start_index:500,:);
    
    for j=1:size(TPSF_collect,2)
        TPSF=smooth(TPSF_collect(:,j));
        [max_value,max_index]=max(TPSF);
        max_index_arrange(i,j)=max_index;
        TPSF_result(:,j)=TPSF./max_value;
    end
    
    TPSF_arrange(:,:,i)=TPSF_result;
    
end


%% plot the DTOF and CV value
% legend_arr={'place 1','place 2','place 3','place 2','place 3'};
legend_arr={'1','2','3'};

figure('Units','pixel','Position',[0 0 1000 800]);
ti=tiledlayout(2,2,'TileSpacing','Compact');
for i=1:size(TPSF_arrange,2)
    % find 50%~0.5%
    max_value=max(TPSF_arrange(:,i,:),[],'all');
    start_value=max_value*0.5;
    end_value=max_value*0.005;

    check_until_this_index=8/0.025;
    start_index=find(TPSF_arrange(1:check_until_this_index,i,1)>=start_value,1);
    end_index=find(TPSF_arrange(1:check_until_this_index,i,1)>=end_value,1,'last');
    
    nexttile;
    plot(0:0.025:0.025*(size(TPSF_arrange,1)-1),squeeze(TPSF_arrange(:,i,:)),'Linewidth',2);
    hold on
    error=squeeze((TPSF_arrange(:,i,2:3)-TPSF_arrange(:,i,1))./TPSF_arrange(:,i,1));
    CV=std(TPSF_arrange(:,i,:),[],3)./mean(TPSF_arrange(:,i,:),3);
    
    title(['SDS ' num2str(i)]);
    xlabel('time (ns)');
    ylabel('Normalized counts');
    set(gca,'YScale','log','FontName','Times New Roman','FontSize',12);
    yyaxis right
    plot_index=1:size(error,1);
    plot(0:0.025:0.025*(length(plot_index)-1),100*abs(CV(plot_index,:)),'Linewidth',1);
    max_CV_in_range(i)=max(CV(start_index:end_index));
    
%     ylabel('relative error compared to the first (%)');
    ylabel('CV (%)');
    ylim([0 40]);
    xline(start_index*0.025,'--','Color',[0.9290 0.6940 0.1250],'LineWidth', 2);
    xline(end_index*0.025,'--','Color',[0.9290 0.6940 0.1250],'LineWidth', 2);
    set(gca,'FontName','Times New Roman','FontSize',18);
    grid on
end

lgd=legend(legend_arr,'Orientation','horizontal','FontSize',18);
lgd.Layout.Tile='South';
print(fullfile(mother_folder,[folderName '.png']),'-dpng','-r200');


%% calculate correaltion coefficient
figure('Units','pixel','Position',[0 0 1000 800]);
ti=tiledlayout('flow');

x=[1 2 3];
for s=1:size(TPSF_arrange,2)
    nexttile;
    for g=1:size(TPSF_arrange,1)
        y=squeeze(TPSF_arrange(g,s,:));
        R=corrcoef(x,y);
        R_arrange(g,s)=R(1,2);
    end
    plot(0:0.025:0.025*(size(TPSF_arrange,1)-1),R_arrange(:,s));
    hold on
    plot((max_index_arrange(:,s)-1)*0.025,zeros(1,3),'o','Linewidth',2)
%     plot((find(isnan(R_arrange(:,s))~=0)-1)*0.025,0,'o','Linewidth',2);
    ylabel('Correlation Coefficient');
    xlabel('time (ns)');
    title(['SDS ' num2str(s)]);
    set(gca,'FontName','Times New Roman','FontSize',14);
end
print(fullfile('results','correlation_coefficient_of_noise.png'),'-dpng','-r200');


%% calculate and plot the variation of three measurments
mean_TPSF_arrange=mean(TPSF_arrange,3);

figure('Units','pixel','Position',[0 0 1980 648]);
ti=tiledlayout(3,5);
blue=[0 0.4470 0.7410];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
purple=[0.4940 0.1840 0.5560];
green=[0.4660 0.6740 0.1880];
color_arr={blue,orange,yellow,purple,green};

nexttile;
plot(0:0.025:0.025*(size(TPSF_arrange,1)-1),mean_TPSF_arrange);
ylabel('normalized counts');
xlabel('time (ns)');
title('mean value');
legend('SDS 1','SDS 2','SDS 3','SDS 4');
set(gca,'FontName','Times New Roman','FontSize',14,'YScale','log');

for s=1:size(TPSF_arrange,2)
    error=squeeze(TPSF_arrange(:,s,:))-mean_TPSF_arrange(:,s);
    relative_error=error./mean_TPSF_arrange(:,s);
    for t=1:size(TPSF_arrange,3)
        nexttile((s+1)+5*(t-1));
        plot(0:0.025:0.025*(size(TPSF_arrange,1)-1),100*relative_error(:,t),'Color',color_arr{t},'Linewidth',2);
        hold on
        plot((max_index_arrange(t,s)-1)*0.025,zeros(1,3),'o','Linewidth',2)
        ylabel('relative error (%)');
        xlabel('time (ns)');
        title(['SDS ' num2str(s)]);
        set(gca,'FontName','Times New Roman','FontSize',14);
    end
end
% legend('measurement 1','measurement 2','measurement 3');
title(ti,figure_name);
print(fullfile('results',[figure_name '_variation.png']),'-dpng','-r200');


