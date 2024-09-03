%{
Plot the generated target spectrum

Benjamin Kao
Last update: 2021/01/17
%}

clc;clear;close all;

global lambda Lbound Ubound net param_range;

%% param 
subject_name_arr={'KB'}; %,'WH','ZJ'
num_anser_to_generate=1; % number of target spec (true answer)
num_error_to_generate=15; % number of adding noise to the same, the first one will have no error

num_SDS_cw=6;
num_SDS_tr=5;
num_gate=10;

SDS_dist_arr_tr=[1.5 2.2 2.9 3.6 4.3]; % cm
SDS_dist_arr_cw=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm; % cm
input_dir='test_fitting_2024-01-13-15-46-39_same_noise';

%% main
% plot each target seperately
for sbj=1:length(subject_name_arr)
    for target_i=1:num_anser_to_generate
        spec_arr=[];
        for error_i=1:num_error_to_generate
            spec_arr(:,:,error_i)=load(fullfile(input_dir,subject_name_arr{sbj},['target_' num2str(target_i) '_' num2str(error_i)],'target_spec.txt')); % CW
            dtof_arr(:,:,error_i)=load(fullfile(input_dir,subject_name_arr{sbj},['target_' num2str(target_i) '_' num2str(error_i)],'target_dtof.txt')); % TR
        end
        
        % CW
        mean_spec=mean(spec_arr,3);
        std_spec=std(spec_arr,[],3);
        cv_spec=std_spec./mean_spec;
        
        % TR
        mean_dtof=mean(dtof_arr,3);
        std_dtof=std(dtof_arr,[],3);
        cv_dtof=std_dtof./mean_dtof;        
        
        
        % CW
        fig=figure('Position',[0 0 1920 1080]);
        set(fig,'visible','off');
        ti=tiledlayout('flow','TileSpacing','compact','Padding','compact');
        for s=1:num_SDS_cw
            nexttile();
            plot(spec_arr(:,1,1),squeeze(spec_arr(:,s+1,:)),'LineWidth',2);
            title(['SDS = ' num2str(SDS_dist_arr_cw(s)) ' cm, CV=' num2str(cv_spec(1,s+1)*100,'%.2f%%')],'FontWeight','Normal');
            yylim=ylim;
            yylim(1)=0;
            ylim(yylim);
            set(gca,'fontsize',22);  %, 'FontName', 'Times New Roman'
            grid on;
        end
        title(ti,[subject_name_arr{sbj} ' target ' num2str(target_i)]);
        print(fullfile(input_dir,subject_name_arr{sbj},['target_spec_' num2str(target_i) '.png']),'-dpng','-r200');

        % TR
        fig=figure('Position',[0 0 1920 1080]);
        set(fig,'visible','off');
        ti=tiledlayout('flow','TileSpacing','compact','Padding','compact');
        for s=1:num_SDS_tr
            nexttile();
            semilogy(1:1:10,squeeze(dtof_arr(:,s,:)),'LineWidth',1);
            hold on
            
            first=0;
            first_flag=0;
            last=0;
            last_flag=0;
            dtof=dtof_arr(:,s,1);
            [max_value,index]=max(dtof);
            for g=1:num_gate
                if dtof(g)>0.5*max_value && g<=index && ~first_flag
                    first=g;
                    first_flag=1;
                elseif dtof(g)<0.0001*max_value && g>index && ~last_flag
                    last=g-1;
                    last_flag=1;
                elseif first_flag && last_flag
                    break
                end
            end
            
            x1=first;
            x2=last;
            yLimits=ylim;
            xlim([1 10])
            xPatch=[x1, x2, x2, x1];
            yPatch=[min(ylim), min(ylim),max(ylim), max(ylim)];
            p=patch(xPatch, yPatch, [0.69, 0.93, 0.93],'FaceAlpha',0.4,'EdgeColor','none');
            p.Annotation.LegendInformation.IconDisplayStyle = 'off';
            uistack(p,"bottom");
            ylim(yLimits);
            
            title(['SDS = ' num2str(SDS_dist_arr_tr(s)) ' cm'],'FontWeight','Normal');
            yyaxis right
            plot(1:1:10,cv_dtof(:,s)*100,'-o','Linewidth',2);
            ylabel('CV (%)');
            
            set(gca,'fontsize',24);  %, 'FontName', 'Times New Roman'
            grid on;
        end
        title(ti,[subject_name_arr{sbj} ' target ' num2str(target_i)],'fontsize',10);
        print(fullfile(input_dir,subject_name_arr{sbj},['target_dtof_' num2str(target_i) '.png']),'-dpng','-r200');
        close all;
    end
