%{
Plot reflectance before amd after interpolation

Ting-Yi Kuo 
Last update: 2023/10/19
%}

clc;clear;close all;

%% param
subject_name_arr={'CT'}; % the name of the subject
input_dir_arr={'CT_2024-04-20-20-50-59'}; % the lut folder of each subject
interp_dir_arr={'CT_test1_2024-04-20-21-59-26'};
compare_dir_arr={'CT_test2_2024-04-20-22-14-02'};

for sbj_i=1:length(subject_name_arr)
    
    subject_name=subject_name_arr{sbj_i};
    input_dir=input_dir_arr{sbj_i};
    interp_dir=interp_dir_arr{sbj_i};
    compare_dir=compare_dir_arr{sbj_i};
    SDS_arr=[1.5 2.2 2.9 3.6 4.3];
    
    num_SDS=5;
    num_gate=10;
    
    %% Plot the spline interpolation effect
    % lookup table value
    all_param_arr_lookup=load(fullfile(input_dir,'all_param_arr.mat'));
    all_param_arr_lookup=all_param_arr_lookup.all_param_arr;
    index=all(all_param_arr_lookup(:,1:7)==[0.5 0.35 0.042 0.5 225 200 23], 2); % set the mua,mus combination you want to plot 
    param_arr=all_param_arr_lookup(index,:);
    
    % interpolation value
    param_arr_interp=load(fullfile(interp_dir,'all_param_arr.mat'));
    param_arr_interp=param_arr_interp.all_param_arr;
    
    figure('Units','pixels','position',[0 0 1920 1080]);
    ti=tiledlayout(4,6);
    for s=2:num_SDS
        for g=1:6 %num_gate
            nexttile;
            plot(param_arr(:,8),param_arr(:,8+g+(s-1)*num_gate),'-o');
            hold on
            plot(param_arr_interp(:,8),param_arr_interp(:,8+g+(s-1)*num_gate));
            title(['SDS ' num2str(s) ' Gate ' num2str(g)]);
            xlabel('\mu_{s,GM}');
            ylabel('reflectance');
        end
    end
    title(ti,subject_name);
    print(fullfile('results_interp',['interp_b_and_a_' subject_name '.png']),'-dpng','-r200');
    
    %% Plot the comparison between interpolation value and Monte Carlo value
    mus_table=load(fullfile(subject_name,'mus_table.txt'));
    DTOF_arrange=[];
    for i=1:size(mus_table,1)
        load(fullfile(subject_name,['DTOF_' num2str(i) '.mat']));
        DTOF_arrange(end+1,:)=to_save;
    end
    index=all(DTOF_arrange(:,1:8)==[0.5 0.35 0.042 0.5 225 200 23 150],2); % set the mua,mus combination you want to plot
    temp_MC=DTOF_arrange(index,:);
    
    load(fullfile(compare_dir,'all_param_arr.mat'));
    temp_interp=all_param_arr;
    
    for s=1:num_SDS
        MC_result(:,s)=temp_MC(9+num_gate*(s-1):8+num_gate*s);
        interp_result(:,s)=temp_interp(9+num_gate*(s-1):8+num_gate*s);
    end
    
    APE=abs((interp_result-MC_result)./MC_result);
    RMSPE=sqrt(mean(((interp_result-MC_result)./MC_result).^2,1));
    RMSPE(1,5)=sqrt(mean(((interp_result(2:10,5)-MC_result(2:10,5))./MC_result(2:10,5)).^2,1));

    start_stop_index=zeros(2,num_SDS);
    RMSPE_within_boundary=[];
    for s=1:num_SDS
        dtof=MC_result(:,s);
        [max_value,index]=max(dtof);
        start_flag=0;
        end_flag=0;
        num=0;
        error=0;
        
        for g=1:num_gate
            if g<=index && ~start_flag && dtof(g)>=0.5*max_value
                start_stop_index(1,s)=g;
                start_flag=1;
            elseif g>index && ~end_flag && dtof(g)<=0.0001*max_value
                start_stop_index(2,s)=g;
                end_flag=1;
            end
            
            if (g<=index && dtof(g)>=0.5*max_value) || (g>index && dtof(g)>=0.0001*max_value)
                error=error+APE(g,s).^2;
                num=num+1;
            end
        end
        RMSPE_within_boundary(1,s)=sqrt(error./num);
    end
    
    figure('Units','pixels','position',[0 0 1920 1080]);
    ti=tiledlayout('flow','Padding','none');
    
    for s=1:num_SDS
        nexttile;
        semilogy(MC_result(:,s),'Linewidth',2);
        hold on
        semilogy(interp_result(:,s),'Linewidth',2);
        legend('MC',['interpolation, RMSPE=' num2str(RMSPE_within_boundary(1,s)*100) '%'],'Location','southoutside','Orientation','horizontal');
        xlabel('Time gate');
        ylabel('reflectance');
        yyaxis right
        plot(APE(:,s)*100,'--','HandleVisibility','off','Linewidth',2);
        ylabel('RMSPE (%)');
        
        % underground (actual fitting bound) 
        % -> if show, you should calculate the RMSPE in this boundary 
        x1=start_stop_index(1,s);
        x2=start_stop_index(2,s);
        yLimits = ylim;
        xPatch = [x1, x2, x2, x1];
        yPatch = [min(ylim), min(ylim),max(ylim), max(ylim)];
        p=patch(xPatch, yPatch, [0.69, 0.93, 0.93],'FaceAlpha',0.3,'EdgeColor','none');
        p.Annotation.LegendInformation.IconDisplayStyle = 'off';
        
        title(['SDS ' num2str(SDS_arr(s)) ' cm']);
        set(gca,'Fontsize',18,'Fontname','Times New Roman');
    end
    print(fullfile('results_interp',['compare_MC_and_interp_' subject_name '.png']),'-dpng','-r200');
end

