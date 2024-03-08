%{
Load the measured image, calculate the mean and CV, and turn into spectrum txt file

Benjamin Kao
Last update: 2020/12/08
%}

clc;clear;close all;

%% param
input_dir='20201209_test_14'; % the folder of the experiment
output_folder='extracted_spec'; % the folder of the extracted spectrum
target_name_arr={'p1_1','p1_2','p1_3','p1_4','p1_5','p1_6','p1_7','p1_8','p2_1','p2_2','p3_1','p3_2','p4_1','p4_2','p5_1','p5_2','p6_1','p6_2','p6_3','tc_1','tc_2','tc_3','tc_4','tc_5','tc_6','tc_7','tc_8','tc_9','tc_10'};
BG_name='bg';
target_name_prefix='SDS_spec_arr_'; % the filename before the phantom name, notice that there sourld be a [target_name_prefix 'BG'] in the input_dir
num_of_phantoms=19; % the former n targets are phantoms

% about camera
wavelength_boundary=[536.0026 1094.5]; % the min and max wavelength of the camera
to_output_wl=[650 1070]; % the wavelength range to output spectrum, calculate CV or plot the figure
camera_x_pixel=160;

picture_mode=2; % =1 for image mode, input the .tif file; =2 for random-track mode, input the .mat file
num_SDS=6; % number of SDS
SDS_dist_arr=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm

% param for image mode
num_shot=5; % number of serial picture take for one target
SDS_y_pos{1}=122:147; % the y-pixel location of the SDS
SDS_y_pos{2}=64:83;

% other setting
do_plot_pic=1; % if =1, plot the spectrum of each target
CV_maxVal=10; % in %, the max CV to show, if the CV is larger than this value, the larger part will be shrink
do_output_CV=1; % if =1, save the CV of the spectrum into txt file
do_plot_together=1; % if =1, plot the spectrum of the target together

lineWidth=2;
fontSize=18;
lgdFontSize=12;
lgdNumCol=6;

%% init
wavelength=interp1([1 camera_x_pixel],wavelength_boundary,1:camera_x_pixel)';
mkdir(fullfile(input_dir,output_folder));

assert(to_output_wl(1)>=wavelength_boundary(1),'to_output_wl larger than camera wavelength boundary');
assert(to_output_wl(2)<=wavelength_boundary(2),'to_output_wl smaller than camera wavelength boundary');
to_output_wl=(ceil(to_output_wl(1):floor(to_output_wl(2))))';
if picture_mode==1
    assert(length(SDS_y_pos)==num_SDS,'number of SDS_y_pos not match with num_SDS');
end

to_process_name_arr={};
for i=1:length(target_name_arr)
    to_process_name_arr{end+1}=[target_name_prefix target_name_arr{i}];
end

all_spec_arr={};
for i=1:length(target_name_arr)
    all_spec_arr{i}=[];
end

%% load BG
BG_image=[];
if picture_mode==1
    for i=1:num_shot
        temp_image=imread(fullfile(input_dir,'measurement',['BG_X' num2str(i) '.tif']));
        if i==1
            BG_image=double(temp_image);
        else
            BG_image=BG_image+double(temp_image);
        end
    end
    BG_image=BG_image./num_shot;
else
    BG_image=load(fullfile(input_dir,['merged_' BG_name '.txt']));
end

