
clc;clear;%close all;

dir='test_fitting_2024-07-03-14-00-54_medium';
sub_dir='fittingSDS_2345';
num_SDS=5;
num_gate=10;

to_check=1:81; %27*2+1:27*3; %27*2+1:27*3   %28:27*2   %1:27

lkt_dir='KB';
target_info=load(fullfile(lkt_dir,'DTOF.txt'));
OP_ans_arrange=target_info(:,1:8);
temp_target_TPSF=target_info(:,9:end);
for t=1:size(temp_target_TPSF,1)
    for i=1:num_SDS
        target_TPSF_arrange(:,i,t)=temp_target_TPSF(t,(i-1)*num_gate+1:i*num_gate)';
    end
end

for tr=1:size(target_TPSF_arrange,3)
    for tc=1:size(target_TPSF_arrange,2)
        start_value=max(target_TPSF_arrange(:,tc,tr))*0.5;
        end_value=max(target_TPSF_arrange(:,tc,tr))*0.0001;
        start_index_arrange(tr,tc)=find(target_TPSF_arrange(:,tc,tr)>=start_value,1);
        end_index_arrange(tr,tc)=find(target_TPSF_arrange(:,tc,tr)>=end_value,1,'last');
    end
end
start_index_arrange=start_index_arrange(to_check,:);
end_index_arrange=end_index_arrange(to_check,:);
OP_ans_arrange=OP_ans_arrange(to_check,:);

mus_to_fit=[40 60 80 100 120 140 160 180];
index=1;
for i=to_check
    load(fullfile(dir,sub_dir,['fitting_info_' num2str(i) '.mat']));
    OP_error(index)=mua_brain_error;
    OP_ans_arrange(index,:)=OP_ans;
    fitted_TPSF=fitted_TPSF(:,:,min_index);
    fitted_TPSF_arrange(:,:,index)=fitted_TPSF;
    fitting_error_arrange(:,:,index)=(fitted_TPSF-target_TPSF)./target_TPSF;
    fitted_param_arrange(index,:)=fitted_param(:,:,min_index);
    mus_arrange(index)=mus_to_fit(min_index);
    index=index+1;
end

fitting_SDS=[2 3 4 5];
SDS=[0.5 1 2 3 4];
figure('Units','pixels','position',[0 0 600 500]);
tiledlayout('flow');
for s=fitting_SDS
    nexttile;
    shadedErrorBar(1:1:num_gate,100*mean(abs(fitting_error_arrange(:,s,:)),3),100*std(abs(fitting_error_arrange(:,s,:)),[],3),'lineprops',{'LineWidth',2},'patchSaturation',0.1);  %'-b'
    xlabel('Time gate');
    ylabel('error(%)');
    set(gca,'FontName','Times New Roman','FontSize',12);
    title(['SDS ' num2str(SDS(s)) ' cm']);
end
print(fullfile(dir,'fitting_error.png'),'-dpng','-r200');

%%

% figure;
% tiledlayout('flow');
% for s=1:num_SDS
%     nexttile;
%     plot(fitted_TPSF_arrange(:,s,27))
%     hold on
%     plot(target_TPSF(:,s))
%     set(gca,'YScale','log')
% end
% 
% for i=1:size(fitting_error_arrange,3)
%     error_to_cal=[];
%     for s=1:num_SDS
%         temp=fitting_error_arrange(start_index_arrange(i,s):end_index_arrange(i,s),s,i);
%         error_to_cal(end+1:end+length(temp))=temp;
%     end
%     total_fitting_error(i)=sqrt(mean(error_to_cal.^2));
% end

%% Plot
% load(fullfile('test_fitting_2024-07-02-17-13-15','fittingSDS_2345','fitting_info.mat'));

plot_index=[28:27*2;1:27;27*2+1:27*3];

xlabelname={'','\mu_{a,scalp}','\mu_{a,skull}','\mu_{a,CSF}','\mu_{a,GM}','','\mu_{s,scalp}','\mu_{s,skull}','\mu_{s,CSF}','\mu_{s,GM}',''};
color_arr=[0 0.4470 0.7410;0.9290 0.6940 0.1250;0.4660 0.6740 0.1880];
figure('Units','pixels','position',[0 0 1400 800]);
ti=tiledlayout(2,3,'Padding','none');
for i=1:3
    nexttile(ti);
    hold on
    plot([1 3 5 7],OP_ans_arrange(plot_index(i,:),1:4),'-o','Color',color_arr(i,:),'LineWidth',1);
    % color_arr=jet(size(fitted_param_arrange,1));
    
