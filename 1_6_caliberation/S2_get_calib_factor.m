%{
Use the simulation value and the measured spectrum to calculate calibration factor
There are 2 mode of the calibrations:
1. all phantom calibration: use all phantoms to find the calibration equation
2. closest phantom calibraton: use some phantoms closest to the target reflectance to find the calibration equation

Benjamin Kao
Last update: 2020/12/08
%}


clc; clear; close all;

%% param
folder_arr={'20201206_test_13'}; % the folder of the experiment
phantom_name_arr={'p1','p2','p3','p4','p5','p6'}; % in the same order as the phantom 1,2...n

num_SDS=6;
calib_wl=[650 1000]; % the calibration wavlength interval

figure_monitoring=1; % =1 to plot the figure of phantom measured value and simulated value, to help understand the goodness of the calibration
monitoring_interval=30; % the wavelength interval of the figure monitoring

calib_mode=1; % 1=MCML, 2=MCX

output_folder_arr={'calibration_MCML','calibration_MCX'};
calib_mode_arr={'MCML','MCX'};
simulate_folder_arr={'phantom_simulation_MCML_FDA_7EK','phantom_simulation_MCX'}; % the folders contain the siulation spectrum of the phantoms
sim_prefix_arr={'phantom_','effective_reflectance_ph_'}; % the file name prefix of the simulated spectrum file in the folder
sim_postfix_arr={'_spec',''}; % the file name postfix of the simulated spectrum file in the folder
sim_ph_index=[1 2 3 4 5 6]; % the index of the simulated phantom corresponding to the measured phantom
sim_SDS_index=[1 2 3 4 5 6]; % the SDS in the simulated spectrum correspond to the measured spectrum
num_phantom_in_interval=3; % for the closest phantom calibration, how many phantoms to consider in one reflectance interval

%% init
num_phantom=length(phantom_name_arr);
assert(length(sim_ph_index)==num_phantom,'Error: the number fo measured phantom is not match to ''sim_ph_index''!');
legend_arr={};
for j=1:num_phantom
    legend_arr{end+1}=['phantom ' phantom_name_arr{j}];
end
for j=1:num_phantom
    legend_arr{end+1}=['leave ' num2str(j) 'out'];
end
legend_arr{end+1}='all phantoms';
colormap_arr=parula(num_phantom+1);

