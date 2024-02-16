%{
Use the trained ANN to predict the spec

OPs: 8 column of OPs, mua1 mus1 mua2 ......

Benjamin Kao
Last update: 2020/10/26
%}

function spec=fun_ANN_forward(OPs)
global net param_range;
% param
do_normalize=1; % if =1, do normalization to spec and param

%% main
OPs=OPs(:,[1 3 5 7 2 4 6 8]); % re-arrange the OPs to match the input of ANN

if do_normalize
    param_scaling=param_range(1,:)-param_range(2,:);
    OPs=(OPs-param_range(2,:))./param_scaling;
end
spec=predict(net,OPs');
spec=double(spec');
if do_normalize
    spec=power(10,-spec);
end

end
