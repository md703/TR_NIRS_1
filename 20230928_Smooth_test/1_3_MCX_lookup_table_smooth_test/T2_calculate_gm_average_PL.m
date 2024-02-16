%{
Calculate average pathlength of choosed layer

Ting-Yi Kuo
Last update: 2023/06/15
Version: 4.41
%}

clear;close all;

num_SDS=5;
num_gate=10;
target_mua=[0.46 0.31 0.042 0.32 0.17 0];
mua_changerate=[-20 -10 0 10 20];
changerate_examine_layer=[1 2 4];
layer_to_check=2; % 1:scalp, 2:skull, 4:gray matter for average pathlength
layer_name={'scalp','skull','CSF','GM'};
sbj_arr={'KB'}; %'KB','BY','BY','TY'

all_subject=[];
for sbj=1:length(sbj_arr)
    all_subject=[all_subject sbj_arr{sbj}];
end


testing_index=1;
for l=changerate_examine_layer % the layer to change
    for del_mus=1:length(mua_changerate)
        temp_mu_arr=target_mua;
        temp_mu_arr(l)=temp_mu_arr(l)*(1+mua_changerate(del_mus)/100);
        temp_param=zeros(1,6);
        temp_param(1,:)=temp_mu_arr;
        mua_param_arr(testing_index,:)=temp_param;

        testing_index=testing_index+1;
    end
end
mua_param_arr(:,5)=mua_param_arr(:,4)*0.5;

%% Arrange average pathlength of all 11 simulations with all subjects
mus_table=load('KB/mus_table.txt');
temp_gm_average_PL=zeros(num_gate,num_SDS,size(mus_table,1),length(sbj_arr));
temp_gm_average_PL_change_mua=zeros(size(mua_param_arr,1),num_SDS,length(sbj_arr));
for sbj=1:length(sbj_arr)
    for i=1:length(mus_table)
        load(fullfile(sbj_arr{sbj},['sim_' num2str(i)],'PL_1.mat'));
            
        for j=1:num_SDS
            for k=1:num_gate
                % for SDS and gate
                weight_arr=exp(-1*sum(double(SDS_detpt_arr{k,j}).*target_mua,2));
                weight_total=sum(exp(-1*sum(double(SDS_detpt_arr{k,j}).*target_mua,2)));
                weight_ratio=weight_arr/weight_total;

                temp_gm_average_PL(k,j,i,sbj)=sum(SDS_detpt_arr{k,j}(:,layer_to_check).*weight_ratio);
            end
            % for SDS
            weight_arr=exp(-1*sum(double(SDS_detpt_arr_orig{j}).*target_mua,2));
            weight_total=sum(exp(-1*sum(double(SDS_detpt_arr_orig{j}).*target_mua,2)));
            weight_ratio1=weight_arr/weight_total;
            
            temp_gm_average_PL_SDS(j,i,sbj)=sum(SDS_detpt_arr_orig{j}(:,layer_to_check).*weight_ratio1);
            
            if i==1 %看要用哪一個當作吸收係數變化的baseline
                for mua=1:size(mua_param_arr,1)
                    weight_arr=exp(-1*sum(double(SDS_detpt_arr_orig{j}).*mua_param_arr(mua,:),2));
                    weight_total=sum(exp(-1*sum(double(SDS_detpt_arr_orig{j}).*mua_param_arr(mua,:),2)));
                    weight_ratio=weight_arr/weight_total;

                    temp_gm_average_PL_change_mua(mua,j,sbj)=sum(SDS_detpt_arr_orig{j}(:,layer_to_check).*weight_ratio);
                end
            end
        end
    end
end
temp_gm_average_PL=mean(temp_gm_average_PL,4); % average the results of all subject
temp_gm_average_PL_SDS=mean(temp_gm_average_PL_SDS,3);
temp_gm_average_PL_change_mua=mean(temp_gm_average_PL_change_mua,3);


%% Calculate average pathlength using all 11 simulations
gm_average_PL=mean(temp_gm_average_PL,3); % average the rersults of all simulations 

cm = [1 0 0;1 1 1; 0 0 1];
cmi = interp1([-100; 0; 100], cm, (-100:100));

