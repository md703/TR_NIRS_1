%{
Use the calib factor to calib the phantoms

Benjamin Kao
Last update: 2021/01/17
%}

clc;clear;close all;

%% param
folder_arr={'20201209_test_14'};

target_name_arr={'tc_1','tc_2','tc_3','tc_4','tc_5','tc_6','tc_7','tc_8','tc_9','tc_10'}; % 14
num_SDS=6;

calib_dir='calibration_MCML_2';

lineWidth=2;
fontSize=18;
lgdFontSize=12;
lgdNumCol=6;

%% init
spec_arr={};
closest_spec_arr={};

%% main

for fi=1:length(folder_arr)
    fprintf('Processing folder: %s\n',folder_arr{fi});
    calib_factor=load(fullfile(folder_arr{fi},calib_dir,'calib_factors.mat'));
    closest_calib_factor=load(fullfile(folder_arr{fi},calib_dir,'closest_calib_factors.mat'));
    wl_interval=calib_factor.wl_interval;
    A_arr=calib_factor.A_arr;
    B_arr=calib_factor.B_arr;
    closest_A_arr=closest_calib_factor.closest_A_arr;
    closest_B_arr=closest_calib_factor.closest_B_arr;
    closest_interval_boundary=closest_calib_factor.closest_interval_boundary;
    closest_interval_Uboundary=closest_interval_boundary;
    closest_interval_Uboundary(:,:,end+1)=inf;
    closest_interval_Lboundary=closest_interval_boundary;
    closest_interval_Lboundary(:,:,2:end+1)=closest_interval_Lboundary;
    closest_interval_Lboundary(:,:,1)=-inf;
    for i=1:length(target_name_arr)
        fprintf('\t%s\n',target_name_arr{i});
        to_calib_spec=load(fullfile(folder_arr{fi},'extracted_spec',[target_name_arr{i} '.txt']));
        % interp
        to_calib_spec=interp1(to_calib_spec(:,1),to_calib_spec(:,2:end),wl_interval,'pchip');
        
        %% do all phantom calibration
        calib_spec=zeros(length(wl_interval),num_SDS+1);
        calib_spec(:,1)=wl_interval;
        for s=1:num_SDS
            calib_spec(:,s+1)=to_calib_spec(:,s).*A_arr(:,s,end)+B_arr(:,s,end);
        end
        calib_spec(calib_spec<0)=0;
        % save
        save(fullfile(folder_arr{fi},calib_dir,[target_name_arr{i} '.txt']),'calib_spec','-ascii','-tabs');
        
        %% do closest phantom calibration
        closest_calib_spec=zeros(length(wl_interval),num_SDS+1);
        closest_calib_spec(:,1)=wl_interval;
        closest_used_interval=zeros(length(wl_interval),num_SDS+1);
        closest_used_interval(:,1)=wl_interval;
        
        closest_interval_index=(closest_interval_Uboundary-to_calib_spec)>=0 & (closest_interval_Lboundary-to_calib_spec)<0;
        for wl=1:length(wl_interval)
            for s=1:num_SDS
                temp_interval_index=find(closest_interval_index(wl,s,:));
                closest_used_interval(wl,s+1)=temp_interval_index;
                closest_calib_spec(wl,s+1)=to_calib_spec(wl,s).*closest_A_arr(wl,s,temp_interval_index)+closest_B_arr(wl,s,temp_interval_index);
            end
        end
        calib_spec(calib_spec<0)=0;
        % save
        save(fullfile(folder_arr{fi},calib_dir,[target_name_arr{i} '_closest.txt']),'closest_calib_spec','-ascii','-tabs');
        save(fullfile(folder_arr{fi},calib_dir,[target_name_arr{i} '_closest_use_interval.txt']),'closest_used_interval','-ascii','-tabs');
        
        %% save for plot
        spec_arr{i}=calib_spec;
        closest_spec_arr{i}=closest_calib_spec;
    end
end

disp('Calibration done, now plot the spectrum.');

%% plot

legend_arr={};
for i=1:length(target_name_arr)
    legend_arr{end+1}=target_name_arr{i};
    legend_arr{end+1}=[target_name_arr{i} ' closest'];
end

colormap_arr=jet(length(target_name_arr));

%% main
for fi=1:length(folder_arr)
    fig=figure('Units','pixels','position',[0 0 1920 640*ceil(num_SDS/2)]);
    set(fig, 'visible', 'off');
    ti=tiledlayout(ceil(num_SDS/2),2,'TileSpacing','compact','Padding','none');
    for s=1:num_SDS
        nexttile();
        hold on;
        for i=1:length(target_name_arr)
            plot(spec_arr{i}(:,1),spec_arr{i}(:,s+1),'Color',colormap_arr(i,:),'LineWidth',lineWidth);
            plot(closest_spec_arr{i}(:,1),closest_spec_arr{i}(:,s+1),'--','Color',colormap_arr(i,:),'LineWidth',lineWidth);
        end
        title(['SDS ' num2str(s)]);
        grid on;
        xlabel('wavelength');
        ylabel('calibrated spectrum');
        set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
        lgd.NumColumns=lgdNumCol;
    end
    print(fullfile(folder_arr{fi},calib_dir,'calib_result.png'),'-dpng','-r200');
    close all;
end

disp('Done!');