


num_SDS=5;
num_gate=10;

sbj_arr = {'KB'};
dtof_arrange=[];
for sbj = 1
    mus_table = load(fullfile(sbj_arr{sbj},'mus_table.txt'));
    
    for sim = 1:size(mus_table,1)
        %% Calculate reflectance
        load(fullfile(sbj_arr{sbj},['DTOF_' num2str(sim)]));
        temp_dtof=to_save(9:end);
        
        for s=1:num_SDS
            dtof_arrange(:,s,sim)=temp_dtof(1,1+num_gate*(s-1):num_gate*s);
        end
    end
    
    cv_value=std(dtof_arrange,[],3)./mean(dtof_arrange,3);
    
    save(fullfile('results','cv_value_1E11.mat'),'cv_value');
end