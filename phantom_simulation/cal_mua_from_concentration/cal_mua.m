% this function can calculate Mua for given concentration
% Tzu-Chia Kao 20181206

clc;clear;close all;

mua_ink=load('measured_parameter_smoothed/20190331_IndiaInk_original_mua_cm.txt');
mua_pdms=load('measured_parameter_smoothed/20190314_BingBond_PDMS_mua_cm.txt');
%wl=(601:1049)';
wl=(600:1100)';
mua_ink=[wl interp1(mua_ink(:,1),mua_ink(:,2),wl)];
mua_pdms=[wl interp1(mua_pdms(:,1),mua_pdms(:,2),wl)];

ink_concentration=load('concentration.txt');

mua_arr=wl;
legned_arr={};
for i=1:length(ink_concentration)
    mua=mua_pdms(:,2)+mua_ink(:,2)*ink_concentration(i);
    mua_arr=[mua_arr mua];
    legend_arr{i}=['ink=' num2str(ink_concentration(i))];
end
save('result.txt','mua_arr','-ascii','-tabs');
plot(mua_arr(:,1),mua_arr(:,2:end));
title('phantom \mu_a')
xlabel('wavelength(nm)')
ylabel('\mu_a(1/cm)');
legend(legend_arr,'Location','best');
disp('Done!');