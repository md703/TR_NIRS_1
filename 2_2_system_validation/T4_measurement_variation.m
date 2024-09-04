%{
Calculate the CV value influenced by probe replacement and measuring
position on phantoms

Ting-Yi Kuo
Last update: 2024/06/11
%}

clc;clear;close all;

mother_folder='20240612-IRF';
folderName='SDS_measure_3_times';
sub_folder={'1','2','3'};
save_name='SDS';

flag=0;
start_index=118;

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
    
    for j=1:size(TPSF_collect,2)
        TPSF=smooth(TPSF_collect(:,j));
        max_value=max(TPSF);
        TPSF_result(:,j)=TPSF./max_value;
    end
    
    mean_TPSF_arrange(:,:,i)=TPSF_result(start_index:500,:);
    
end

% % move max to same point
% for i=1:size(mean_TPSF_arrange,2)
%     [max_value,max_first]=max(mean_TPSF_arrange(:,i,1));
%     for j=1:size(mean_TPSF_arrange,3)-1
%         temp=mean_TPSF_arrange(:,i,j+1);
%         [~, max_now]=max(temp);
%         x_shift=max_now-max_first;
%         mean_TPSF_arrange(:,i,j+1)=circshift(temp,-x_shift);
%     end
% end



% plot
% legend_arr={'place 1','place 2','place 3','place 2','place 3'};
legend_arr={'1','2','3'};

figure('Units','pixel','Position',[0 0 1000 800]);
ti=tiledlayout(2,2,'TileSpacing','Compact');
for i=1:size(mean_TPSF_arrange,2)
    % find 50%~0.5%
    max_value=max(mean_TPSF_arrange(:,i,:),[],'all');
    start_value=max_value*0.5;
    end_value=max_value*0.005;

    check_until_this_index=8/0.025;
    start_index=find(mean_TPSF_arrange(1:check_until_this_index,i,1)>=start_value,1);
    end_index=find(mean_TPSF_arrange(1:check_until_this_index,i,1)>=end_value,1,'last');
    
    nexttile;
    plot(0:0.025:0.025*(size(mean_TPSF_arrange,1)-1),squeeze(mean_TPSF_arrange(:,i,:)),'Linewidth',2);
    hold on
    error=squeeze((mean_TPSF_arrange(:,i,2:3)-mean_TPSF_arrange(:,i,1))./mean_TPSF_arrange(:,i,1));
    CV=std(mean_TPSF_arrange(:,i,:),[],3)./mean(mean_TPSF_arrange(:,i,:),3);
    
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
