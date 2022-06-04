clc;clear;
%% OneSmple t-test for eachcenter(HC and MDD)
addpath(genpath('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Funcs'));
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/subject_info/SubInfo.xlsx');
mask_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/raphe_masks';
Mask=[mask_dir,'/GroupMask.nii'];
Center={'CMU','CSU','GCMU1','GCMU2','KMU','PKU','SCU','SWU','YMU','ZZU'};
group={'HC','MDD'};
ROI={'DR_raw','MR_raw'};
path='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/SeedFC_map';
for g=1:2
    for n_seed=1:2
        for C=1:10
             file=dir([path,'/zROI',num2str(n_seed),Center{C},'*',group{g},'*.nii']);
             data=[];
             for i=1:length(file)
                 data{i,1}=[file(i).folder,'/',file(i).name];
             end
             ind=find(SubInfo.group==g-1&SubInfo.ID==C);
             Regressors1={[SubInfo.age(ind),SubInfo.sex(ind),SubInfo.FD(ind)]};
             [TTest1_T1,Header1] = y_TTest1_Image({data},[ROI{n_seed},'_',group{g},'_',Center{C},'_Tmap'],Mask,[],Regressors1,0);
        end
    end
end
%% Mate analysis
other_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Otherfiles';
surfacefile =[other_dir,'/BrainMesh_ICBM152_smoothed.nv'];
Cgf= [other_dir,'/OneST_Cgf.mat'];
[mask,~,~,~]=y_ReadAll(Mask);
log_mask=logical(mask);
W{1,1}=[248,108,34,66,46,73,41,254,109,100];% the munbers of HC for each center
W{1,2}=[125,177,34,66,41,75,48,282,105,195];% the munbers of MDD for each center
seed={'Mate_DR','Mate_MR'};
for n_seed=1:2
    for g=1:2
        file=dir([ROI{1,n_seed},'_',group{1,g},'*_Tmap.nii']);
        data=[];
        for i=1:length(file)
            data{i,1}=[file(i).folder,'/',file(i).name] ;
        end
        [tem,voxelsize,~,Header]=y_ReadAll(data);
        num_cov=2; %age,sex;
        for num=1:10
            df=w(num)-1-num_cov;
            t=tem(:,:,:,num);
            z_center = spm_t2z(t,df);
            z(:,:,:,num)=(z_center.*log_mask)*sqrt(w(num));
        end
        denominator=sqrt(sum(w));
        com_z=sum(z,4)./denominator;
        
        Header.pinfo = [1;0;0];
        Header.dt    =[16,0];
        HeaderTWithDOF=Header;
        HeaderTWithDOF.descrip=sprintf('{Z}');
        y_Write(com_z,HeaderTWithDOF,[seed{n_seed},'_',group{g},'_Tmap'])
        voxel_p=0.001;
        [GRF_Data_Corrected,ClusterSize,GRF_Header]=GRF([seed{n_seed},'_',group{g},'_Tmap'],voxel_p,1,0.05,[seed{n_seed},'_',group{g},'_Tmap_GRF'],[],'Z');
        BrainNet_MapCfg(surfacefile,[seed{n_seed},'_',group{g},'_Tmap_GRF.nii'],Cgf,[seed{n_seed},'_',group{g},'_Tmap_GRF.tif']);
    end
end


