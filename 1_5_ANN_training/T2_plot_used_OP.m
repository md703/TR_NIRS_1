%{
Plot the used OP to train ANN

Ting-Yi Kuo
Last updated: 2023/12/31
%}



% cw
layer_mu_cw={[50:25:350],[50:37.5:350],[10 19 28 37],[50:60:350],[0.1 0.6],[0.05 0.45],[0.015 0.1],[0.05 0.5]};
load('./KB_interpolation_result_cw/all_param_arr.mat');
interp_mus_cw=all_param_arr(1:5808,5:8);
%%% should be deleted
index=find(interp_mus_cw(:,1)>350);
interp_mus_cw=[interp_mus_cw(1:index-1,:); interp_mus_cw(index+1:end,:)];
%%%
interp_mua_cw=unique(all_param_arr(:,1:4),'rows');
% plot_used_OP(layer_mu_cw,interp_mus,interp_mua);

all_param_arr=[];
% tr
layer_mu_tr={[75:25:250],[25:25:225],23,[25:25:275],[0.1 0.45],[0.1 0.3],[0.042],[0.1 0.4]};
load('../1_4_MCX_lookup_table_dataGen/KB_2023-12-31-18-11-02//all_param_arr.mat');
interp_mus_tr=all_param_arr(1:1793,5:8);
interp_mua_tr=unique(all_param_arr(:,1:4),'rows');


figure('Unit','pixels','Position',[0 0 1080 500]);
ti=tiledlayout(1,2);
nexttile;
for i=1:4
    h1=plot(i,interp_mus_cw(:,i)/10,'.','Color',[0 0.4470 0.7410],'MarkerSize', 10);
    hold on
    plot(i,layer_mu_cw{i}/10,'o','Color',[0 0.4470 0.7410],'Linewidth',2);
end

for i=1:4
    h2=plot(i+0.2,interp_mus_tr(:,i)/10,'.','Color',[0.4660 0.6740 0.1880],'MarkerSize', 10);
    hold on
    plot(i+0.2,layer_mu_tr{i}/10,'o','Color',[0.4660 0.6740 0.1880],'Linewidth',2);
end

% legend([h1(1), h2(1)],'CW','TR');
xlim([0.2 5]);
ylim([0 40]);
xticks([1.1 2.1 3.1 4.1]);
xticklabels({'\mu_{s,scalp}','\mu_{s,skull}','\mu_{s,CSF}','\mu_{s,GM}'});

ylabel('mm^{-1}');
set(gca,'fontsize',18);

nexttile;
for i=1:4
    h1=plot(i,interp_mua_cw(:,i)/10,'.','Color',[0 0.4470 0.7410],'MarkerSize', 10);
    hold on
end

for i=1:4
    h2=plot(i+0.2,interp_mua_tr(:,i)/10,'.','Color',[0.4660 0.6740 0.1880],'MarkerSize', 10);
    hold on
end

% legend([h1(1), h2(1)],'CW','TR');
xlim([0.2 5]);
xticks([1.1 2.1 3.1 4.1]);
xticklabels({'\mu_{a,scalp}','\mu_{a,skull}','\mu_{a,CSF}','\mu_{a,GM}'});
ylabel('mm^{-1}');
set(gca,'fontsize',18);

lgd=legend([h1(1), h2(1)],'Continuous-wave','Time-resolved','orientation','horizontal');
lgd.Layout.Tile='south';
legend boxoff


if ~exist('results','dir')
    mkdir('results');
end
print(fullfile('results','used_OP.png'),'-dpng','-r200');

