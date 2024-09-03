%{
Plot the result compare MCS value and ANN predicted value

Ting-Yi Kuo
Last edited: 2023/12/31
%}

global cw_net cw_param_range tr_net tr_param_range;

if ~exist('results','dir')
    mkdir('results');
end

mu_table=load(fullfile('KB','mu_table.txt'));

dtof_arrange=[];
load('model_arrange/KB_tr_model.mat');
SDS_length_arr_tr=[1.5 2.2 2.9 3.6 4.3];

dtof_true=[];
dtof_ANN=[];

plot_index=1;
for sim=1:size(mu_table,1)
    load(fullfile('KB',['DTOF_' num2str(sim) '.mat']));
    dtof_true(sim,:)=to_save(9:58);
    
    input=mu_table(sim,[1 5 2 6 3 7 4 8]);
    dtof_ANN(sim,:)=fun_ANN_forward(input,1);
    
   if sim==1
       RMSPE=(dtof_ANN(sim,:)-dtof_true(sim,:))./dtof_true(sim,:);
       fig=figure('Units','pixels','position',[0 0 1920 1080]);
       ti=tiledlayout('flow','TileSpacing','Compact','Padding','Compact');
       for s=1:5
           nexttile;
           semilogy(1:1:10,dtof_true(sim,1+(s-1)*10:10*s),'-^','Linewidth',2);
           hold on
           semilogy(1:1:10,dtof_ANN(sim,1+(s-1)*10:10*s),'-o','Linewidth',1);
           hold on
           xlabel('time gate')
           ylabel('reflectance')
           
           yyaxis right
           ax = gca;
           plot(1:1:10,100*RMSPE(1+(s-1)*10:10*s),'-o','Linewidth',1,'Color',[0 0.6 0]);
           hold on
           plot(1:1:10,zeros(1,10),'--','Linewidth',1.5,'Color',[0 0.6 0]);
           ax.YColor=[0 0.6 0];
           ylabel('percentage error (%)');
           xlim([1 10]);
           title(['SDS ' num2str(SDS_length_arr_tr(s)) ' cm']);
           set(gca,'FontName', 'Times New Roman','fontsize',16);
       end
       lgd=legend('MC','model','Orientation','horizontal','fontsize',16);
       legend box off
       lgd.Layout.Tile='south';
       print(fullfile('results','compare_result_each_SDS.png'),'-dpng','-r200');
   end
end

% RMSPE=sqrt(mean(((dtof_ANN-dtof_true)./dtof_true).^2,'all'));
RMSPE=sqrt(mean(((dtof_ANN(:,[1:40 42:end])-dtof_true(:,[1:40 42:end]))./dtof_true(:,[1:40 42:end])).^2,'all'));

min_value=min(dtof_true,[],'all');
max_value=max(dtof_true,[],'all');

figure('Units','pixels','position',[0 0 640 540]);
nexttile;
plot([min_value max_value],[min_value max_value],'Color',[0.3010 0.7450 0.9330],'Linewidth',2);
hold on
plot(dtof_true,dtof_ANN,'o','Color',[0 0.4470 0.7410],'Linewidth',2);

title(['RMSPE = ' num2str(100*RMSPE) '%']);
xlabel('Monte Carlo simulation value');
ylabel('ANN predicted value');
set(gca,'FontName', 'Times New Roman','fontsize',16);

print(fullfile('results','compare_result_total.png'),'-dpng','-r200');



