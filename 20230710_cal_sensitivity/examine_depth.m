%{
Examine the distance of every detector from surface to gray matter.

Ting-Yi Kuo
Last update: 2023/12/25
%}

num_SDS=5;
set=1000;

sbj_arr={'KB'};  %,'ZJ','WH','WW','BY','CT','TY','CS'
dist2_pial=zeros(length(sbj_arr),num_SDS);

for sbj=1:length(sbj_arr)
    load(fullfile('head_models',['headModel' sbj_arr{sbj} '_EEG.mat']));
    pos=load(fullfile('head_models',[sbj_arr{sbj} '_probe_pos.txt']));
    dir=load(fullfile('head_models',[sbj_arr{sbj} '_probe_dir.txt']));
    

    nearest_point=zeros(num_SDS,3);
    
    for s=1:num_SDS
        volume=vol;
        now_pos=pos(s+1,:);
        now_dir=dir(s+1,:);
        
        dist=sqrt(sum((pialsurf.vertices-now_pos).^2,2));
        [sort_dist,sort_index]=sort(dist);
        dist2_pial(sbj,s)=sort_dist(1);
        nearest_point(s,:)=pialsurf.vertices(sort_index(1));
        
        % plot the section of head model
%         figure;
%         volume(round(pos(s,1)),round(pos(s,2)),round(pos(s,3)))=7;
%         volume(round(nearest_point(s,1)),round(nearest_point(s,2)),round(nearest_point(s,3)))=7;
%         heatmap(squeeze(volume(:,:,round(pos(s,3)))));
%         title(['SDS ' num2str(s)]);
%         grid off;
    end
    % plot the section of head model
    figure;
    colormap_arr=[1,1,1; 0,0,1;0,1,1;0.5,1,0;1,1,0;1,0.5,0;1,0,0];
    section_point=mean(pos);
    section_surface=squeeze(volume(:,:,round(section_point(1,3))));
    imagesc(section_surface);
    colormap(colormap_arr);
    caxis([0,7]);
    colorbar('Ticks', 0:6, 'TickLabels', {'air', 'scalp', 'skull', 'CSF', 'GM', 'WM', 'sinus'});
    box off;
    axis off;
    print(fullfile('results',['headmodel_section_' sbj_arr{sbj}]),'-dpng','-r200');
end

avg_dist2_pial=mean(dist2_pial,1);
        
        