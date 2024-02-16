
num_target=5;

mua=load('result_1.txt');

for i=2:num_target
    temp=load(['result_' num2str(i) '.txt']);
    mua=[mua temp(:,2)];
end

save('mu_a.txt','mua','-ascii','-tabs');

disp('Done!');