%{
Calculate the position of EEG on the head MRI model
Please run 's3_find_fiducials.m' before run this script

Benjamin Kao
Last update: 2020/08/15
%}

clc;clear;close all;

%% params

model_folder='model2';
subject_name='Y70_F_B131002_S034';
num_EEG_system=1; % if ==1, then only calculate 10-5 system; if ==2, also calculate 10-10 system; if ==3, also calculate 10-20 system
voxel_size=0.93; % the length of side of each voxel in the MRI voxel model, in mm
model_version=2;
do_sinus=1; % if the model have sinus or not

random_change_size=8; % the size of random change the reference points


%% load the params
load(fullfile(model_folder,['headModel' subject_name '.mat']));

%% load fiducial (reference) points
% Nasion position (Nz): indentation at the top of the nose approximately between the eyebrows
% Inion position (Iz): indentation at the back of the head approximately where the neck begins
% (The orientation is seen from above with nose on top)
% Left preauricular position (M1): indentation in front of the top of the ear cannal, dent between the upper edge of the targus and the daith
% Right preauricular position (M2): indentation in front of the top of the ear cannal, dent between the upper edge of the targus and the daith

% Fiducials = [Nasion position;
%              Inion position;
%              Left preauricular position;
%              Right preauricular position];

Fiducials=load(fullfile(model_folder,['Fiducials_' subject_name '.txt']));

%% calculate EEG positions
% Run function. 
% Inputs: Fiducial positions
%         Mesh Faces (surface elements)
%         Mesh Vertices (nodes)
%         Layout option (1: 10-5, 2: 10-10, 3: 10-20)
%         Coordinate transformation option (0: leaves the coordinate system
%         as is, 1: transforms the coordinates of the mesh vertices to
%         align coordinate system with fiducials, such that the origin
%         lies in the midpoint between M1 and M2 and Nz lies normal to the
%         segment M1-M2 in the negative x-direction.
% Outputs: [x,y,z] coordinates of each EEG position
%          Labels for each position 
orig_Fiducials=Fiducials;
retry_counter=1;
while true
    try
        assert(num_EEG_system>=1);
        [EEGPts1,EEGLab1] = ComputeEEGPos(Fiducials,headsurf.faces,headsurf.vertices,1,0);
        if num_EEG_system>=2
            [EEGPts2,EEGLab2] = ComputeEEGPos(Fiducials,headsurf.faces,headsurf.vertices,2,0);
        end
        if num_EEG_system>=3
            [EEGPts3,EEGLab3] = ComputeEEGPos(Fiducials,headsurf.faces,headsurf.vertices,3,0);
        end
        break;
    catch
        fprintf('Retrying the %d time\n',retry_counter);
        retry_counter=retry_counter+1;
        Fiducials=orig_Fiducials+(rand(size(orig_Fiducials))-0.5)*random_change_size;
    end
end

if retry_counter>1
    save(fullfile(model_folder,['Fiducials_' subject_name '.txt']),'Fiducials','-ascii','-tabs');
end

%% plot result
figure
patch(headsurf,'FaceColor',[0.8 0.8 1.0],'EdgeColor','none','FaceLighting','gouraud','AmbientStrength',0.15);
% Lights, axis, and view
camlight('headlight');
material('dull');
% light('Position',[0 -.75 -0.5],'Style','infinite'); % add extra lights
axis('image');
view([-135 35]);

% Visualize EEG points
hold on
if num_EEG_system==1
    plot3(EEGPts1(:,1),EEGPts1(:,2),EEGPts1(:,3),'ro','MarkerSize',10,'LineWidth',2)
else
    plot3(EEGPts1(:,1),EEGPts1(:,2),EEGPts1(:,3),'.','MarkerSize',15)
    if num_EEG_system>=2
        plot3(EEGPts2(:,1),EEGPts2(:,2),EEGPts2(:,3),'ro','MarkerSize',10,'LineWidth',2)
    end
    if num_EEG_system>=3
        plot3(EEGPts3(:,1),EEGPts3(:,2),EEGPts3(:,3),'yh','MarkerSize',10,'LineWidth',2)
    end
end

for i=1:length(EEGLab1)
    text(EEGPts1(i,1),EEGPts1(i,2),EEGPts1(i,3),EEGLab1{i},'FontSize',12);
end

legend_arr={'Mesh','EEG 10-5 positions','EEG 10-10 positions','EEG 10-20 positions'};
legend_arr=legend_arr(1:num_EEG_system+1);

legend(legend_arr)
hold off
saveas(gcf,fullfile(model_folder,['headModel' subject_name '_EEG_plot.fig']));

%% save the EEG points
EEG=struct;
for i=1:length(EEGLab1)
    point_name=EEGLab1{i};
    if findstr(point_name,'(')
        point_name=strrep(point_name,'(','_');
        point_name=strtok(point_name,')');
    end
    
    EEG=setfield(EEG,point_name,EEGPts1(i,:));
end

%% calculate the intersection of the source and detectors to the head
%select FP2 AFP8 AF8 as fiducials
Fid=[EEG.Fp2; EEG.AFp8; EEG.AF8];
[EdgePts] = MeshPlaneIntersectPoints(Fid,headsurf.faces, headsurf.vertices);
figure;
patch('XData',EdgePts(:,1),'YData',EdgePts(:,2),'ZData',EdgePts(:,3),'facecolor','g');
hold on;
patch(headsurf,'facecolor','r','facealpha',0.3,'edgecolor','none')
scatter3(Fid(:,1),Fid(:,2),Fid(:,3),'filled','k');
view(3);

center=mean(EdgePts,1); % set the center of the ring as the center of the head

% [PtSort p2idx] = AddFiducials(Fid, EdgePts);
% PtSeg1 = sqrt(sum(diff(PtSort(1:p2idx,:)).^2,2));
% PtSeg2 = sqrt(sum(diff(PtSort(p2idx:end,:)).^2,2));
% PtSeg = [PtSeg1;PtSeg2];
% scatter3(PtSort(:,1),PtSort(:,2),PtSort(:,3),'filled','y')
% view(3);

save(fullfile(model_folder,['headModel' subject_name '_EEG.mat']),'EEG','headsurf','pialsurf','subject','vol','center','voxel_size','model_version','do_sinus');

disp('Done!');