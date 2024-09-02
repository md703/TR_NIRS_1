%{
Calculate average pathlength of gray matter

Ting-Yi Kuo
Last update: 2023/06/15
%}

num_SDS=5;
num_gate=10;
target_mua=[0.3 0.2 0.042 0.27 0.135 0];

num_layer=5;

mus_table=load('KB/mus_table.txt');
gm_PL_ratio=[];zeros(length(mus_table),num_SDS*num_gate);
for i=1:length(mus_table)
    load(fullfile('KB',['sim_' num2str(i)],'PL_1.mat'));
    for s=1:num_SDS
        for g=1:num_gate
            weight_arr=exp(-1*sum(double(SDS_detpt_arr{g,s}).*target_mua,2));
            weight_total=sum(exp(-1*sum(double(SDS_detpt_arr{g,s}).*target_mua,2)));
            weight_ratio=weight_arr/weight_total;
            for l=1:num_layer
    %         gm_PL_ratio(i,j)=sum(SDS_detpt_arr{j}(:,4).*weight_ratio);
                gm_PL_ratio(g,s,l,i)=sum(SDS_detpt_arr{g,s}(:,l).*weight_ratio);
            end
        end
    end
end

gm_PL_ratio=mean(gm_PL_ratio,4);

% for i=1:num_SDS
%     gm_PL_ratio_2(i,:,l)=squeeze(gm_PL_ratio(1,1+num_gate*(i-1):num_gate+num_gate*(i-1),l));
% end
%%
cm = [1 0 0;1 1 1; 0 0 1];
cmi = interp1([-100; 0; 100], cm, (-100:100));

title_arr={'scalp','skull','CSF','GM','WM'};

figure('Units','pixels','Position',[0 0 990 1080]);
ti=tiledlayout(3,2,'TileSpacing','compact');
for l=1:num_layer
    nexttile;
    h(l)=heatmap(gm_PL_ratio(:,:,l),'Colormap',jet*0.65+0.35,'ColorbarVisible','off','GridVisible','off'); %,'CellLabelColor','none'
    h(l).CellLabelFormat = '%.2f';
%     h(l).NodeChildren(3).YDir='normal';       
    xlabel('SDS');
    ylabel('Time gate');
    title(title_arr(l));
    ax=gca;
    axp=struct(ax);       %you will get a warning
    axp.Axes.XAxisLocation = 'top';
    set(gca,'FontName','Times New Roman','FontSize',12);
    
end
colorLims = vertcat(h.ColorLimits);
globalColorLim = [min(colorLims(:,1)), max(colorLims(:,2))];
set(h, 'ColorLimits', globalColorLim)

ax = axes(ti,'visible','off','Colormap',h(1).Colormap,'CLim',globalColorLim);
cb = colorbar(ax);
ylabel(cb,'average pathlength (cm)','FontSize',12,'Rotation',270);
cb.Label.Position(1) = 5;
cb.Layout.Tile = 'East';
print(fullfile('results','average_PL_for_each_layer.png'),'-dpng','-r200');