%{
Convert the segemented 3D voxel model to the mesh for finding the EEG
position and visualization.
Also save the voxel and mesh to a data structure
Please run 's1_Segmentation_Protocol.mlx' before run this script

Benjamin Kao
Last update: 2020/08/14
%}

clc;clear;close all;

%% param
to_process_folder={'MRI_raw_datas_2/F_51_60/Y51_F_F222007789','MRI_raw_datas_2/F_51_60/Y51_F_H19_Yeh_W1','MRI_raw_datas_2/F_51_60/Y52_F_EXP_09','MRI_raw_datas_2/F_51_60/Y52_F_H13_Liu','MRI_raw_datas_2/F_51_60/Y52_F_H25_Pan_D1','MRI_raw_datas_2/F_51_60/Y52_F_H25_Pan_W1','MRI_raw_datas_2/F_51_60/Y52_F_MINDFUL_CON_9','MRI_raw_datas_2/F_51_60/Y52_F_NSC13-15_TCC_H08_Zheng','MRI_raw_datas_2/F_51_60/Y53_F_NSC13-15_TCC_H25','MRI_raw_datas_2/F_51_60/Y54_F_H22_NI_W3','MRI_raw_datas_2/F_51_60/Y54_F_H22_Ni_W1','MRI_raw_datas_2/F_51_60/Y54_F_TCC_H83','MRI_raw_datas_2/F_51_60/Y55_F_A160901_NTUAC_S041','MRI_raw_datas_2/F_51_60/Y55_F_EXP_06','MRI_raw_datas_2/F_51_60/Y55_F_EXP_10','MRI_raw_datas_2/F_51_60/Y55_F_EXP_14','MRI_raw_datas_2/F_51_60/Y55_F_NSC13-15_TCC_H10_Lin','MRI_raw_datas_2/F_51_60/Y56_F_A203969296','MRI_raw_datas_2/F_51_60/Y56_F_EXP05','MRI_raw_datas_2/F_51_60/Y56_F_MINDFUL_CON_10','MRI_raw_datas_2/F_51_60/Y56_F_NTUAC_S031','MRI_raw_datas_2/F_51_60/Y57_F_A170801_MINDFULCON_CHIO','MRI_raw_datas_2/F_51_60/Y57_F_MINDFUL_EX01','MRI_raw_datas_2/F_51_60/Y57_F_NSC13-15_TCC_H04_Wang','MRI_raw_datas_2/F_51_60/Y57_F_NSC13-15_TCC_H07_Chu','MRI_raw_datas_2/F_51_60/Y57_F_NSC15-16-H20-Lin-W6','MRI_raw_datas_2/F_51_60/Y58_F_H06_Liang','MRI_raw_datas_2/F_51_60/Y58_F_H06_Liang_Post','MRI_raw_datas_2/F_51_60/Y59_F_11_02','MRI_raw_datas_2/F_51_60/Y60_F_H12_CHUNG','MRI_raw_datas_2/F_51_60/Y60_F_H41','MRI_raw_datas_2/F_61_70/Y67_F_H50_PRE','MRI_raw_datas_2/F_61_70/Y68_F_B121126_s014','MRI_raw_datas_2/F_61_70/Y68_F_H18_Tsai_D1','MRI_raw_datas_2/F_61_70/Y68_F_H33_Chuang_W1','MRI_raw_datas_2/F_61_70/Y68_F_H33_Chuang_W3','MRI_raw_datas_2/F_61_70/Y68_F_H33_Chung_W6','MRI_raw_datas_2/F_61_70/Y68_F_H34_Liao_D1','MRI_raw_datas_2/F_61_70/Y69_F_B130723_S113','MRI_raw_datas_2/F_61_70/Y70_F_B131002_S034'}; % the folder contains the segmented MRI model
subject_arr={'Y51_F_F222007789','Y51_F_H19_Yeh_W1','Y52_F_EXP_09','Y52_F_H13_Liu','Y52_F_H25_Pan_D1','Y52_F_H25_Pan_W1','Y52_F_MINDFUL_CON_9','Y52_F_NSC13-15_TCC_H08_Zheng','Y53_F_NSC13-15_TCC_H25','Y54_F_H22_NI_W3','Y54_F_H22_Ni_W1','Y54_F_TCC_H83','Y55_F_A160901_NTUAC_S041','Y55_F_EXP_06','Y55_F_EXP_10','Y55_F_EXP_14','Y55_F_NSC13-15_TCC_H10_Lin','Y56_F_A203969296','Y56_F_EXP05','Y56_F_MINDFUL_CON_10','Y56_F_NTUAC_S031','Y57_F_A170801_MINDFULCON_CHIO','Y57_F_MINDFUL_EX01','Y57_F_NSC13-15_TCC_H04_Wang','Y57_F_NSC13-15_TCC_H07_Chu','Y57_F_NSC15-16-H20-Lin-W6','Y58_F_H06_Liang','Y58_F_H06_Liang_Post','Y59_F_11_02','Y60_F_H12_CHUNG','Y60_F_H41','Y67_F_H50_PRE','Y68_F_B121126_s014','Y68_F_H18_Tsai_D1','Y68_F_H33_Chuang_W1','Y68_F_H33_Chuang_W3','Y68_F_H33_Chung_W6','Y68_F_H34_Liao_D1','Y69_F_B130723_S113','Y70_F_B131002_S034'};
output_folder='model2';

