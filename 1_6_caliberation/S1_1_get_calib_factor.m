%{
Use the simulation value and the measured spectrum to calculate calibration factor
There are 2 mode of the linear calibrations:
1. all phantom calibration: use all phantoms to find the calibration equation
2. closest phantom calibraton: use some phantoms closest to the target reflectance to find the calibration equation

Benjamin Kao
Edited: Ting-Yi Kuo
Last update: 2024/03/12
%}

clc; clear; close all;

%% param
folder_arr={'20201209_test_14'}; % the folder of the experiment
phantom_name_arr={'p1','p2'}; % in the same order as the phantom 1,2...n

num_SDS=5;
num_gate=10;
SDS_dist_arr=[1.5 2.2 2.9 3.6 4.3]; % cm

calib_mode=1; % 1=MCML, 2=MCX

output_folder_arr={'calibration_MCML_2','calibration_MCX'};
calib_mode_arr={'MCML','MCX'};
simulate_folder_arr={'phantom_simulation_MCML_FDA_7EK_2_dilated','phantom_simulation_MCX'}; % the folders contain the siulation spectrum of the phantoms
sim_prefix_arr={'phantom_','effective_reflectance_ph_'}; % the file name prefix of the simulated spectrum file in the folder
sim_postfix_arr={'_TPSF',''}; % the file name postfix of the simulated spectrum file in the folder
sim_ph_index=[1 2]; % the index of the simulated phantom corresponding to the measured phantom
sim_SDS_index=[1 2 3 4 5]; % the SDS in the simulated spectrum correspond to the measured spectrum
num_phantom_in_interval=3; % for the closest phantom calibration, how many phantoms to consider in one reflectance interval


% about plot
figure_monitoring=1; % =1 to plot the figure of phantom measured value and simulated value, to help understand the goodness of the calibration
monitoring_interval=30; % the wavelength interval of the figure monitoring

lineWidth=2;
fontSize=14;
lgdFontSize=12;
lgdNumCol=7;

subplot_height=300; % pixel, the height of subplot
subplot_width=450; % pixel, the width of subplot
left_spacing=80; % pixel, the space between subplot and the left things
right_spacing=50; % pixel, the space right of the last column of subplot
upper_spacing=90; % pixel, the space between subplot and the upper things
lower_spacing=30; % pixel, the space below the legend box
legend_height=70; % pixel, the height of legend box

plot_n_col=3; % the column number of subplot
plot_n_row=2; % the row number of subplot


%% init
num_phantom=length(phantom_name_arr);
assert(length(sim_ph_index)==num_phantom,'Error: the number fo measured phantom is not match to ''sim_ph_index''!');
legend_arr={};
for j=1:num_phantom
    legend_arr{end+1}=['phantom ' phantom_name_arr{j}];
end
for j=1:num_phantom
    legend_arr{end+1}=['leave ' phantom_name_arr{j} ' out'];
end
legend_arr{end+1}='all phantoms';
colormap_arr=parula(num_phantom+1);


