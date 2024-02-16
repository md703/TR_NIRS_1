%{
Plot the segmented result compares to the original MRI image

Not finish yet QQ

Benjamin Kao
Last update: 2020/03/29
%}

clc;clear;close all;

% param
save_mode=1; % 1 for image, 2 for video

mri_image_cscale=50;

input_dir='YF_MRI';
subject_name='YF';
model_dir='model';
seged_vol=load(fullfile(model_dir,['headModel' subject_name '_EEG.mat']));
seged_vol=seged_vol.vol;

%% main
file = dir(fullfile(input_dir,'r*.nii'));
assert(length(file)==1,['There are more files named ''r*.nii'' in folder ' input_dir]);
% orig_image = niftiread(fullfile(to_process_folder{i},file.name));
orig_image = niftiread(fullfile(input_dir,file.name));

crop_region=load(fullfile(input_dir,'crop_range.txt'));
orig_image=orig_image(crop_region(1):crop_region(2),crop_region(3):crop_region(4),crop_region(5):crop_region(6));

max_z=min(size(orig_image,3),size(seged_vol,3));

orig_image=double(orig_image);
orig_image=orig_image/max(orig_image(:))*mri_image_cscale;
seged_vol=seged_vol+mri_image_cscale+1;

figure();

for z=1:max_z
    imagesc(orig_image(:,:,z));
    hold on;
    
%     colorTickLabel={'sclap','WM','0'};
%     colorTick=[1 5 6 to_label_colorScale];
    
    imagesc(seged_vol(:,:,z),'AlphaData',0.4);
    title([subject_name ' layer ' num2str(z)]);
    colorbar;
    colormap([gray(mri_image_cscale+1);jet(6)]);
    caxis([0 mri_image_cscale+6]);
%     colorbar('Ticks',colorTick,'TickLabels',colorTickLabel);
    hold off;
    axis off;
    drawnow;
%     if do_output_video
%         frame = getframe(gcf);
%         writeVideo(v,frame);
%     end
end