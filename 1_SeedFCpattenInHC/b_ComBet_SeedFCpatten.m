clc;clear;
addpath(genpath('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Funcs'));
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/subject_info/SubInfo.xlsx');
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/raphe_masks';
data_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/ComBet_ten_zROI';
other_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Otherfiles';
surfacefile =[other_dir,'/BrainMesh_ICBM152_smoothed.nv']; 
Cgf= [other_dir,'/OneST_Cgf.mat'];
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
Covariates={[SubInfo.age(ind_hc),SubInfo.sex(ind_hc)];[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd)]};
seed={'ComBet_DR','ComBet_MR'};
group={'HC','MDD'};
Mask=[mask_dir,'/GroupMask.nii'];
for n_seed=1:length(seed)
    for g=1:length(group)
        file1=dir([data_dir,'/zROI',num2str(n_seed),'*',group{g},'*.nii']);
        data=[];
        for nn=1:length(file1)
            data{nn,1}=[file1(nn).folder,'/',file1(nn).name] ;
        end
        data={data};
        [TTest1_T1,Header1] = y_TTest1_Image(data,[seed{n_seed},'_',group{g},'_Tmap'],Mask,[],Covariates(g,1));
        [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF([seed{n_seed},'_',group{g},'_Tmap'],0.001,1,0.05,[seed{n_seed},'_',group{g},'_Tmap_GRF'],Mask);
        BrainNet_MapCfg(surfacefile,[seed{n_seed},'_',group{g},'_Tmap_GRF.nii'],Cgf,[seed{n_seed},'_',group{g},'_Tmap_GRF.tif']);
    end
end