end

% plot one target and noise represented in shadederror bar
for sbj=1:length(subject_name_arr)
    for target_i=1:num_anser_to_generate
        spec_arr=[];
        for error_i=1:num_error_to_generate
            spec_arr(:,:,error_i)=load(fullfile(input_dir,subject_name_arr{sbj},['target_' num2str(target_i) '_' num2str(error_i)],'target_spec.txt')); % CW
            dtof_arr(:,:,error_i)=load(fullfile(input_dir,subject_name_arr{sbj},['target_' num2str(target_i) '_' num2str(error_i)],'target_dtof.txt')); % TR
        end
        
        % CW
        upper_noise_cw=spec_arr(:,2:7,1).*(1+cv_spec(:,2:7));
        lower_noise_cw=spec_arr(:,2:7,1).*(1-cv_spec(:,2:7));
        
        % TR
        upper_noise_tr=dtof_arr(:,:,1).*(1+cv_dtof);
        lower_noise_tr=dtof_arr(:,:,1).*(1-cv_dtof);       
        
        
        % CW
        fig=figure('Position',[0 0 1920 1080]);
%         set(fig,'visible','off');
        ti=tiledlayout('flow','TileSpacing','compact','Padding','compact');
        for s=1:num_SDS_cw
            nexttile();
            plot(spec_arr(:,1,1),squeeze(spec_arr(:,s+1,1)),'LineWidth',2,'Color',[0 0.4470 0.7410]); %[0 0 0.6]
            hold on
            p=patch([spec_arr(:,1,1); flip(spec_arr(:,1,1))], [upper_noise_cw(:,s); flip(lower_noise_cw(:,s))], [0.4660 0.6740 0.1880], 'EdgeColor','none');
            uistack(p,"bottom");
            alpha(0.5)
%             shadedErrorBar(spec_arr(:,1,1),log(squeeze(spec_arr(:,s+1,1))),cv_spec(:,s+1),'lineprops',{'LineWidth',2},'patchSaturation',0.1);  %'-b'
            
            title(['SDS = ' num2str(SDS_dist_arr_cw(s)) ' cm'],'FontWeight','Normal');
            xlabel('wavelength')
%             yylim=ylim;
%             yylim(1)=0;
%             ylim(yylim);
            set(gca,'fontsize',22);  %, 'FontName', 'Times New Roman'
            grid on;
        end
        title(ti,[subject_name_arr{sbj} ' target ' num2str(target_i)]);
        print(fullfile(input_dir,subject_name_arr{sbj},['target_spec_' num2str(target_i) '.png']),'-dpng','-r200');

        % TR
        fig=figure('Position',[0 0 1920 1080]);
%         set(fig,'visible','off');
        ti=tiledlayout('flow','TileSpacing','compact','Padding','compact');
        for s=1:num_SDS_tr
            nexttile();
            plot(1:1:10,log(squeeze(dtof_arr(:,s,1))),'LineWidth',2);
            hold on
            p=patch([[1:1:10]'; flip([1:1:10]')], [log(upper_noise_tr(:,s)); flip(log(lower_noise_tr(:,s)))], [0.4660 0.6740 0.1880], 'EdgeColor','none');
            alpha(0.5)
            title(['SDS = ' num2str(SDS_dist_arr_tr(s)) ' cm'],'FontWeight','Normal');
            xlabel('Time gate')
            ylabel('(log scale)')
            set(gca,'fontsize',22);  %, 'FontName', 'Times New Roman'
            grid on;
        end
        title(ti,[subject_name_arr{sbj} ' target ' num2str(target_i)],'fontsize',10);
        print(fullfile(input_dir,subject_name_arr{sbj},['target_dtof_' num2str(target_i) '.png']),'-dpng','-r200');
%         close all;
    end
end

disp('Done!');