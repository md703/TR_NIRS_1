%{
Plot the fitting result

Ting-Yi Kuo
Last update: 2024/05/14
%}


mother_dir='20240612'; 
target_folder={'phantom_2','phantom_3','phantom_5'};
used_intensity={'10_6_530','10_6_530','10_6_530'};
fitting_folder='fittingSDS_12';

fitting_phantom=[2 3 5];

num_SDS=2;

% load OP answer
mua_ans=load(fullfile('20240502','cal_reflectance_200','mua_FDA_cm.txt'));
mus_ans=load(fullfile('20240502','cal_reflectance_200','musp_cm.txt'));
wavelength=800;

figure('Units','pixels','Position',[0,0,800,1000]);
ti=tiledlayout(length(fitting_phantom),num_SDS,'TileSpacing','compact');

for i=1:length(target_folder)
    load(fullfile(mother_dir,[target_folder{i} '_' used_intensity{i}],fitting_folder,'fitting_info.mat')); % 'target_TPSF','start_index','end_index','init_param','init_TPSF','init_error','fitted_param','fitted_TPSF','fitting_error','OP_error'
    
    for s=1:num_SDS
        nexttile;
        plot(0:0.025:0.025*(length(target_TPSF)-1),target_TPSF(:,s),'Linewidth',2)
        end_value=max(target_TPSF(:,s))*0.05;
        hold on
        plot(0:0.025:0.025*(length(init_TPSF)-1),init_TPSF(:,s),'-','Linewidth',2)
        plot(0:0.025:0.025*(length(fitted_TPSF)-1),fitted_TPSF(:,s),'Linewidth',2)
        xline(start_index(s)*0.025,'--b','LineWidth',2);
        xline(end_index(s)*0.025,'--b','LineWidth',2);
        set(gca,'Yscale','log','FontName', 'Times New Roman','Fontsize',12);
        ylim([end_value*10^(-3) 1]);
        title(['ph' num2str(fitting_phantom(i)) ', SDS ' num2str(s)]);
        xlabel('time (ns)');
        ylabel('normalized counts');
        
        legend('target',['initial DTOF=' num2str(100*init_error(s)) '%'],['fitted DTOF=' num2str(100*fitting_error(s)) '%'],'Location','southoutside','Fontsize',12);
    end
%     title(ti,['phantom ' num2str(fitting_phantom(i))]);
%     set(gca,'FontName', 'Times New Roman','Fontsize',12);
%     print(fullfile(mother_dir,['phantom' num2str(fitting_phantom(i)) '_fitted_result.png']),'-dpng','-r200');
    

    target_TPSF_arrange(:,:,i)=target_TPSF;
    start_index_arrange(:,:,i)=start_index;
    end_index_arrange(:,:,i)=end_index;
    init_param_arrange(:,:,i)=init_param;
    init_TPSF_arrange(:,:,i)=init_TPSF;
    init_error_arrange(:,:,i)=init_error;
    fitted_param_arrange(:,:,i)=fitted_param;
    fitting_error_arrange(:,:,i)=fitting_error;
    OP_error_arrange(:,:,i)=OP_error;
    mus=interp1(mus_ans(:,1),mus_ans(:,fitting_phantom(i)+1),wavelength);
    mua=interp1(mua_ans(:,1),mua_ans(:,fitting_phantom(i)+1),wavelength);
    OP_answer_arrange(:,:,i)=[mus mua];
end
print(fullfile(mother_dir,'all_fitted_result.png'),'-dpng','-r200');

% plot true OP answer and fitted param
title_name_arr={'\mu_s''','\mu_a'};
figure('Units','pixels','Position',[0,0,640,300]);
ti=tiledlayout(1,2);
for i=1:2
    nexttile;
    yyaxis right
    b=bar(squeeze(OP_answer_arrange(1,i,:)),squeeze(abs(100*OP_error_arrange(1,i,:))),'Linestyle','none','FaceAlpha',0.5);
    ylabel('OP error (%)');
    ylim([0 20]);
    yyaxis left
    plot(squeeze(OP_answer_arrange(1,i,:)),squeeze(fitted_param_arrange(1,i,:)),'o','Linewidth',2);
    hold on
    plot(squeeze(OP_answer_arrange(1,i,:)),squeeze(OP_answer_arrange(1,i,:)),'--','Linewidth',2);
    ylabel('fitted OP');
    title([title_name_arr{i}]);
    xlabel('OP fitted by CW system');
%     legend('TR','CW');
    set(gca,'FontName', 'Times New Roman','Fontsize',12);
end
print(fullfile(mother_dir,'fitted_OP_error.png'),'-dpng','-r200');

fitted_param_arrange=squeeze(fitted_param_arrange);
save(fullfile(mother_dir,'fitted_OP_phantom_2_3_5.txt'),'fitted_param_arrange','-ascii','-tabs');
    