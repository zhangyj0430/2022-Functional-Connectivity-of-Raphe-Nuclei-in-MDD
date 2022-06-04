clc;clear;
addpath(genpath('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/Funcs'));
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/subject_info/SubInfo.xlsx');
mask=load_nii('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/raphe_masks/GroupMask.nii');
Nvoxel=size(find(mask.img==1),1);
mask=logical(mask.img);
path='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/SeedFC_map';
outpath='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/ComBet_ten_zROI';
group=SubInfo.ID;
for n_seed=1:2
    hc=dir([path,'/zROI',num2str(n_seed),'*HC*.nii']);
    mdd=dir([path,'/zROI',num2str(n_seed),'*MDD*.nii']);
    file=[hc;mdd];
    AllVolume=zeros(Nvoxel,length(file));
    for numsub=1:length(file)
        tem=load_nii([file(numsub).folder,'/',file(numsub).name]);
        temp=reshape(tem.img,[],1);
        AllVolume(:,numsub)=temp(mask,:);
    end
    data=AllVolume;
    disease = dummyvar(SubInfo.group+1);
    mod = disease(:,2);
    data_new = combat(data,group,mod,1);
    
    for sub=1:size(data_new,2)
        temp=zeros(size(mask));
        temp(mask) = data_new(:,sub);
        file(sub).name
        subject=load_nii([file(sub).folder,'/',file(sub).name]);
        subject.img=temp;
        save_nii(subject,[outpath,'/',file(sub).name(1:end-4),'_ComBet.nii']);
    end
end