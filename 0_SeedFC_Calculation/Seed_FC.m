clc;clear;
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/raphe_masks';
output_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/SeedFC_map';
workingDir1='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Raw_Data/D1_GSR_NoS';
sublist1=dir(workingDir1);
ind=[sublist1(:).isdir];
sublist1=sublist1(ind);
sublist1=sublist1(3:end);
n_sub1=size(sublist1,1);

workingDir2='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Raw_Data/D2_GSR_S';
sublist2=dir(workingDir2);
ind=[sublist2(:).isdir];
sublist2=sublist2(ind);
sublist2=sublist2(3:end);
n_sub2=size(sublist2,1);

[ROI1mask,~,~,~] =y_ReadAll([mask_dir,'/dr_mask_ICBM152_flirt_2MNI152_3mm.nii']);
[ROI2mask,~,~,~] =y_ReadAll([mask_dir,'/mr_mask_ICBM152_flirt_2MNI152_3mm.nii']);
[drx,dry,drz]=ind2sub(size(ROI1mask),find(ROI1mask==1));
[mrx,mry,mrz]=ind2sub(size(ROI2mask),find(ROI2mask==1));

for sub=1:n_sub1  
    sublist1(sub).name
    file=dir([sublist1(sub).folder,'/',sublist1(sub).name,'/*nii']);
    [AllVolume,~,~,~] =y_ReadAll([file.folder,'/',file.name]); 
   %caculate seed-DR
    SeedSeries_dr=[];
    SeedSeriesSTD=[];
    for i=1:size(drx,1)
        SeedSeries_dr(:,i)=AllVolume(drx(i),dry(i),drz(i),:);
    end 
    SeedSeries_dr=mean(SeedSeries_dr,2);
    SeedSeries_dr=SeedSeries_dr-repmat(mean(SeedSeries_dr),size(SeedSeries_dr,1),1);
    SeedSeriesSTD=squeeze(std(SeedSeries_dr,0,1)); 
    
    sublist2(sub).name
    sfile=dir([sublist2(sub).folder,'/',sublist2(sub).name,'/*nii']);
    [sAllVolume,~,~,Header] =y_ReadAll([sfile.folder,'/',sfile.name]);    
    [nDim1, nDim2, nDim3, nDimTimePoints]=size(sAllVolume);
    sAllVolume=reshape(sAllVolume,[],size(sAllVolume,4))';  
    sAllVolume = sAllVolume-repmat(mean(sAllVolume),size(sAllVolume,1),1);
    sAllVolumeSTD= squeeze(std(sAllVolume, 0, 1));
    sAllVolumeSTD(find(sAllVolumeSTD==0))=inf;    
    
    Header.pinfo = [1;0;0];
    Header.dt    =[16,0];
    OutputName=[output_dir,'/',sublist1(sub).name,'.nii'];

    FC_dr=SeedSeries_dr'*sAllVolume/(nDimTimePoints-1);
    FC_dr=(FC_dr./sAllVolumeSTD)/SeedSeriesSTD;

    FCBrain=FC_dr;
    FCBrain=reshape(FCBrain,nDim1, nDim2, nDim3);
    zFCBrain = (0.5 * log((1 + FCBrain)./(1 - FCBrain)));

    [pathstr, name, ext] = fileparts(OutputName);
    y_Write(zFCBrain,Header,fullfile(pathstr,['zROI1',name, ext]));
% caculate seed-MR
    SeedSeries_mr=[];
    SeedSeriesSTD=[];
    for i=1:size(mrx,1)
        SeedSeries_mr(:,i)=AllVolume(mrx(i),mry(i),mrz(i),:);
    end 
    SeedSeries_mr=mean(SeedSeries_mr,2);
    SeedSeries_mr=SeedSeries_mr-repmat(mean(SeedSeries_mr),size(SeedSeries_mr,1),1);
    SeedSeriesSTD=squeeze(std(SeedSeries_mr,0,1));
        
    FC_mr=SeedSeries_mr'*sAllVolume/(nDimTimePoints-1);
    FC_mr=(FC_mr./sAllVolumeSTD)/SeedSeriesSTD;

    FCBrain=FC_mr;
    FCBrain=reshape(FCBrain,nDim1, nDim2, nDim3);
    zFCBrain = (0.5 * log((1 + FCBrain)./(1 - FCBrain)));
    [pathstr, name, ext] = fileparts(OutputName);
    y_Write(zFCBrain,Header,fullfile(pathstr,['zROI2',name, ext]));
end