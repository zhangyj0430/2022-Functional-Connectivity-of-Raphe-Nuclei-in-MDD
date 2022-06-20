clc;clear;
%% ttest2 for eachcenter
path='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/SeedFC_map';
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/raphe_masks';
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/subject_info/SubInfo.xlsx');
Mask=[mask_dir,'/GroupMask.nii'];
center={'CMU','CSU','GCMU1','GCMU2','KMU','PKU','SCU','SWU','YMU','ZZU'};
group={'DR_raw','MR_raw'};
for g=1:2
    for k=1:10
            hc=dir([path,'/zROI',num2str(g),center{1,k},'*HC*.nii']);
            data1=[];
            for i=1:length(hc)
                data1{1,i}=[hc(i).folder,'/',hc(i).name] ;
            end
            hc_data=data1';
            mdd=dir([path,'/zROI',num2str(g),center{1,k},'*MDD*.nii']);
            data2=[];
            for i=1:length(mdd)
                data2{1,i}=[mdd(i).folder,'/',mdd(i).name] ;
            end
            mdd_data=data2';        
            data={mdd_data;hc_data};
            ind_hc=SubInfo.group==0&SubInfo.ID==k;
            ind_mdd=SubInfo.group==1&SubInfo.ID==k;
            Covariates={[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd)];[SubInfo.age(ind_hc),SubInfo.sex(ind_hc)]};
            OutputName=[group{1,g},'_',center{1,k},'_HC_MDD_Tmap'];
            [TTest2_T,Header] = y_TTest2_Image(data,OutputName,Mask,[],Covariates);
    end 
end

%% Mate analysis: regional between-group analysis
addpath(genpath('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Funcs'));
[mask,~,~,~]=y_ReadAll(Mask);
log_mask=logical(mask);
seed={'Mate_DR','Mate_MR'};
other_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Otherfiles';
dr_s =[other_dir,'/BrainMesh_ICBM152_smoothed.nv']; 
mr_s =[other_dir,'/BrainMesh_Cerebellum_by_SLF.nv'];
surfacefile ={dr_s,mr_s};
dr_c= [other_dir,'/DR_Cgf.mat'];
mr_c=[other_dir,'/MR_Cgf.mat'];
Cgf={dr_c,mr_c};

w=[374,285,68,132,91,148,91,536,214,295];%sample size for each center
for n_seed=1:2 
    file=dir([group{n_seed},'*Tmap.nii']);
    data=[];
    for i=1:length(file)
        data{i,1}=[file(i).folder,'/',file(i).name] ;
    end
    num_cov=2; %%age,sex
    [tem,voxelsize,~,Header]=y_ReadAll(data);
 
    for num=1:length(data)
        df=w(num)-2-num_cov;
        t=tem(:,:,:,num);
        z_center = spm_t2z(t,df);
        z(:,:,:,num)=(z_center.*log_mask)*sqrt(w(num));
    end
    denominator=sqrt(sum(w));
    hv_mdd_com_z=sum(z,4)./denominator;
    Header.pinfo = [1;0;0];
    Header.dt    =[16,0];
    HeaderTWithDOF=Header;
    HeaderTWithDOF.descrip=sprintf('{Z}');
    y_Write(hv_mdd_com_z,HeaderTWithDOF,[seed{n_seed},'_T2_comZ_hc_mdd.nii'])
    [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF([seed{n_seed},'_T2_comZ_hc_mdd.nii'],0.001,0,0.05,[seed{n_seed},'_T2_comZ_hc_mdd_GRF'],Mask,'Z');
    BrainNet_MapCfg(surfacefile{n_seed},[seed{n_seed},'_T2_comZ_hc_mdd_GRF.nii'],Cgf{n_seed},[seed{n_seed},'_T2_comZ_hc_mdd_GRF.tif']);
end