%% init
mkdir(output_folder);

%% main
% for i=1:length(to_process_folder)
for i=20
    clear vol subject headsurf pialsurf;
    subject=subject_arr{i};
    fprintf('Processing %s, folder %d/%d\n',subject,i,length(to_process_folder));
        
    vol=niftiread(fullfile(to_process_folder{i},'segmented_tissue.nii'));
    
    % rotate the model to right orientation
    new_vol=[];
    for z=1:size(vol,3)
        temp_slice=vol(:,:,z);
        temp_slice=temp_slice';
        temp_slice=temp_slice(end:-1:1,:);
        new_vol(:,:,z)=temp_slice;
    end
    vol=new_vol;
    
    vol=fillholes3d(vol,2);
        
    % padding 0 to the boundary
    vol(:,:,2:end+1)=vol;
    vol(:,:,1)=0;
    vol(:,2:end+1,:)=vol;
    vol(:,1,:)=0;
    vol(2:end+1,:,:)=vol;
    vol(1,:,:)=0;
    vol(end+1,:,:)=0;
    vol(:,end+1,:)=0;
    vol(:,:,end+1)=0;
    
    % make the right coordinate for isosurface to generate mesh
    [xx,yy,zz]=ndgrid(1:size(vol,1),1:size(vol,2),1:size(vol,3));
    
    headsurf=isosurface(xx,yy,zz,vol,0); % head surface
    temp_vol=vol;
    temp_vol(temp_vol==6)=2; % if there is sinus in the model, change it to skull to prevent wierd brain surface
    pialsurf=isosurface(xx,yy,zz,temp_vol,3); % brain surface
    
    %% plot
    figure();
    patch(headsurf,'FaceColor',[0.8 0.8 1.0],'EdgeColor','black','FaceLighting','gouraud','AmbientStrength',0.35);
    title('head surface');
    view(3);
    xlabel('x axis');
    ylabel('y axis');
    figure();
    patch(pialsurf,'FaceColor',[0.8 0.8 1.0],'EdgeColor','black','FaceLighting','gouraud','AmbientStrength',0.15);
    title('brain surface');
    view(3);
    xlabel('x axis');
    ylabel('y axis');

    %% save
    save(fullfile(output_folder,['headModel' subject '.mat']),'subject','vol','headsurf','pialsurf');
    close all;
end

disp('Done!');