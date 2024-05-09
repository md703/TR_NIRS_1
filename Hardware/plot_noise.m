%{
To see if sqrt(N)*CV will be constant or not. => seems not
 
Ting-Yi Kuo
Last update: 2024/04/08
%}

folderPath='20240402';
save_name={'3min','2min'};

const=[];
for i=1:length(save_name)
    load(fullfile(folderPath,[save_name{i} '_processed.mat'])); % binning_TPSF, CV
    TPSF=sqrt(mean(binning_TPSF(1:10,:),2));
    const(end+1:end+length(TPSF),1)=TPSF.*CV(1:10,1);
end

figure;
plot(const,'Linewidth',2);