%     for i=1:size(fitted_param_arrange,1)
        plot([2 7],fitted_param_arrange(plot_index(i,:),:),'^','Color',color_arr(i,:),'LineWidth',1);
%     end
    % plot(repmat([2 7],size(fitted_param_arrange,1),1),fitted_param_arrange,'o','Color',[0 0.4470 0.7410],'LineWidth',2); %
    ylabel('(1/cm)')
    ylim([0 0.5]);

    yyaxis right
    bar(7,100*mean(OP_error(plot_index(i,:))),'Linestyle','none','FaceAlpha',0.5,'FaceColor',[0.8500 0.3250 0.0980]);
    errorbar(7,100*mean(OP_error(plot_index(i,:))),100*std(OP_error(plot_index(i,:))),'k','linestyle','none');
    % bar(7,100*mean(OP_error),'Linestyle','none','FaceAlpha',0.5);
    ylim([0 80]);
    ylabel('error(%)');
    
    xticks([0 1 3 5 7 8]);
    xticklabels(xlabelname(1:6));
    grid on
    box on
    set(gca,'FontName','Times New Roman','FontSize',14,'YColor',[0.8500 0.3250 0.0980]);
end

nexttile(ti);
t=tiledlayout(ti,1,1);
t.Layout.Tile=4;
for i=1:3
    hold on
    plot([1 3 5 7],OP_ans_arrange(plot_index(i,:),5:8),'-o','Color',color_arr(i,:),'LineWidth',1);
    xticks([0 1 3 5 7 8]);
    xticklabels(xlabelname(6:10));
    ylim([23 250])
    set(gca,'ytick',[],'FontName','Times New Roman','FontSize',14);

    
end
ax2=axes(t);
counts=histc(mus_arrange(plot_index(1,:)),mus_to_fit);
b1=barh(ax2,mus_to_fit,counts,'Linestyle','none','FaceAlpha',0.5);
set(b1,'FaceColor',color_arr(1,:));
hold on

counts=histc(mus_arrange(plot_index(2,:)),mus_to_fit);
b2=barh(ax2,mus_to_fit,counts,'Linestyle','none','FaceAlpha',0.5);
set(b2,'FaceColor',color_arr(2,:));

counts=histc(mus_arrange(plot_index(3,:)),mus_to_fit);
b3=barh(ax2,mus_to_fit,counts,'Linestyle','none','FaceAlpha',0.5);
set(b3,'FaceColor',color_arr(3,:));

xlabel('Counts');
ylabel('(1/cm)');
ylim([23 250]);

ax2.XAxisLocation='top';
ax2.Color='none';
ax2.XColor=[0.8500 0.3250 0.0980];
ax2.YColor=[0 0 0]; %[0 0.4470 0.7410];
grid on
set(gca,'FontName','Times New Roman','FontSize',14);

% ax2.Box = 'off';

% yyaxis right
% counts=histc(mus_arrange,mus_to_fit);
% bar(mus_to_fit,counts,'Linestyle','none','FaceAlpha',0.5) % ,'BarWidth',10
% ylabel('counts');
% yyaxis left
% plot(OP_ans_arrange(:,5:8),[1 3 5 7],'--o','LineWidth',1);
% 
% % plot(repmat(4,1,length(mus_to_fit)),mus_to_fit,'--o','Color',[0.8500 0.3250 0.0980],'LineWidth',1);
% % plot(4,mus_to_fit(min_index),'o','Color',[0.8500 0.3250 0.0980],'LineWidth',3);
% xlabel('\mu_s (1/cm)')
% xticks(mus_to_fit);
% xticklabels(mus_to_fit);
% % xlim([min([min(mus_to_fit) min(OP_ans_arrange(:,1:4),'all')]) max([max(mus_to_fit) min(OP_ans_arrange(:,1:4),'all')])]);
% % xlim([23 250]);
% yticks([0 1 3 5 7 8]);
% yticklabels(xlabelname(6:10));
% 
% 

print(fullfile(dir,'fitted_param.png'),'-dpng','-r200');