%% main
for fi=1:length(folder_arr)
    
    %% for flat phantom
    simulate_folder=simulate_folder_arr{calib_mode};
    
    output_folder=fullfile(folder_arr{fi},output_folder_arr{calib_mode});
    
    figure_folder=fullfile(output_folder,'figure');
    
    measure_folder=fullfile(folder_arr{fi},'extracted_spec');
    
    %% init
    mkdir(output_folder);
    if figure_monitoring
        mkdir(figure_folder);
    end
    
    %% load
    measure_spec={};
    simulate_spec={};
    for i=1:num_phantom
        measure_spec{1,i}=load(fullfile(measure_folder,['phantom_' phantom_name_arr{i} '.txt']));
        simulate_spec{1,i}=load(fullfile(simulate_folder,[sim_prefix_arr{calib_mode} num2str(sim_ph_index(i)) sim_postfix_arr{calib_mode} '.txt']));
        if i==1
            sim_wl=simulate_spec{1}(:,1);
        end
        simulate_spec{1,i}=simulate_spec{1,i}(:,sim_SDS_index+1); % first column is the wavelength
    end
    
    fprintf('Load spectrum done.\n');
    
    %% check calibration wavelenght
    wl_change_flag=0;
    for i=1:num_phantom
        if max(measure_spec{i}(:,1))<calib_wl(2)
            calib_wl(2)=max(measure_spec{i}(:,1));
            wl_change_flag=1;
        end
        if min(measure_spec{i}(:,1))>calib_wl(1)
            calib_wl(1)=min(measure_spec{i}(:,1));
            wl_change_flag=1;
        end
    end
    if max(sim_wl)<calib_wl(2)
        calib_wl(2)=max(sim_wl);
        wl_change_flag=1;
    end
    if min(sim_wl)>calib_wl(1)
        calib_wl(1)=min(sim_wl);
        wl_change_flag=1;
    end
    
    if wl_change_flag
        fprintf('Calibration wavelength changed to %d ~ %d.\n',calib_wl(1),calib_wl(2));
    end
    
    clear wl_change_flag;
    
    wl_interval=(calib_wl(1):calib_wl(2))';
    
    %% interp the spec
    for i=1:num_phantom
        measure_spec{i}=interp1(measure_spec{i}(:,1),measure_spec{i},wl_interval);
        simulate_spec{i}=interp1(sim_wl,[sim_wl simulate_spec{i}],wl_interval,'pchip');
    end
    
    fprintf('Spectrum interpolation done.\n');
    
    %% start calibration
    % for all phantom calibration
    A_arr=zeros(length(wl_interval),num_SDS,num_phantom+1); % the calibration factor of y=Ax+B
    B_arr=zeros(length(wl_interval),num_SDS,num_phantom+1); % the calibration factor of y=Ax+B
    RR_arr=zeros(length(wl_interval),num_SDS,num_phantom+1); % the r^2 value
    pred_RMSPE_arr=zeros(length(wl_interval),num_SDS,num_phantom+1); % the RMSE between calibrated spectrum and simulated spectrum of perdicted phantom (the calibrated one)
    all_RMSPE_arr=zeros(length(wl_interval),num_SDS,num_phantom+1); % the RMSE between calibrated spectrum and simulated spectrum of all phantom
    
    % for closest phantom calibrations
    closest_A_arr=zeros(length(wl_interval),num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_B_arr=zeros(length(wl_interval),num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_RR_arr=zeros(length(wl_interval),num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_all_RMSPE_arr=zeros(length(wl_interval),num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_interval_boundary=zeros(length(wl_interval),num_SDS,num_phantom-num_phantom_in_interval); % the boundary between each reflectane interval
    
    
    for wl=1:length(wl_interval)
        fprintf('calibrate  %d nm\n',wl_interval(wl));
        
        if figure_monitoring && rem(wl,monitoring_interval)==1
            figure('Units','pixels','position',[0 0 1600 900]);
            ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
        end
        
        for s=1:num_SDS
            %% make the x and y array
            x_arr=zeros(1,num_phantom);
            y_arr=zeros(1,num_phantom);
            for i=1:num_phantom
                x_arr(i)=measure_spec{i}(wl,s+1);
                y_arr(i)=simulate_spec{i}(wl,s+1);
            end
            
            pred_y_arr=cell(1,num_phantom+1);
            
            %% all phantom calibration, calibration for leave one out or all
            for j=1:(num_phantom+1)
                xx_arr=x_arr([1:(j-1) (j+1):end]);
                yy_arr=y_arr([1:(j-1) (j+1):end]);
                CF=polyfit(xx_arr,yy_arr,1);
                A_arr(wl,s,j)=CF(1);
                B_arr(wl,s,j)=CF(2);
                pred_y=CF(1)*x_arr+CF(2);
                pred_y_arr{j}=pred_y;
                
                if figure_monitoring && j==num_phantom+1 && rem(wl,monitoring_interval)==1
                    nexttile;
                    hold on;
                    for jj=1:num_phantom
                        plot(x_arr(jj),y_arr(jj),'o','Color',colormap_arr(jj,:),'MarkerSize',12,'LineWidth',2);
                    end
                    for jj=1:num_phantom
                        plot(x_arr,pred_y_arr{jj},'--','Color',colormap_arr(jj,:),'LineWidth',2);
                    end
                    plot(x_arr,pred_y_arr{num_phantom+1},'-','Color',colormap_arr(end,:),'LineWidth',2);
                    title(['SDS ' num2str(s)]);
                    lgd=legend(legend_arr,'Location','northwest');
                    lgd.NumColumns=2;
                    grid on;
                    xlabel('measured reflectance');
                    ylabel('simulated reflectance');
                    set(gca,'fontsize',12, 'FontName', 'Times New Roman');
                end
                
                error_y=pred_y-y_arr;
                RR_arr(wl,s,j)=1-(sum(error_y.^2)/sum((y_arr-mean(y_arr)).^2));
                all_RMSPE_arr(wl,s,j)=sqrt(mean((error_y./y_arr).^2));
                if j<=num_phantom
                    pred_RMSPE_arr(wl,s,j)=abs(error_y(j)./y_arr(j));
                else
                    pred_RMSPE_arr(wl,s,j)=all_RMSPE_arr(wl,s,j);
                end
            end
            
            %% closest phantom calibration
            [sorted_x_arr,mea_spec_index]=sort(x_arr,'ascend');
            for r_i=1:num_phantom-num_phantom_in_interval+1 % reflectance interval
                interval_x_arr=x_arr(mea_spec_index(r_i:r_i+num_phantom_in_interval-1));
                interval_y_arr=y_arr(mea_spec_index(r_i:r_i+num_phantom_in_interval-1));
                CF=polyfit(interval_x_arr,interval_y_arr,1);
                closest_A_arr(wl,s,r_i)=CF(1);
                closest_B_arr(wl,s,r_i)=CF(2);
                pred_y=CF(1)*interval_x_arr+CF(2);
                error_y=pred_y-interval_y_arr;
                closest_RR_arr(wl,s,r_i)=1-(sum(error_y.^2)/sum((interval_y_arr-mean(interval_y_arr)).^2));
                closest_all_RMSPE_arr(wl,s,r_i)=sqrt(mean((error_y./interval_y_arr).^2));
                if r_i<num_phantom-num_phantom_in_interval+1
                    closest_interval_boundary(wl,s,r_i)=mean(sorted_x_arr([r_i,r_i+num_phantom_in_interval]));
                end
            end
        end
        if figure_monitoring && rem(wl,monitoring_interval)==1
            title(ti,[calib_mode_arr{calib_mode} 'calibration, wl ' num2str(wl_interval(wl)) ' nm'],'FontName', 'Times New Roman');
            print(fullfile(figure_folder,['wl_' num2str(wl) '.png']),'-dpng','-r200');
            close(gcf);
        end
    end
    
    save(fullfile(output_folder,'calib_factors.mat'),'A_arr','B_arr','RR_arr','pred_RMSPE_arr','all_RMSPE_arr','wl_interval');
    save(fullfile(output_folder,'closest_calib_factors.mat'),'closest_A_arr','closest_B_arr','closest_RR_arr','closest_all_RMSPE_arr','closest_interval_boundary','wl_interval');
end
disp('Done!');