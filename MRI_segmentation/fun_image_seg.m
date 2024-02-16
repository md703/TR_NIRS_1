%{
Segment the image into multuple regions

Input:
input_image_orig: the image to segment
Outputs:
output_index_map: the region index for each voxel, with sorted region area, 1 for the largest region. Same size as the input_image_orig
output_root_arr: one point for each region, a R*2 array, R for the number of regions.

Benjamin Kao
Last update: 2020/08/09
%}

function [output_index_map,output_root_arr]=fun_image_seg(input_image_orig)
global input_image index_map;
input_image=input_image_orig;
index_map=zeros(size(input_image));
root_arr=[];
max_index=1;
for x=1:size(input_image,1)
    for y=1:size(input_image,2)
        if input_image(x,y)>0 && index_map(x,y)==0
            root_arr(max_index,:)=[x,y];
            fun_region_growing(x,y,max_index);
            max_index=max_index+1;
        end
    end
end
output_index_map=zeros(size(input_image));
output_root_arr=zeros(size(root_arr));
max_index=max_index-1;
region_area=zeros(1,max_index);
for i=1:max_index
    region_area(i)=length(find(index_map==i));
end
[~,sorted_index]=sort(region_area,'descend');
for i=1:max_index
    output_index_map(index_map==sorted_index(i))=i;
    output_root_arr(i,:)=root_arr(sorted_index(i),:);
end
end

function fun_region_growing(x,y,assign_index)
global input_image index_map;
if input_image(x,y)>0 && index_map(x,y)==0
%     fprintf('[%d,%d]\n',x,y);
    index_map(x,y)=assign_index;
    if x-1>=1
        fun_region_growing(x-1,y,assign_index);
    end
    if x+1<=size(input_image,1)
        fun_region_growing(x+1,y,assign_index);
    end
    if y-1>=1
        fun_region_growing(x,y-1,assign_index);
    end
    if y+1<=size(input_image,2)
        fun_region_growing(x,y+1,assign_index);
    end
end
end