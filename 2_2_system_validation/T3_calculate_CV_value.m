%{
Calculate the CV value of measurements with total counts=10^5 and 10^6

Ting-Yi Kuo
Last update: 2024/06/11
%}

clc; clear;
mother_folder={'20240612-10^5','20240612-10^6'};
SDS={'SDS1','SDS2','SDS3','SDS4'};

title_arr={'10^5','10^6'};
legend_arr={'10^{5}','10^{6}','CV of 10^{5}','CV of 10^{6}'};

blue=[0 0.4470 0.7410];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
color_arr={blue,yellow,orange};

figure('Units','pixels','Position',[0 0 1000 800]);
ti=tiledlayout('flow');

for j=1:length(SDS)
    nexttile;
    for i=1:length(mother_folder)
        load(fullfile(mother_folder{i},'phantom_3_530',SDS{j},[SDS{j} '_TPSF_collect.mat']));
        temp_TPSF=TPSF_collect(1:501,:);
        temp_total_counts=sum(temp_TPSF);
        count=mean(temp_total_counts);
        
        for k=1:size(temp_TPSF,2)
            temp_TPSF(:,k)=smooth(temp_TPSF(:,k));
            [max_value,max_index]=max(temp_TPSF(:,k));
            temp_TPSF(:,k)=temp_TPSF(:,k)/max_value;
            max_index_arrange(i,j,k)=max_index;
        end
        TPSF_arrange(i,j,:,:)=temp_TPSF;
        
        mean_TPSF=mean(temp_TPSF,2);
        max_value=max(mean_TPSF);
        start_value=max_value*0.5;
        end_value=max_value*0.005;
        start_index=find(mean_TPSF>=start_value,1);
        end_index=find(mean_TPSF>=end_value,1,'last');
        
        CV(:,j,i)=std(temp_TPSF,[],2)./mean(temp_TPSF,2);
        max_CV_in_range(j,i)=max(CV(start_index:end_index,j,i),[],'all');
        
        hold on
        yyaxis left
        plot(0:0.025:0.025*(length(temp_TPSF)-1),temp_TPSF,'-','Color',color_arr{i},'LineWidth',1);
        ylabel('Counts');
        set(gca,'YScale','log');
        yyaxis right
        plot(0.025:10*0.025:0.025*(length(CV)-1),100*CV(1:10:500,j,i),'Color',orange,'LineWidth',1);
        ylabel('CV (%)');
        xlabel('time (ns)');
        ylim([0 40]);
        yticks(0:5:40);
        title(['SDS ' num2str(j)]); %', Total counts = ' num2str(round(count))
        set(gca,'FontName','Times New Roman','FontSize',16);
    end
    xline(start_index*0.025,'--','Color',[0.9290 0.6940 0.1250],'LineWidth', 2);
    xline(end_index*0.025,'--','Color',[0.9290 0.6940 0.1250],'LineWidth', 2);
    
end

none=[];
color_arr={blue,yellow,orange,orange};
line_prop={'-','-','-','--'};
for i=1:4
    h(i)=plot(NaN,NaN,line_prop{i},'color',color_arr{i});
end

lgd=legend(h,legend_arr,'Orientation','horizontal');
lgd.Layout.Tile='south';
print(fullfile('results',['CV_vlaue.png']),'-dpng','-r200');

%% Calculate the vatriation and plot
blue=[0 0.4470 0.7410];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
purple=[0.4940 0.1840 0.5560];
green=[0.4660 0.6740 0.1880];
color_arr={blue,orange,yellow,purple,green};

mean_TPSF_arrange=mean(TPSF_arrange,4);

