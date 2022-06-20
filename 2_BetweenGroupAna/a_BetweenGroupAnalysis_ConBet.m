clc;clear;
addpath(genpath('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Funcs'));
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/subject_info/SubInfo.xlsx');
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/raphe_masks';
data_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/ComBet_ten_zROI';
seed={'ComBet_DR','ComBet_MR'};
other_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Otherfiles';
dr_s =[other_dir,'/BrainMesh_ICBM152_smoothed.nv']; 
mr_s =[other_dir,'/BrainMesh_Cerebellum_by_SLF.nv'];
surfacefile ={dr_s,mr_s};
dr_c= [other_dir,'/DR_Cgf.mat'];
mr_c=[other_dir,'/MR_Cgf.mat'];
Cgf={dr_c,mr_c};

ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
num_hc=length(ind_hc);
num_mdd=length(ind_mdd);
Covariates={[SubInfo.age(ind_hc),SubInfo.sex(ind_hc)];[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd)]};
Mask=[mask_dir,'/GroupMask.nii'];
mask=logical(y_ReadAll(Mask));
M=reshape(mask,[],1);

%% global FC between-group analysis
T=[];P=[];FC=[];
for n_seed=1:length(seed)
    hc_dirs=dir([data_dir,'/zROI',num2str(n_seed),'*HC*.nii']);
    hc=[];
    for i=1:length(hc_dirs)
        hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name] ;
    end
    mdd_dirs=dir([data_dir,'/zROI',num2str(n_seed),'*MDD*.nii']);
    mdd=[];
    for i=1:length(mdd_dirs)
        mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name];
    end
    Depdir=[hc;mdd];
    A=y_ReadAll(Depdir);
    A=reshape(A,[],size(A,4));
    voxel=size(find(M~=0),1);
    meanFC=(sum(A.*M,1)/voxel)';   
    [T0,P0] = y_TTest2Cov(meanFC(1:num_hc),meanFC(num_hc+1:end),Covariates{1,1},Covariates{2,1});
    FC(:,n_seed)=meanFC;
    T(n_seed)=T0;
    P(n_seed)=P0;
end
% save ComBet_globalFC_stats.mat FC T P

%% Combet mode: regional between-group analysis 
for n_seed=1:length(seed)
    hc_dirs=dir([data_dir,'/zROI',num2str(n_seed),'*HC*.nii']);
    hc=[];
    for i=1:length(hc_dirs)
        hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name];
    end
    mdd_dirs=dir([data_dir,'/zROI',num2str(n_seed),'*MDD*.nii']);
    mdd=[];
    for i=1:length(mdd_dirs)
        mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name];
    end
    DependentDirs={mdd;hc};
    [TTest2_T,Header] = y_TTest2_Image(DependentDirs,[seed{n_seed},'_T2_hc_mdd'],Mask,[],Covariates);
    [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF([seed{n_seed},'_T2_hc_mdd'],0.001,0,0.05,[seed{n_seed},'_T2_hc_mdd_GRF'],Mask);
    BrainNet_MapCfg(surfacefile{n_seed},[seed{n_seed},'_T2_hc_mdd_GRF.nii'],Cgf{n_seed},[seed{n_seed},'_T2_hc_mdd_GRF.tif']);
end

