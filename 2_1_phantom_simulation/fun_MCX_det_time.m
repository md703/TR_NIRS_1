%{
Calculate dectected time of each photon 
and store the pathlength (cm) into gate

Ting-Yi Kuo
last update: 2023/06/12
Version: 4.41
%}

function [detpt_arr_time]=fun_MCX_det_time(detpL_arr,cfg,num_gate)

%% initialize
% media_num=size(cfg.prop,1);
% if(media_num<=1)
%     error('empty property list');
% end

detpt_arr_time=cell(num_gate,1);
dett=zeros(size(detpL_arr,1),1);
R_C0 = 3.333333e-11;	% inverse of light speed in vacuum (cm/s)^-1

%% Split into time gates

for i=2
    dett=dett+1.457*detpL_arr(:,i)*R_C0;
end

[tempcounts, idx]=histc(dett,0:cfg.tstep:cfg.tend);
for g=1:num_gate
    detpt_arr_time{g,1}=detpL_arr(idx==g,:);
end
%     detpt_arr_time(g,s)=temp_arr;