%% main
for fi=1:length(folder_arr)
    
    %% for flat phantom
    load(fullfile(folder_arr{fi},'phantom_TPSF_processed.mat'));    % load measured data
    
    simulate_folder=simulate_folder_arr{calib_mode};        % load phantom simulation data
    
    output_folder=fullfile(folder_arr{fi},output_folder_arr{calib_mode});
    
    figure_folder=fullfile(output_folder,'figure');
    
    %% init
    mkdir(output_folder);
    if figure_monitoring
        mkdir(figure_folder);
    end
    
    %% load
    measure_TPSF=target_mean;
    simulate_TPSF={};
    for i=1:num_phantom
        simulate_TPSF{1,i}=load(fullfile(simulate_folder,[sim_prefix_arr{calib_mode} num2str(sim_ph_index(i)) sim_postfix_arr{calib_mode} '.txt']));
        simulate_TPSF{1,i}=simulate_TPSF{1,i}(:,sim_SDS_index);
    end
    
    fprintf('Load TPSF done.\n');
    
    
    %% start calibration
    % for all phantom calibration
    A_arr=zeros(num_gate,num_SDS,num_phantom+1); % the calibration factor of y=Ax+B
    B_arr=zeros(num_gate,num_SDS,num_phantom+1); % the calibration factor of y=Ax+B
    RR_arr=zeros(num_gate,num_SDS,num_phantom+1); % the r^2 value
    pred_RMSPE_arr=zeros(num_gate,num_SDS,num_phantom+1); % the RMSE between calibrated spectrum and simulated spectrum of perdicted phantom (the calibrated one)
    all_RMSPE_arr=zeros(num_gate,num_SDS,num_phantom+1); % the RMSE between calibrated spectrum and simulated spectrum of all phantom
    
    % for closest phantom calibrations
    closest_A_arr=zeros(num_gate,num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_B_arr=zeros(num_gate,num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_RR_arr=zeros(num_gate,num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_all_RMSPE_arr=zeros(num_gate,num_SDS,num_phantom-num_phantom_in_interval+1);
    closest_interval_boundary=zeros(num_gate,num_SDS,num_phantom-num_phantom_in_interval); % the boundary between each reflectane interval

    for g=1:num_gate
        fprintf('calibrate  %d nm\n',wl_interval(g));
        
        if figure_monitoring && rem(g,monitoring_interval)==1
            fig=figure('Units','pixels','position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
            set(fig, 'visible', 'off');
        end
        
        for s=1:num_SDS
            %% make the x and y array
            x_arr=zeros(1,num_phantom);
            y_arr=zeros(1,num_phantom);
            for i=1:num_phantom
                x_arr(i)=measure_spec{i}(g,s+1);
                y_arr(i)=simulate_spec{i}(g,s+1);
            end
            
            pred_y_arr=cell(1,num_phantom+1);
            
            %% all phantom calibration, calibration for leave one out or all
            for j=1:(num_phantom+1)
                xx_arr=x_arr([1:(j-1) (j+1):end]);
                yy_arr=y_arr([1:(j-1) (j+1):end]);
                CF=polyfit(xx_arr,yy_arr,1);
                A_arr(g,s,j)=CF(1);
                B_arr(g,s,j)=CF(2);
                pred_y=CF(1)*x_arr+CF(2);
                pred_y_arr{j}=pred_y;
                
                error_y=pred_y-y_arr;
                RR_arr(g,s,j)=1-(sum(error_y.^2)/sum((y_arr-mean(y_arr)).^2));
                all_RMSPE_arr(g,s,j)=sqrt(mean((error_y./y_arr).^2));
                if j<=num_phantom
                    pred_RMSPE_arr(g,s,j)=abs(error_y(j)./y_arr(j));
                else
                    pred_RMSPE_arr(g,s,j)=all_RMSPE_arr(g,s,j);
                end
                
                % plot
                if figure_monitoring && j==num_phantom+1 && rem(g,monitoring_interval)==1
                    row_index=ceil(s/plot_n_col);
                    col_index=s-(row_index-1)*plot_n_col;
                    axes;
                    hold on;
                    for jj=1:num_phantom
                        plot(x_arr(jj),y_arr(jj),'o','Color',colormap_arr(jj,:),'MarkerSize',12,'LineWidth',lineWidth);
                    end
                    for jj=1:num_phantom
                        plot(x_arr,pred_y_arr{jj},'--','Color',colormap_arr(jj,:),'LineWidth',lineWidth);
                    end
                    plot(x_arr,pred_y_arr{num_phantom+1},'-','Color',colormap_arr(end,:),'LineWidth',lineWidth);
                    x_range=xlim();
                    mid_x_point=mean(x_range);
                    text(mid_x_point,interp1(x_arr,pred_y_arr{num_phantom+1},mid_x_point)*0.9,{['y = ' num2str(A_arr(g,s,j),'%.2e') ' \times x + ' num2str(B_arr(g,s,j),'%.2e')],['r^2 = ' num2str(RR_arr(g,s,j),'%.4f')]},'HorizontalAlignment','left','VerticalAlignment','top','fontsize',fontSize, 'FontName', 'Times New Roman');
                    title(['SDS = ' num2str(SDS_dist_arr(s)) ' cm']);
                    grid on;
                    xlabel('measured counts');
                    ylabel('simulated counts');
                    set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');
                    set(gca,'Unit','pixels','Position',[left_spacing+(left_spacing+subplot_width)*(col_index-1) lower_spacing+legend_height+upper_spacing+(subplot_height+upper_spacing)*(plot_n_row-row_index) subplot_width subplot_height]);
                    if s==num_SDS
                        lgd=legend(legend_arr,'Location','southoutside','fontsize',lgdFontSize);
                        lgd.NumColumns=lgdNumCol;
                        set(lgd,'Unit','pixels','position',[left_spacing lower_spacing plot_n_col*subplot_width+(plot_n_col-1)*left_spacing legend_height]);
                    end
                end
                
            end
            
            %% closest phantom calibration
            [sorted_x_arr,mea_spec_index]=sort(x_arr,'ascend');
            for r_i=1:num_phantom-num_phantom_in_interval+1 % reflectance interval
                interval_x_arr=x_arr(mea_spec_index(r_i:r_i+num_phantom_in_interval-1));
                interval_y_arr=y_arr(mea_spec_index(r_i:r_i+num_phantom_in_interval-1));
                CF=polyfit(interval_x_arr,interval_y_arr,1);
                closest_A_arr(g,s,r_i)=CF(1);
                closest_B_arr(g,s,r_i)=CF(2);
                pred_y=CF(1)*interval_x_arr+CF(2);
                error_y=pred_y-interval_y_arr;
                closest_RR_arr(g,s,r_i)=1-(sum(error_y.^2)/sum((interval_y_arr-mean(interval_y_arr)).^2));
                closest_all_RMSPE_arr(g,s,r_i)=sqrt(mean((error_y./interval_y_arr).^2));
                if r_i<num_phantom-num_phantom_in_interval+1
                    closest_interval_boundary(g,s,r_i)=mean(sorted_x_arr([r_i,r_i+num_phantom_in_interval]));
                end
            end
        end
        if figure_monitoring && rem(g,monitoring_interval)==1
            axes;
            axis off;
            set(gca,'Unit','pixels','Position',[0 0 (left_spacing+subplot_width)*plot_n_col+right_spacing (upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing+lower_spacing]);
            text(((left_spacing+subplot_width)*plot_n_col+right_spacing)/2,(upper_spacing+subplot_height)*plot_n_row+legend_height+upper_spacing/2+lower_spacing,[calib_mode_arr{calib_mode} ' calibration, gate ' num2str(wl_interval(g)) ' nm'],'Unit','pixels','HorizontalAlignment','center','VerticalAlignment','middle','fontsize',fontSize,'FontName', 'Times New Roman')

            print(fullfile(figure_folder,['Gate_' num2str(g) '.png']),'-dpng','-r200');
            close(gcf);
        end
    end
    
    save(fullfile(output_folder,'calib_factors.mat'),'A_arr','B_arr','RR_arr','pred_RMSPE_arr','all_RMSPE_arr');
    save(fullfile(output_folder,'closest_calib_factors.mat'),'closest_A_arr','closest_B_arr','closest_RR_arr','closest_all_RMSPE_arr','closest_interval_boundary');
end
disp('Done!');

