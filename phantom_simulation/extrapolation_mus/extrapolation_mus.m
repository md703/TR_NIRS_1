% use the equation musp=A*lambda^-k to extrapolate the mus
% 20191213 Benjamin Kao

clc;clear;close all;

num_phantom=6;
to_output_wl=(600:1100)';

original_musp=load('musp_cm.txt');

A_arr=[];
K_arr=[];
new_musp=to_output_wl;

figure('units','normalized','outerposition',[0 0 1 1]);
for i=1:num_phantom
    % log(musp)=-K * log(lambda) +log (A)
    y=log(original_musp(:,i+1));
    x=log(original_musp(:,1));
    p=polyfit(x,y,1);
    A_arr(i)=exp(p(2));
    K_arr(i)=-p(1);
    new_musp(:,i+1)=A_arr(i).*to_output_wl.^-K_arr(i);
    
    subplot(2,3,i);
    plot(original_musp(:,1),original_musp(:,i+1),new_musp(:,1),new_musp(:,i+1));
    legend({'old','new'},'Location','best');
    xlabel('wavelength(nm)');
    ylabel('\mu_s''(1/cm)');
    title({['phantom ' num2str(i) ' \mu_s'''],['A= ' num2str(A_arr(i)) ', K=' num2str(K_arr(i))]});
end

to_save=[A_arr; K_arr];
save('AK.txt','to_save','-ascii','-tabs');
save('new_musp.txt','new_musp','-ascii','-tabs');

saveas(gcf,'compare_musp.png');