%% for spectrum
for i=1:length(to_process_name_arr)
    fprintf('Processing target %s\n',target_name_arr{i});
    temp_spec_arr={};
    if picture_mode==1
        for j=1:num_shot
            temp_image=double(imread(fullfile(input_dir,'measurement',[to_process_name_arr{i} '_X' num2str(j) '.tif'])));
            temp_image=temp_image-BG_image;
            for s=1:num_SDS
                temp_spec_arr{s}(j,:)=sum(temp_image(SDS_y_pos{s},:));
            end
        end
    else
        temp_image=load(fullfile(input_dir,[to_process_name_arr{i} '.mat']));
        for s=1:length(temp_image.SDS_spec_arr) % SDS
            temp_spec_arr{s}=medfilt1(transpose(double(temp_image.SDS_spec_arr{s})-BG_image(:,s)),3,[],2); % use medium filter to smooth the spectrum
        end
    end
    
    mean_spec=[];
    CV_spec=[];
    for s=1:num_SDS
        mean_spec(s,:)=mean(temp_spec_arr{s},1);
        CV_spec(s,:)=abs(std(temp_spec_arr{s})./mean_spec(s,:));
    end
    mean_spec=mean_spec';
    CV_spec=CV_spec';
    
    all_spec_arr{i}=interp1(wavelength,mean_spec,to_output_wl);
    CV_spec=interp1(wavelength,CV_spec,to_output_wl);
    to_save=[to_output_wl all_spec_arr{i}];
    save(fullfile(input_dir,output_folder,[target_name_arr{i} '.txt']),'to_save','-ascii','-tabs');
    
    if do_output_CV
        to_save=[to_output_wl CV_spec];
        save(fullfile(input_dir,output_folder,[target_name_arr{i} '_CV.txt']),'to_save','-ascii','-tabs');
    end
        
    if do_plot_pic
        fig=figure('Units','pixels','position',[0 0 1920 1080]);
        set(fig, 'visible', 'off');
        ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
        for s=1:size(all_spec_arr{i},2)
            nexttile(s);
            plot(wavelength,transpose(temp_spec_arr{s}),'LineWidth',lineWidth);
            ylabel('Reflectance');
            grid on;
            yyaxis right
            plot(to_output_wl,CV_spec(:,s)*100,'--','LineWidth',lineWidth);
            ylabel('CV (%)');
            yylim=ylim;
            if yylim(2)>CV_maxVal
                yylim(2)=CV_maxVal;
            end
            ylim(yylim);
            title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm']);
            set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
            legend_arr={};
            for jj=1:size(temp_spec_arr{s},1)
                legend_arr{end+1}=num2str(jj);
            end
            legend_arr{end+1}='CV';
            lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
            lgd.NumColumns = lgdNumCol;
        end
        title(ti,strrep(target_name_arr{i},'_','\_'));
        print(fullfile(input_dir,output_folder,[target_name_arr{i} '.png']),'-dpng','-r200');
        close all;
    end
end

if do_plot_together
    fprintf('Plot the targets together.\n');
    fig=figure('Units','pixels','position',[0 0 1920 540*size(all_spec_arr{1},2)]);
    set(fig, 'visible', 'off');
    ti=tiledlayout(size(all_spec_arr{1},2),2,'TileSpacing','compact','Padding','none');
    colormap_arr=jet(length(target_name_arr));
    for s=1:size(all_spec_arr{1},2)
        nexttile;
        hold on;
        for i=1:length(target_name_arr)
            if i<=num_of_phantoms
                plot(to_output_wl,all_spec_arr{i}(:,s),'--','Color',colormap_arr(i,:));
            else
                plot(to_output_wl,all_spec_arr{i}(:,s),'Color',colormap_arr(i,:));
            end
        end
        hold off;
        legend(target_name_arr,'Location','best');
        title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm']);
        grid on;
        nexttile;
        hold on;
        for i=1:length(target_name_arr)
            if i<=num_of_phantoms
                plot(to_output_wl,all_spec_arr{i}(:,s),'--','Color',colormap_arr(i,:));
            else
                plot(to_output_wl,all_spec_arr{i}(:,s),'Color',colormap_arr(i,:));
            end
        end
        hold off;
        legend(target_name_arr,'Location','best');
        title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm log sacle']);
        grid on;
        set(gca, 'YScale', 'log');
    end
    saveas(gcf,fullfile(input_dir,output_folder,'compare.png'));
    close all;
end

disp('Done!');