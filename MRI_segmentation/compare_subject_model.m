%{
Compare the segmented model for subjects

Benjamin Kao
Last update: 2020/03/30
%}

clc;clear;close all;

do_output_video=1;

model_dir='model';
subject_name_arr={'KB','ZJ','WW','WH'};
output_dir='compare_subject_model';

%% init
mkdir(output_dir);

model_arr={};
max_z=inf;
for i=1:length(subject_name_arr)
    temp_model=load(fullfile(model_dir,['headModel' subject_name_arr{i} '_EEG.mat']));
    model_arr{i}=temp_model.vol;
    max_z=min(max_z,size(model_arr{i},3));
end

for i=1:length(subject_name_arr)
    model_arr{i}=model_arr{i}(:,:,(size(model_arr{i},3)-max_z+1):end);
end

break_index=0;
while max_z>1
    for i=1:length(subject_name_arr)
        if sum(sum(sum(model_arr{i}(:,:,max_z))))>0
            break_index=1;
            break;
        end
    end
    if break_index==1
        break;
    end
    max_z=max_z-1;
end

min_z=1;
break_index=0;
while min_z<max_z
    for i=1:length(subject_name_arr)
        if sum(sum(sum(model_arr{i}(:,:,min_z))))>0
            break_index=1;
            break;
        end
    end
    if break_index==1
        break;
    end
    min_z=min_z+1;
end

if do_output_video
    v = VideoWriter(fullfile(output_dir,['compare_subject.avi']));
    v.FrameRate=20;
    open(v);
end

figure('units','normalized','outerposition',[0 0 0.64 0.8]);
ti=tiledlayout('flow','TileSpacing','compact','Padding','none');

for z=max_z:-1:min_z
    for i=1:length(subject_name_arr)
        nexttile(i);
        imagesc(model_arr{i}(:,:,z));
        colormap(jet);
        colorbar('Ticks',[1 2 3 4 5],'TickLabels',{'scalp','skull','CSF','GM','WM'});
        caxis([0 5]);
        title(subject_name_arr{i});
    end
    
    title(ti,['layer ' num2str(z)]);
    drawnow;
    if do_output_video
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
end

if do_output_video
    close(v);
end
close all;

disp('Done!');