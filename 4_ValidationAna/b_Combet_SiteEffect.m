clc;
clear;
addpath(genpath('/home1/zhangyj/Desktop/MDD/AnalysisData/SeedFC/BeliveauSeedFC_GSR/Funcs'));
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/subject_info/SubInfo.xlsx'); 
group=SubInfo.ID;
mask_dir='/home1/zhangyj/Desktop/MDD/AnalysisData/SeedFC/BeliveauSeedFC_GSR/Mask';
Mask=[mask_dir,'/GroupMask.nii'];
mask=load_nii(Mask);
[x,y,z]=size(mask.img);
M=reshape(mask.img,[],1);
ind=find(M~=0);
Seed={'DR','MR'};
filepath='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/ComBet_ten_zROI';
for roi=1:2
    file=[];
    file1=dir([filepath,'/zROI',num2str(roi),'*HC*']);
    file2=dir([filepath,'/zROI',num2str(roi),'*MDD*']);
    file=[file1;file2];
    for i=1:length(file)
        load_nii([file(i).folder,'/',file(i).name]);
        tep=reshape(ans.img,[],1);
        AllVolume(:,i)=tep(ind);
    end
    for j=1:size(AllVolume,1)
        disp(['prossing:' num2str(j)])
        Stats=kwtest([AllVolume(j,:)',group]);
        temp_F_F(j)= Stats.F.F;
        temp_F_P(j)= Stats.F.pvalue;
    end
    N=zeros(size(tep,1),1);
    N(ind)=temp_F_F;
    F_F=reshape(N,[x,y,z]);
    Df_Group=length(file);
    Header.pinfo = [1;0;0];
    Header.dt    = [16,0];
    Header.mat    = [-3,0,0,93;0,3,0,-129;0,0,3,-75;0,0,0,1];
    HeaderTWithDOF=Header;
    HeaderTWithDOF.descrip=sprintf('DPABI{F_%.1f}',Df_Group);
    y_Write(F_F,HeaderTWithDOF,['Com_',Seed{1,roi},'_F.nii']);
    [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF(['Com_',Seed{1,roi},'_F.nii'],0.001,0,0.05,['Com_',Seed{1,roi},'_F_GRF.nii'],'F',size(group,1)-9,9);
end

