%{
Try and test the position of fiducial positions on the head MRI model
Please run 's2_segmented_to_mesh.m' before run this script

Benjamin Kao
Last update: 2020/08/15
%}
clc;clear;close all;

%% params

model_folder='model2';

subject_name='Y70_F_B131002_S034';


%% load the params
load(fullfile(model_folder,['headModel' subject_name '.mat']));
figure('Units','pixels','position',[0 0 1920 1080]);
patch(headsurf,'FaceColor',[1,.75,.65],'EdgeColor','none','FaceAlpha','0.9');
lighting gouraud
lightangle(0,30);
lightangle(120,30);
lightangle(-120,30);
% material('dull');
axis('image');
view([-135 35]);
xlabel('x');
ylabel('y');
zlabel('z');

% Nasion position (Nz): indentation at the top of the nose approximately between the eyebrows
% Inion position (Iz): indentation at the back of the head approximately where the neck begins
% (The orientation is seen from above with nose on top)
% Left preauricular position (M1): indentation in front of the top of the ear cannal, dent between the upper edge of the targus and the daith
% Right preauricular position (M2): indentation in front of the top of the ear cannal, dent between the upper edge of the targus and the daith

% for old model:
% x axis: from back to front
% y axis: from right to left
% z axis: from bottom to up

% for new model:
% x axis: from front to back
% y axis: from left to right
% z axis: from bottom to up

%% Please adjust this part manually for each subject
Nz = [54 105 42];
Iz = [239 94 17]; 
M1 = [138 24 11];
M2 = [152 178 25];

%% plot

hold on;
fiducials=[Nz;Iz;M1;M2];
plot3(fiducials(:,1),fiducials(:,2),fiducials(:,3),'ro','MarkerSize',10,'LineWidth',3);
text(Nz(1),Nz(2),Nz(3),'\leftarrow Nz','FontSize',20,'Color','b');
text(Iz(1),Iz(2),Iz(3),'\leftarrow Iz','FontSize',20,'Color','b');
text(M1(1),M1(2),M1(3),'\leftarrow M1','FontSize',20,'Color','b');
text(M2(1),M2(2),M2(3),'\leftarrow M2','FontSize',20,'Color','b');
view(3);
disp('If the poines are Okey, then continue to save the points');
keyboard();

%% If the result above is okey, then save the file

save(fullfile(model_folder,['Fiducials_' subject_name '.txt']),'fiducials','-ascii','-tabs');

disp('Done!');