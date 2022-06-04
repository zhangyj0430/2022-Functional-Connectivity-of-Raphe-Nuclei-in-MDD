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
Mask=[mask_dir,'/GroupMask.nii'];
%% leval one out: regional between-group analysis
Center={'CMU','CSU','GCMU1','GCMU2','KMU','PKU','SCU','SWU','YMU','ZZU'};
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
Cov=[SubInfo.age,SubInfo.sex,SubInfo.FD];
for n_seed=1:2
    hc_dirs=dir([data_dir,'/zROI',num2str(n_seed),'*HC*.nii']);
    hc=[];
    for i=1:length(hc_dirs)
        hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name] ;
    end
    mdd_dirs=dir([data_dir,'/zROI',num2str(n_seed),'*MDD*.nii']);
    mdd=[];
    for i=1:length(mdd_dirs)
        mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name] ;
    end
    data=[hc;mdd];
    for c=1:10
        ind=find(SubInfo.ID~=c);
         mm=SubInfo.group(ind);
        num_hc=size(find(mm==0),1);
        num_mdd=size(find(mm==1),1);
        cov=Cov(ind,:);
        Covariates={cov(num_hc+1:end,:);cov(1:num_hc,:)};     
        data=data(ind);
        DependentDirs={data(num_hc+1:end,:);data(1:num_hc,:)};        
        [TTest2_T,Header] = y_TTest2_Image(DependentDirs,[seed{n_seed},'_T2_hc_mdd_',Center{c}],Mask,[],Covariates);
        [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF([seed{n_seed},'_T2_hc_mdd_',Center{c}],0.001,0,0.05,[seed{n_seed},'_T2_hc_mdd_',Center{c},'_GRF'],Mask);
        BrainNet_MapCfg(surfacefile{n_seed},[seed{n_seed},'_T2_hc_mdd_',Center{c},'_GRF.nii'],Cgf{n_seed},[seed{n_seed},'_T2_hc_mdd_',Center{c},'_GRF.tif']);
    end
end
