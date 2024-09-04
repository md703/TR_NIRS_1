%{
Evaluate random noise of the system

Ting-Yi Kuo
Last update: 2024/06/11
%}


mother_folder='20240521-bg';
folder_name='no_room_light_given_voltage_threshold_30';

end_index=250;
present_index=5;

load(fullfile(mother_folder,folder_name,'bg_TPSF_collect.mat'));
load(fullfile(mother_folder,folder_name,'bg_info_record.mat'));
figure;
plot(0:0.025:0.025*(end_index-1),TPSF_collect(1:end_index,present_index));
ylim([0 3]);
set(gca,'FontName', 'Times New Roman','Fontsize',12);
xlabel('Time (ns)');
ylabel('Counts');

print(fullfile(mother_folder,'bg_no_room_light_in_IRF_module.png'),'-dpng','-r200');
fprintf('Count rate: %d\n',info_record{present_index,4});


%%
folder_name='put_on_phantom';
present_index=1;

target_TPSF=load(fullfile(mother_folder,folder_name,[folder_name '_norm_TPSF_collect.txt']));
load(fullfile(mother_folder,folder_name,'bg_TPSF_collect.mat'));
load(fullfile(mother_folder,folder_name,'bg_info_record.mat'));
figure;
plot(0:0.025:0.025*(end_index-1),TPSF_collect(1:end_index,present_index));
ylim([0 3]);
set(gca,'FontName', 'Times New Roman','Fontsize',12);
xlabel('Time (ns)');
ylabel('Counts');

print(fullfile(mother_folder,'bg_no_room_light_on_phantom.png'),'-dpng','-r200');
fprintf('Count rate: %d\n',info_record{present_index,4});


%% plot noise within 1 second / 4 seconds
mother_folder='20240612-IRF';

load(fullfile(mother_folder,'bg','bg8','bg8_TPSF_collect.mat'));
bg1=TPSF_collect(1:501,:);

counts=sum(bg1,1);
legend_arr={};
for i=1:length(counts)
    legend_arr(end+1)={['total counts=' num2str(counts(i))]};
end

color_arr=jet(size(bg1,2));

figure('Units','pixels','Position',[0 0 900 400]);
ti=tiledlayout(1,2);
nexttile;
for i=1:size(bg1,2)
    patchline(0:0.025:0.025*500,bg1(:,i),'edgecolor',color_arr(i,:),'edgealpha',0.5);
    hold on
end

% create fake line to plot legend
none=[];
for i=1:size(bg1,2)
    h(i)=plot(NaN,NaN,'color',color_arr(i,:));
end
xlabel('time (ns)');
ylabel('Counts');
xlim([0 12.5]);

lgd=legend(h,legend_arr,'Location','southoutside','Orientation','horizontal');
lgd.NumColumns=3;
set(gca,'FontName','Times New Roman','FontSize',12);

legend_arr(end+1)={['mean total counts=' num2str(ceil(mean(counts([1 2 3 4 5 6 8]))))]};% [1 2 3 4 5 6 8]
nexttile;
shadedErrorBar(0:0.025:0.025*500,mean(bg1(:,[1 2 3 4 5 6 8]),2),std(bg1(:,[1 2 3 4 5 6 8]),[],2),'lineprops',{'LineWidth',2},'patchSaturation',0.5);
xlabel('time (ns)');
ylabel('Counts');
xlim([0 12.5]);
legend(legend_arr(end),'Location','southoutside');
set(gca,'FontName','Times New Roman','FontSize',12);

print(fullfile('results','background_analysis_8s.png'),'-dpng','-r200');


%% plot noise within 4 sec with the experimental value
blue=[0 0.4470 0.7410];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
color_arr={blue,orange,yellow};
mother_folder='20240612-IRF';

load(fullfile(mother_folder,'bg','bg8','bg8_TPSF_collect.mat'));
bg4=TPSF_collect(1:501,:);

mother_folder='20240612';

load(fullfile(mother_folder,'phantom_2_10_5_530','SDS1','SDS1_TPSF_collect.mat'));
SDS_1=TPSF_collect(1:501,:);

load(fullfile(mother_folder,'phantom_2_10_5_530','SDS2','SDS2_TPSF_collect.mat'));
SDS_2=TPSF_collect(1:501,:);

figure('Units','pixels','Position',[0 0 550 400]);
% color_arr=lines(3);
color_arr_2=jet(size(bg4,2));
hold on
plot(0:0.025:0.025*500,SDS_1,'Color',color_arr{2});  %
plot(0:0.025:0.025*500,SDS_2,'Color',color_arr{3});  %,'Color',color_arr(3,:)
for i=1:size(bg4,2)
    patchline(0:0.025:0.025*500,bg4(:,i),'edgecolor',color_arr_2(i,:),'edgealpha',0.6);
    hold on
end

% create fake line to plot legend
none=[];
for i=1:2
    h(i)=plot(NaN,NaN,'color',color_arr{i+1});
end
legend(h,{'SDS 1','SDS 2'});
xlabel('time (ns)');
ylabel('Counts');

set(gca,'Yscale','log','FontName','Times New Roman','FontSize',12);
print(fullfile('results','noise_influence.png'),'-dpng','-r200');






