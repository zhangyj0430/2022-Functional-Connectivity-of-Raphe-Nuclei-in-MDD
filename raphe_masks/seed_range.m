clc;
clear;
map=load_nii('dr_mask_ICBM152_flirt_2MNI152_1mm.nii');
ind=setdiff(unique(map.img(:)),0);
%Origin of MNI space
origin=map.hdr.hist.originator(1,1:3);
%Voxel dimension
mm=map.hdr.dime.pixdim(1,2); 
coor=zeros(length(ind),3);
for i=1:length(ind)
    [x,y,z]=ind2sub(size(map.img),find(ind(i)==map.img));
    [val,ind_min]=min(sqrt((mean(x)-x).^2+(mean(y)-y).^2+(mean(z)-z).^2)); 
    coor(i,:)=[x(ind_min(1)),y(ind_min(1)),z(ind_min(1))]; 
end
%seed range
seed_r=[x,y,z];
seed_r=(seed_r-repmat(origin,length(ind),1))*mm; 
dr_x=unique(seed_r(:,1));
dr_y=unique(seed_r(:,2));
dr_z=unique(seed_r(:,3));
%Map voxel coordinates to MNI coordinates
dr_center=(coor-repmat(origin,length(ind),1))*mm; 


map=load_nii('mr_mask_ICBM152_flirt_2MNI152_1mm.nii');
ind=setdiff(unique(map.img(:)),0);
%Origin of MNI space
origin=map.hdr.hist.originator(1,1:3);
%Voxel dimension
mm=map.hdr.dime.pixdim(1,2); 
coor=zeros(length(ind),3);
for i=1:length(ind)
    [x,y,z]=ind2sub(size(map.img),find(ind(i)==map.img));
    [val,ind_min]=min(sqrt((mean(x)-x).^2+(mean(y)-y).^2+(mean(z)-z).^2)); 
    coor(i,:)=[x(ind_min(1)),y(ind_min(1)),z(ind_min(1))]; 
end
%seed range
seed_r=[x,y,z];
seed_r=(seed_r-repmat(origin,length(ind),1))*mm; 
mr_x=unique(seed_r(:,1));
mr_y=unique(seed_r(:,2));
mr_z=unique(seed_r(:,3));

%Map voxel coordinates to MNI coordinates
mr_center=(coor-repmat(origin,length(ind),1))*mm; 
