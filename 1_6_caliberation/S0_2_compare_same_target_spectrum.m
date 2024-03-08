%{
Compare the spectrum of the same target or BG, to see if the spectrum are different

Benjamin Kao
Last update: 2020/12/05
%}

clc;clear;close all;

%% param
input_dir='20201126_test_12';
spec_name_prefix='SDS_spec_arr_'; % the filename before the phantom name, notice that there sourld be a [target_name_prefix 'BG'] in the input_dir
target_name_prefix='p1_'; % the name of the target to plot
target_index=[1:24]; % the index to plot
output_name='Compare_p1'; % the saved picture name
lineWidth=2;
fontSize=18;
lgdFontSize=12;
lgdNumCol=6;

%% init
target_name_arr={};
for i=1:length(target_index)
    target_name_arr{i}=[target_name_prefix num2str(target_index(i))];
end

color_arr=jet(length(target_name_arr));
% color_arr=[1 1 1].*(1:length(BG_name_arr))'/length(BG_name_arr);
legend_arr={};
for i=1:length(target_name_arr)
    legend_arr{i}=strrep(target_name_arr{i},'_',' ');
end
legend_arr{end+1}='CV';

%% main
BG_spec_arr={};
for i=1:length(target_name_arr)
    temp=load(fullfile(input_dir,[spec_name_prefix target_name_arr{i} '.mat']));
%     BG_spec_arr{i}=temp.SDS_spec_arr;
    for s=1:length(temp.SDS_spec_arr)
        SDS_BG_spec=medfilt1(mean(temp.SDS_spec_arr{s},2),5);
        BG_spec_arr{s}(i,:)=SDS_BG_spec;
    end
end

CV_spec=[];
for s=1:length(BG_spec_arr)
    CV_spec(s,:)=std(BG_spec_arr{s},[],1)./mean(BG_spec_arr{s},1);
end

%% plot mean
figure('Units','pixels','position',[0 0 1920 1080]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none');

for s=1:length(BG_spec_arr)
    nexttile();
    hold on;
    for i=1:length(target_name_arr)
        plot(BG_spec_arr{s}(i,:),'Color',color_arr(i,:),'LineWidth',lineWidth);
    end
    xlabel('pixel');
    ylabel('Reflectance');
    
    yyaxis right;
    plot(CV_spec(s,:)*100,'--','LineWidth',lineWidth);
    ylabel('CV(%)');
%     ylim([0 max(CV_spec(s,:))*200]);
    
%     lgd=legend(legend_arr,'Location','eastoutside','fontsize',legendFontSize);
    lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
    lgd.NumColumns = lgdNumCol;
    
    title(['SDS ' num2str(s)]);
    grid on;
    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
end
title(ti,target_name_prefix);
print(fullfile(input_dir,[output_name '.png']),'-dpng','-r300');

close all;

disp('Done!');