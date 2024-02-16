%{
Observe the relation between the change of mus and its reflectance value in
each gate

Ting-Yi Kuo
Last update: 2023/08/01
%}

clear;close all;


num_SDS=5;
num_gate=10;

SDS_arr=[0.8 1.5 2.5 3.5 4.5];

sbj_arr = {'KB'};
dtof_arrange=[];

for sbj = 1
    mus_table = load(fullfile(sbj_arr{sbj},'mus_table.txt'));
    step=1;

    for sim = 1:378%size(mus_table,1)
        dtof=load(fullfile(sbj_arr{sbj},['DTOF_' num2str(sim) '.mat']));
        dtof_arrange(end+1,:)=dtof.to_save;
    end
end

% sbj_arr = {'KB_test'};
% dtof_arrange_test=[];
% 
% for sbj = 1
%     mus_table = load(fullfile(sbj_arr{sbj},'mus_table.txt'));
%     step=1;
% 
%     for sim = 1:size(mus_table,1)
%         dtof=load(fullfile(sbj_arr{sbj},['DTOF_' num2str(sim) '.mat']));
%         dtof_arrange_test(end+1,:)=dtof.to_save;
%     end
% end

% load('/home/md703/Documents/Ty/1_3_MCX_lookup_table/KB_2023-07-23-15-10-52/all_param_arr.mat')
% [~,index]=sort(all_param_arr(:,8));
% all_param_arr=all_param_arr(index,:);


mkdir('results');
close all;
for s=1:num_SDS
    fig=figure('Units','pixels','position',[0 0 1920 1080]); 
    ti=tiledlayout(2,5);
%     fig=figure; 
%     ti=tiledlayout('flow');
    step=1;
    for i=1+num_gate*(s-1):num_gate*s %2+num_gate*(s-1)
        nexttile;
        plot(dtof_arrange(370:378,8),dtof_arrange(370:378,8+i),'-o');
        hold on
%         plot(dtof_arrange(1:9,8),smoothdata(dtof_arrange(1:9,8+i),'sgolay',11,'Degree',3),'-o');
%         hold on
%         test=smoothdata(dtof_arrange(1:9,8+i));
% 
%         plot(dtof_arrange_test(:,8),dtof_arrange_test(:,8+i),'-o');
%         hold on
        
        xlabel('\mu_{s,GM}(1/cm)');
        ylabel('reflectance');
        title(['Gate ' num2str(step)]);
        step=step+1;
    end
%     lgd=legend('look up table','interpolation','test','Orientation','horizontal');
    lgd=legend('original','smooth7','true','smooth true','Orientation','horizontal');
    lgd.Layout.Tile='south';

    title(ti,['SDS ' num2str(SDS_arr(s)) ' cm']);
    print(fullfile('results',['SDS_' num2str(SDS_arr(s)) '_cm.png']),'-dpng','-r200');
end
        