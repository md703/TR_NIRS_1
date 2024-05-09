

sbj_name={'KB'};

figure;
map = {'#ffffff','#6666FF','#66FFFF','#B2FF66','#FFFF66','#FFB266','#FF6666'};
cmap = validatecolor(map, 'multiple');
colormap(cmap)

for i=1:length(sbj_name)
    load(fullfile('models',['headModel' sbj_name{i} '_EEG.mat']));
    Fp2=round(EEG.Fp2);
    
    h=imagesc(squeeze(vol(:,:,Fp2(3)))');
    colorbar;
    caxis([0, 7]);
    colorbar('Ticks', 1:7, 'TickLabels', {'air', 'scalp', 'skull', 'CSF', 'GM', 'WM', 'sinus'});
    axis off;

%     title(sbj_name{i});
    
    if ~exist('results','file')
        mkdir('results');
    end

    print(fullfile('results',[sbj_name{i} '_segmentation_result.png']),'-dpng','-r200');
end
