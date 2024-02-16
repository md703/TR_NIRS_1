%{
Find the ANN error and the relationship with the inputs

Benjamin Kao
Last update: 2020/12/23
%}

clc;clear;close all;

%% param
input_dir_arr={'ZJ_2020-12-22-12-36-51','YH_2020-12-22-22-44-50','YF_2020-12-22-15-14-33','WW_2020-12-23-18-41-36','WH_2020-12-22-20-37-29','SJ_2020-12-22-18-48-01','SC_2020-12-23-02-22-28','KB_2020-12-23-16-36-17','BT_2020-12-23-00-35-30'};
max_sequence_length=50000;
num_SDS=7;
SDS_dist_arr=[0.8 1.5 2.12 3 3.35 4.5 4.74]; % cm
num_error_to_check=400;

fontSize=14;
marker_size=20;
line_width=2;

for sbj_i=1:length(input_dir_arr)
    input_dir=input_dir_arr{sbj_i};
    %% init
    load(fullfile(input_dir,'ANN__train_info.mat'));
    param_range=load(fullfile(input_dir,'param_range.txt'));

    true_input_arr=zeros(max_sequence_length*length(testing_input),size(testing_input{1},1));
    for i=1:length(testing_input)
        true_input_arr((i-1)*max_sequence_length+1:i*max_sequence_length,:)=testing_input{i}';
    end

    true_input_arr=normalize_param(true_input_arr,param_range,2);

    %% main
    for s=1:num_SDS
        fprintf('Analysis %s SDS %d\n',input_dir,s);
        fig=figure('Units','pixels','position',[0 0 1600 600]);
        set(fig, 'visible', 'off');
%         ti=tiledlayout('flow','TileSpacing','compact','Padding','none');
        ti=tiledlayout(1,3,'TileSpacing','compact','Padding','none');

        [SDS_error,error_index]=sort(abs(error(:,s)),'descend');
        to_check_index=error_index(1:num_error_to_check);
        to_check_error=error(to_check_index,s);
        error_input=true_input_arr(to_check_index,:);
        error_answer=testing_output(to_check_index,s); % the answer in the training data
        error_output=reflectance_arr(to_check_index,s); % the output of the ANN

        % find if the params are close to the boundary
        input_closeTo_ub=abs((error_input./param_range(1,:)-1))<0.02;
        input_closeTo_lb=abs((error_input./param_range(2,:)-1))<0.02;
        input_closeTo_boundary=sum(input_closeTo_ub+input_closeTo_lb,2);
        
        nexttile();
        plot(abs(to_check_error),input_closeTo_boundary,'.','MarkerSize',marker_size);
        xlabel('error');
        ylabel('number of parameter close to boundary');
        set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');

        % find the relationship with the original answer
        nexttile();
        plot(error_answer,error_output,'.','MarkerSize',marker_size);
        hold on;
        plot([0 max(error_answer)],[0 max(error_answer)],'LineWidth',line_width);
        xlabel('true answer');
        ylabel('ANN output');
        set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');

        % find the percentage of the true answer in the training data
        [~,all_reflectance_index]=sort(testing_output(:,s),'ascend');
        in_reflectance_percentage=[];
        for i=1:num_error_to_check
            in_reflectance_percentage(i,1)=find(all_reflectance_index==to_check_index(i));
        end
        in_reflectance_percentage=in_reflectance_percentage/size(reflectance_arr,1);
        nexttile();
        plot(in_reflectance_percentage,'.','MarkerSize',marker_size);
        xlabel('error rank');
        ylabel('true answer percentage in all training data');
        set(gca,'fontsize',fontSize, 'FontName', 'Times New Roman');

        title(ti,['SDS = ' num2str(SDS_dist_arr(s)) ' cm, largest ' num2str(num_error_to_check) ' error'],'fontsize',fontSize, 'FontName', 'Times New Roman');
        drawnow;
        print(fullfile(input_dir,['error_analysis_SDS' num2str(s) '.png']),'-dpng','-r200');
        close all;
    end
end

disp('Done!');

% normalize the parameters to [0,1]
% direction: if =1, normalize the input; if =2, denormalize the input
function output=normalize_param(input,param_range,direction)
    param_scaling=param_range(1,:)-param_range(2,:);
    if direction==1
        output=(input-param_range(2,:))./param_scaling;
    elseif direction==2
        output=input.*param_scaling+param_range(2,:);
    else
        assert(false,'Function ''normalize_spec'' param ''direction'' Error!');
    end
end