figure;
h=heatmap(gm_average_PL(:,1:5)','Colormap',cmi ,'CellLabelColor','none','GridVisible','off');
h.NodeChildren(3).YDir='normal';       
xlabel('Time gate');
ylabel('SDS');
title(['Average pathlength of ' layer_name{layer_to_check} ' (' all_subject ')']);
mkdir('results');
print(fullfile('results',['average_pathlength_' layer_name{layer_to_check} '_' all_subject '.png']),'-dpng','-r200');


%% Calculate the difference of average pathlength using mus,GM=200 as baseline, and change from -45% to 45%

% gm_average_PL_SDS=squeeze(sum(temp_gm_average_PL,1))';
% gm_average_PL_SDS=squeeze(sum(temp_gm_average_PL.*weight_ratio_SDS,1))';
gm_average_PL_SDS=temp_gm_average_PL_SDS';

choosed_index=[3:9]; % 7 8 9 10 11
baseline_index=6;
PL_change_ratio=gm_average_PL_SDS(choosed_index,:)./gm_average_PL_SDS(baseline_index,:)-1;

fig=figure('Units','pixels','position',[0 0 1000 540]);
ti=tiledlayout(1,2);

nexttile;
colormap_arr=jet(length(choosed_index));
ind=1;
for i=choosed_index
    plot(1:5,gm_average_PL_SDS(i,:),'Color',colormap_arr(ind,:),'LineWidth',1);
    hold on;
    ind=ind+1;
end
xticks([1:1:5]);
xlabel('SDS');
ylabel('average pathlength (cm)');

% % 用ANOVA看灰質散射係數對灰質平均路徑長有沒有顯著的影響
% prep=gm_average_PL_SDS(choosed_index,:);
% [p,tbl]=anova2(prep,1,'off');
% disp(tbl);
% title(['p value=' num2str(round(tbl{3,6},4))],'FontWeight','normal');

nexttile;
colormap_arr=jet(size(PL_change_ratio,1));
for i=1:size(PL_change_ratio,1)
    p=plot(1:1:5,100*PL_change_ratio(i,:),'-o','Color',colormap_arr(i,:),'LineWidth',1);
    hold on;
end
xticks([1:1:5]);
ylim([-100 100]);
xlabel('SDS');
ylabel('error(%)');
lgd=legend('-45%','-30%','-15%',['baseline=' num2str(mus_table(baseline_index,4))],'15%','30%','45%','Orientation','horizontal');
% lgd=legend('-20%','-10%',['baseline=' num2str(mus_table(baseline_index,4)) ' cm^{-1}'],'10%','20%','Orientation','horizontal');
% lgd=legend(num2str(mus_table(choosed_index,4)),'Orientation','horizontal');
lgd.Layout.Tile = 'south';
% title(ti,['Average pathlength of changing \mu_{s,GM} (' all_subject ')']);
title(ti,'Average pathlength of changing \mu_{s,GM}');
print(fullfile('results',['average_pathlength_of_changing_mus_GM_' all_subject '.png']),'-dpng','-r200');


% scatter plot
x=1:1:size(PL_change_ratio,1);
y=-15*x+60;

figure('Units','pixels','Position',[0 0 700 600]);
plot(x,y);
hold on;
p=plot(x,100*PL_change_ratio,'o','LineWidth',2);
yticks(-45:15:45);
xticks(1:1:7);
xticklabels(-45:15:45);
xlabel('\mu_{s,GM} error (%)');
ylabel('GM average pathlength error (%)');
legend(p,'SDS 1','SDS 2','SDS 3','SDS 4','SDS 5');
print(fullfile('results',['average_PL_compare_mus_GM_error_' all_subject '.png']),'-dpng','-r200');


%% Calculate the difference of average pathlength using different mua
PL_change_ratio=temp_gm_average_PL_change_mua./temp_gm_average_PL_change_mua(3,:)-1;

change_layer_arr={'\mu_{a,scalp}','\mu_{a,skull}','\mu_{a,GM}'};

x=1:1:length(mua_changerate);
figure('Units','pixels','Position',[0 0 1920 600]);
ti=tiledlayout(1,3)
for i=1:length(changerate_examine_layer)
    nexttile;
    p=plot(x,100*PL_change_ratio(1+length(mua_changerate)*(i-1):length(mua_changerate)*i,:),'o','LineWidth',2);
    xticks(1:1:length(mua_changerate));
    xticklabels(mua_changerate);
    yticks(mua_changerate);
    ylim([-20 20]);
    xlabel([change_layer_arr{i} ' error (%)']);
    ylabel('GM average pathlength error (%)');
end
legend('SDS 1','SDS 2','SDS 3','SDS 4','SDS 5');



%% 用ANOVA看灰質散射係數對灰質平均路徑長有沒有顯著的影響
% prep=gm_average_PL_SDS(choosed_index,:);
% [p,tbl]=anova2(gm_average_PL_SDS,1,'off');
% disp(tbl);


%% Test
% gm_average_PL_SDS=squeeze(sum(temp_gm_average_PL,1))';
% 
% choosed_index=[1:7];
% PL_change_ratio=gm_average_PL_SDS(choosed_index,:)./gm_average_PL_SDS(4,:)-1;
% 
% fig=figure('Units','pixels','position',[0 0 1000 540]);
% ti=tiledlayout(1,2);
% 
% nexttile;
% colormap_arr=jet(length(choosed_index));
% ind=1;
% for i=choosed_index
%     plot(1:5,gm_average_PL_SDS(i,:),'Color',colormap_arr(ind,:),'LineWidth',1);
%     hold on;
%     ind=ind+1;
% end
% xticks([1:1:5]);
% xlabel('SDS');
% ylabel('average pathlength (cm)');
% 
% nexttile;
% colormap_arr=jet(size(PL_change_ratio,1));
% for i=1:size(PL_change_ratio,1)
%     p=plot(1:1:5,100*PL_change_ratio(i,:),'-o','Color',colormap_arr(i,:),'LineWidth',1);
%     hold on;
% end
% xticks([1:1:5]);
% ylim([-10 10]);
% xlabel('SDS');
% ylabel('error(%)');
% lgd=legend('-20%','-10%','baseline','10%','20%','Orientation','horizontal');
% lgd.Layout.Tile = 'south';


