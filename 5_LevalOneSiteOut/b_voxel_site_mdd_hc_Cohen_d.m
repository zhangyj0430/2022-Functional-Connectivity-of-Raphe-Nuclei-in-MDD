clc;clear;
data_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/ComBet_ten_zROI';
%% leval one out: regional between-group analysis
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/subject_info/SubInfo.xlsx');
Center={'CMU','CSU','GCMU1','GCMU2','KMU','PKU','SCU','SWU','YMU','ZZU'};
mask=y_ReadAll('DR_T2_hc_mdd_GRF_mask.nii');
hc_dirs=dir([data_dir,'/zROI1*HC*.nii']);
hc=[];
for i=1:length(hc_dirs)
    hc{i,1}=[hc_dirs(i).folder,'/',hc_dirs(i).name] ;
end
mdd_dirs=dir([data_dir,'/zROI1*MDD*.nii']);
mdd=[];
for i=1:length(mdd_dirs)
    mdd{i,1}=[mdd_dirs(i).folder,'/',mdd_dirs(i).name];
end
data=[hc;mdd];
[A,~,~,header]=y_ReadAll(data);
A=reshape(A,[],size(A,4));
M=reshape(mask,[],1);
R=A(find(M~=0),:)';

for c=1:10
    ind=find(SubInfo.ID==c);
    ind_hc=find(SubInfo.group==0&SubInfo.ID==c);
    ind_mdd=find(SubInfo.group==1&SubInfo.ID==c);
    D=R(ind,:);
    Cov=[SubInfo.age,SubInfo.sex];
    for i=1:size(D,2)
        [r,~,~] = regress_out(D(:,i),Cov(ind,:));       
        [~,p(c,i)]=ttest2(r(1:size(ind_hc,1)),r(size(ind_hc,1)+1:end));
        d(c,i)=abs(cohen(r(1:size(ind_hc,1)),r(size(ind_hc,1)+1:end)));
    end    
end