for i=1:length(mother_folder)
    figure('Units','pixel','Position',[0 0 1980 1080]);
    ti=tiledlayout(5,5);
    
    nexttile(1);
    plot(0:0.025:0.025*(size(mean_TPSF_arrange,3)-1),squeeze(mean_TPSF_arrange(i,:,:)));
    ylabel('normalized counts');
    xlabel('time (ns)');
    title('mean value');
    legend('SDS 1','SDS 2','SDS 3','SDS 4');
    set(gca,'FontName','Times New Roman','FontSize',14,'YScale','log');

    temp=squeeze(TPSF_arrange(i,:,:,:));
    for s=1:size(temp,1)
        error=squeeze(temp(s,:,:))-squeeze(mean_TPSF_arrange(i,s,:));
        relative_error=error./squeeze(mean_TPSF_arrange(i,s,:));
        for t=1:size(temp,3)
            nexttile((s+1)+5*(t-1));
            plot(0:0.025:0.025*(size(error,1)-1),100*relative_error(:,t),'Color',color_arr{t},'Linewidth',2);
            hold on
            plot((squeeze(max_index_arrange(i,s,t))-1)*0.025,zeros(1,5),'o','Color','b','Linewidth',2)
            ylabel('relative error (%)');
            xlabel('time (ns)');
            xlim([0 10]);
            title(['SDS ' num2str(s)]);
            set(gca,'FontName','Times New Roman','FontSize',14);
        end
    end
    title(ti,title_arr{i});
    print(fullfile('results',[title_arr{i} '_variation.png']),'-dpng','-r200');
end

%% calculate correaltion coefficient
figure('Units','pixel','Position',[0 0 1500 800]);
ti=tiledlayout(2,4);

x=[1 2 3 4 5];
for i=1:length(mother_folder)
    temp=squeeze(TPSF_arrange(i,:,:,:));
    for s=1:size(temp,1)
        nexttile;
        for g=1:size(temp,2)
            y=squeeze(temp(s,g,:));
            R=corrcoef(x,y);
            R_arrange(g,s)=R(1,2);
        end
        plot(0:0.025:0.025*(size(temp,2)-1),R_arrange(:,s));
        hold on
        plot((squeeze(max_index_arrange(i,s,:))-1)*0.025,zeros(1,5),'o','Linewidth',2)
    %     plot((find(isnan(R_arrange(:,s))~=0)-1)*0.025,0,'o','Linewidth',2);
        ylabel('Correlation Coefficient');
        xlabel('time (ns)');
        title(['SDS ' num2str(s)]);
        set(gca,'FontName','Times New Roman','FontSize',14);
    end
end
print(fullfile('results','photon_counts_correlation_coefficient_of_noise.png'),'-dpng','-r200');

%%
% SDS_1=TPSF_collect(1:501,:);
% temp_total_counts=sum(SDS_1);
% count(1)=mean(temp_total_counts);
% max_value=max(SDS_1);
% for i=1:size(SDS_1,2)
%     SDS_1(:,i)=smooth(SDS_1(:,i)./max_value(i));
% end
% 
% load(fullfile(mother_folder,'phantom_2_460','SDS2','SDS2_TPSF_collect.mat'));
% SDS_2=TPSF_collect(1:501,:);
% temp_total_counts=sum(SDS_2);
% count(2)=mean(temp_total_counts);
% max_value=max(SDS_2);
% for i=1:size(SDS_2,2)
%     SDS_2(:,i)=smooth(SDS_2(:,i)./max_value(i));
% end
% 
% % plot to find the start point
% figure;
% plot(SDS_1,'Color',[0 0.4470 0.7410]);
% hold on
% plot(SDS_2,'Color',[0.8500 0.3250 0.0980]);
% 
% SDS_1=SDS_1(120:440,:);
% SDS_2=SDS_2(120:440,:);
% 
% % plot before deleting outlier and binning
% figure('Units','pixels','Position',[0 0 550 400]);
% hold on
% plot(0:0.025:0.025*320,SDS_1,'Color',[0 0.4470 0.7410]);
% plot(0:0.025:0.025*320,SDS_2,'Color',[0.8500 0.3250 0.0980]);
% set(gca,'Yscale','log');
% ylabel('Normalized counts');
% 
% yyaxis right
% cv_1=std(SDS_1,[],2)./mean(SDS_1,2);
% cv_2=std(SDS_2,[],2)./mean(SDS_2,2);
% p1=plot(0:0.025:0.025*320,100*cv_1,'--','Color',[0 0.4470 0.7410]);
% p2=plot(0:0.025:0.025*320,100*cv_2,'--','Color',[0.8500 0.3250 0.0980]);
% 
% legend_arr={};
% for i=1:length(count)
%     legend_arr(end+1)={['SDS ' num2str(i) ', total counts=' num2str(ceil(count(i)))]};
% end
% legend([p1,p2],legend_arr);
% xlabel('time (ns)');
% ylabel('CV (%)');
% set(gca,'FontName','Times New Roman','FontSize',12);

% 


