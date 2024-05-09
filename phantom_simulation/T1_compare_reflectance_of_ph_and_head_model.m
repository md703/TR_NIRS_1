

% head
sum_head=zeros(1,5);

for i=1:5
    for j=1:10
        sum_head(i)=sum_head(i)+length(SDS_detpt_arr{j,i})./each_photon_weight_arr(1,i);
    end
end


% phantom
sum_3=zeros(1,5);

for i=1:5
    for j=1:10
        sum_3(i)=sum_3(i)+length(PL_arr{j,i})./each_photon_weight_arr(1,i);
    end
end



%%
ph_prob=[];
for i=1:6
    temp_TPSF=load(fullfile('MCML_sim_lkt_2','cal_reflectance_10',['phantom_' num2str(i) '_TPSF.txt']));
    ph_prob(i,:)=sum(temp_TPSF,1);
end

head_prob=[];
for i=1:5
    head_prob(i)=sum(spec(1+(i-1)*10:i*10));
end

