% compare the parameters of different measure result

clc;clear;close all;

%% PDMS
PDMS_name={'20181211_pdms_mua_cm.txt','20190314_BingBond_PDMS_mua_cm.txt','20190314_QiaoYue_PDMS_mua_cm.txt'};
PDMS_legend_arr={'old','BingBond','QiaoYue'};
PDMS_spec={};

for i=1:length(PDMS_name)
    PDMS_spec{i}=load(PDMS_name{i});
end

figure;
hold;
for i=1:length(PDMS_name)
    plot(PDMS_spec{i}(:,1),PDMS_spec{i}(:,2));
end
title('PDMS mua');
xlabel('wavelength(nm)');
ylabel('\mu_a(1/cm)');
legend(PDMS_legend_arr,'Location','best');

%% ink
ink_name={'20181212_old_IndiaInk_original_mua_cm.txt','20181211_IndiaInk_original_mua_cm.txt','20190331_IndiaInk_original_mua_cm.txt'};
ink_legend_arr={'20181212','20181211','20190331'};
ink_spec={};

for i=1:length(ink_name)
    ink_spec{i}=load(ink_name{i});
end

figure;
hold;
for i=1:length(ink_name)
    plot(ink_spec{i}(:,1),ink_spec{i}(:,2));
end
title('ink mua');
xlabel('wavelength(nm)');
ylabel('\mu_a(1/cm)');
legend(ink_legend_arr,'Location','best');