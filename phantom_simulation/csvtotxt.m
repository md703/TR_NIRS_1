

data=readtable(fullfile('epsilon','musp_in_mm-phantom1-6.csv'));
data=data(2:end,[1 2 5 6 7 4 3]);
data_=table2array(data);
temp_data=data_(:,2:end)*10;
data=[data_(:,1) temp_data];
save(fullfile('epsilon','musp_cm.txt'),'data','-ascii','-tabs');


data=readtable(fullfile('epsilon','mua_in_mm_phantom1_6.csv'));
data=data(2:end,[1 2 5 6 7 4 3]);
data_=table2array(data);
temp_data=data_(:,2:end)*10;
data=[data_(:,1) temp_data];
save(fullfile('epsilon','mua_FDA_cm.txt'),'data','-ascii','-tabs');



