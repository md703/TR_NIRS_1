%{
Plot the smooth result in one figure

Ting-Yi Kuo
Last update: 2023/11/14
%}

clc;%clear;close all;


%% param
subject_name_arr={'CT'};
lookup_table_arr='../1_3_MCX_lookup_table'; % the dir containing the unmerged lookup table

bs_value=[];
as_value=[];
true_value=[];

for sbj_i=1:length(subject_name_arr)
    %% init
    subject_name=subject_name_arr{sbj_i};
    output_dir=fullfile('results_smooth',subject_name);
    lkt_dir=fullfile(lookup_table_arr,subject_name); % the dir containing the unmerged lookup table
    
    % load lookup table information
    lkt_sim_set=load(fullfile(lkt_dir,'sim_set.mat'));
    lkt_sim_set=lkt_sim_set.sim_set;
    lkt_layer_mus=load(fullfile(lkt_dir,'layer_mus.mat'));
    lkt_layer_mus=lkt_layer_mus.layer_mus;
    lkt_mus_table=load(fullfile(lkt_dir,'mus_table.txt'));

    % find index
    ls=[100 50 23];
    ms=[150 125 23];
    hs=[225 200 23];
    
    index_ls=[];
    index_ms=[];
    index_hs=[];
    
    for i=1:size(lkt_mus_table, 1)
        if isequal(lkt_mus_table(i,1:3),ls)
            index_ls=[index_ls,i];
        elseif isequal(lkt_mus_table(i,1:3),ms)
            index_ms=[index_ms,i];
        elseif isequal(lkt_mus_table(i,1:3),hs)
            index_hs=[index_hs,i];
        end
    end
    
    load(fullfile(output_dir,'lkt_ref_value_arr_bs.mat'));
    load(fullfile(output_dir,'lkt_ref_value_arr_as.mat'));
    
    bs_value=[bs_value; squeeze(lkt_ref_value_arr_bs(index_ls,size(lkt_ref_value_arr_bs,2),:))];
    bs_value=[bs_value; squeeze(lkt_ref_value_arr_bs(index_hs,size(lkt_ref_value_arr_bs,2),:))];
    
    as_value=[as_value; squeeze(lkt_ref_value_arr_as(index_ls,size(lkt_ref_value_arr_as,2),:))];
    as_value=[as_value; squeeze(lkt_ref_value_arr_as(index_hs,size(lkt_ref_value_arr_as,2),:))];
    
    mus_table = load(fullfile(subject_name,'mus_table.txt'));
    for sim = 1:size(mus_table,1)
        dtof=load(fullfile(subject_name,['DTOF_' num2str(sim) '.mat']));
        dtof_arrange=dtof.to_save;
        true_value(end+1,:)=dtof_arrange(:,9:end);
    end

end

%% plot the smooth result in one graph
figure('Units','pixels','position',[0 0 500 400]); % 
dtof_arrange(dtof_arrange==0)=NaN;

max_ref=max(dtof_arrange(:,9:end),[],'all');
min_ref=min(dtof_arrange(:,9:end),[],'all');

true_=true_value(:,[1:30 32:40 42:50]); % skip gate 1 data
bs=bs_value(:,[1:30 32:40 42:50]);
as=as_value(:,[1:30 32:40 42:50]);

orig_rmspe=sqrt(mean(((bs-true_)./true_).^2,'all'));
smooth_rmspe=sqrt(mean(((as-true_)./true_).^2,'all'));


plot([min_ref max_ref],[min_ref max_ref]);
hold on;
p1=plot(true_(:),bs(:),'.','Color',[0 0 0.55],'markersize',12);
p2=plot(true_(:),as(:),'.','Color',[0.8500 0.3250 0.0980],'markersize',12); %[1 0.27 0] [0.91 0.59 0.48]
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');

title({['Original RMSPE = ' num2str(100*orig_rmspe) '%'];['RMSPE = ' num2str(100*smooth_rmspe) '%']},'FontWeight','Normal');

xlim([min_ref max_ref]);
ylim([min_ref max_ref]);

xlabel('ground truth');
ylabel('reflectance');
legend([p1,p2],{'original value','denoised value'},'Location','northwest');
set(gca,'fontsize',14);

print(fullfile('results_smooth','smooth_result.png'),'-dpng','-r200');



%% Plot smooth effect
mus_ub=[250 225 23 275]; % 1/cm, skip CSF
mus_lb=[75 25 23 25]; % 1/cm, skip CSF

lkt_value=lkt_ref_value_arr_bs(:,1001,36);
lkt_4D_bs=lkt_value(in_place_arr);

lkt_value=lkt_ref_value_arr_as(:,1001,36);
lkt_4D_as=lkt_value(in_place_arr);


f=figure('Units','pixels','position',[0 0 640 540]);
% set(f,'visible','off');
[X,Y] = meshgrid(mus_lb(2):25:mus_ub(2),mus_lb(4):25:mus_ub(4));
surf(X,Y,squeeze(lkt_4D_as(2,:,1,:))','EdgeColor','None');
xlabel('\mu_{s,skull}');
ylabel('\mu_{s,gray matter}');
zlabel('Reflectance');
hold on;

to_plot=reshape(squeeze(lkt_4D_bs(2,:,1,:))',[],1);
X=reshape(X,[],1);
Y=reshape(Y,[],1);
scatter3(X,Y,to_plot,20,'red','filled');
set(gca,'fontsize',16);

print(fullfile('results_smooth','smooth_effect.png'),'-dpng','-r200');


