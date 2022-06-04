clc;clear;
SubInfo = readtable('/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/subject_info/SubInfo.xlsx');
data_dir='/home1/zhangyj/Desktop/MDD/MDD_RapheNuclei/SampleData/Sample_SeedFC/ComBet_ten_zROI';
mask=y_ReadAll('DR_T2_hc_mdd_GRF_Vp0001_mask.nii');
ind_hc=(1:1079)';
ind_mdd=(1085:2234)';
ind_Med=find(SubInfo.Med==1);
ind_No_Med=find(SubInfo.No_Med==1);
ind_FE=find(SubInfo.FE==1);
ind_recurrent=find(SubInfo.No_FE==1);
ind_onsetB21=find(SubInfo.onsetB21==1);
ind_onsetS21=find(SubInfo.onsetS21==1);
str={'hc','mdd','Med','No_Med','FE','recurrent','onsetB21','onsetS21'};
ind={ind_hc,ind_mdd-1079,ind_Med-1079,ind_No_Med-1079,ind_FE-1079,ind_recurrent-1079,ind_onsetB21-1079,ind_onsetS21-1079};
file1=dir([data_dir,'/zROI1*HC*.nii']);
file2=dir([data_dir,'/zROI1*MDD*.nii']);
file={file1,file2,file2,file2,file2,file2,file2,file2};
%% caculate meanFC in the cluster for each subject
for g=1:8
    for i=1:length(file{1,g})
        D{i,1}=[file{1,g}(i).folder,'/',file{1,g}(i).name] ;  
    end
    data=D(ind{1,g});
   [A,~,~,header]=y_ReadAll(data);
   A=reshape(A,[],size(A,4));
   M=reshape(mask,[],1);
   voxel=size(find(M~=0),1);
   R{1,g}=(sum(A.*M,1)/voxel)';   
   R{2,g}=str{1,g};
end
%% statstc meanFC between HC and Subgroup
ind_hc=find(SubInfo.group==0);
ind_mdd=find(SubInfo.group==1);
cov_hc=[SubInfo.age(ind_hc),SubInfo.sex(ind_hc)];
cov_mdd=[SubInfo.age(ind_mdd),SubInfo.sex(ind_mdd)];
T=[];P=[];
for j=2:8
    [t,p]=y_TTest2Cov(R{1,1},R{1,j},cov_hc,cov_mdd(ind{1,j},:));
    T(1,j-1)=t;
    P(1,j-1)=p;
end
save ROImeanResults_DR.mat P T R;

%% hdrs for each subgroup
MDD=find(SubInfo.hdrs_type==17);
hdrsMDD=SubInfo.hdrs(MDD);

Med=find(SubInfo.Med==1&SubInfo.hdrs_type==17);
hdrsMed=SubInfo.hdrs(Med);

No_Med=find(SubInfo.No_Med==1&SubInfo.hdrs_type==17);
hdrs_noMed=SubInfo.hdrs(No_Med);

FE=find(SubInfo.FE==1&SubInfo.hdrs_type==17);
hdrsFE=SubInfo.hdrs(FE);

recurrent=find(SubInfo.No_FE==1&SubInfo.hdrs_type==17);
hdrs_recurrent=SubInfo.hdrs(recurrent);

onsetB21=find(SubInfo.onsetB21==1&SubInfo.hdrs_type==17);
hdrs_onsetB21=SubInfo.hdrs(onsetB21);

onsetS21=find(SubInfo.onsetS21==1&SubInfo.hdrs_type==17);
hdrs_onsetS21=SubInfo.hdrs(onsetS21);

index_hdrs={MDD-1079,Med-1079,No_Med-1079,FE-1079,recurrent-1079,onsetB21-1079,onsetS21-1079};
m={hdrsMDD,hdrsMed,hdrs_noMed,hdrsFE,hdrs_recurrent,hdrs_onsetB21,hdrs_onsetS21};
p_cov_hdrs={cov_mdd(index_hdrs{1,1},:),cov_mdd(index_hdrs{1,2},:),cov_mdd(index_hdrs{1,3},:),cov_mdd(index_hdrs{1,4},:)...
    cov_mdd(index_hdrs{1,5},:),cov_mdd(index_hdrs{1,6},:),cov_mdd(index_hdrs{1,7},:)};

for i=1:length(file2)
    DD{i,1}=[file2(i).folder,'/',file2(i).name] ;  
end
R_hdrs=[];
P_hdrs=[];
str2={'MDD','Med','NoMed','FE','Recurrent','Onset>21','Onset<21'};

for k=1:7
    SeedSeries=m{1,k};
    data=DD(index_hdrs{1,k});
    [ A,~,~,header]=y_ReadAll(data);
    A=reshape(A,[],size(A,4));
    subplot(7,1,k);
    M=reshape(mask,[],1);
    kk=A.*M;
    kk(M==0,:)=[];
    ROI=mean(kk,1)';
    [r,p]=partialcorr(SeedSeries,ROI,p_cov_hdrs{1,k});
    f = fit(SeedSeries,ROI,'poly1');
    fig=plot(f,SeedSeries,ROI);
    %         set(fig,'Color','k','LineWidth',1.7,'MarkerSize',1)
    set(gca,'Fontname','Times New Roman','FontSize',8,'LineWidth',1)
    set(gcf,'unit','centimeters','position',[20 0 6 25]);
    xlabel('HDRS');
    ylabel(['mFC_',str2{k}],'Interpreter','none');
    xlim([0 50])
    ylim([-0.5 1])
    legend off
    R_hdrs(k)=r;
    P_hdrs(k)=p;
end
save HDRScorrCluster_PT_DR.mat R_hdrs P_hdrs
saveas (gcf,'HDRScorrCluster_DR_PT.tiff');
close all


%% duration for each subgroup
M=find(SubInfo.durInd==1);
durMDD=SubInfo.dur_y(M);

Med2=find(SubInfo.Med==1&SubInfo.durInd==1);
durMed=SubInfo.dur_y(Med2);

No_Med2=find(SubInfo.No_Med==1&SubInfo.durInd==1);
durNoMed=SubInfo.dur_y(No_Med2);

FE2=find(SubInfo.FE==1&SubInfo.durInd==1);
durFE=SubInfo.dur_y(FE2);

recurrent2=find(SubInfo.No_FE==1&SubInfo.durInd==1);
durRecurr=SubInfo.dur_y(recurrent2);

onsetB212=find(SubInfo.onsetB21==1&SubInfo.durInd==1);
durB21=SubInfo.dur_y(onsetB212);

onsetS212=find(SubInfo.onsetS21==1&SubInfo.durInd==1);
durS21=SubInfo.dur_y(onsetS212);

index_dur={M-1079,Med2-1079,No_Med2-1079,FE2-1079,recurrent2-1079,onsetB212-1079,onsetS212-1079};
n={durMDD,durMed,durNoMed,durFE,durRecurr,durB21,durS21};
p_cov_dur={cov_mdd(index_dur{1,1},:),cov_mdd(index_dur{1,2},:),cov_mdd(index_dur{1,3},:),cov_mdd(index_dur{1,4},:)...
    cov_mdd(index_dur{1,5},:),cov_mdd(index_dur{1,6},:),cov_mdd(index_dur{1,7},:)};

R_dur=[];
P_dur=[];
for k=1:7
    SeedSeries=n{1,k};
    data=DD(index_dur{1,k});
    [ A,~,~,header]=y_ReadAll(data);
    A=reshape(A,[],size(A,4));
    subplot(7,1,k);
    M=reshape(mask,[],1);
    kk=A.*M;
    kk(M==0,:)=[];
    ROI=mean(kk,1)';
    [r,p]=partialcorr(SeedSeries,ROI,p_cov_dur{1,k});
    f = fit(SeedSeries,ROI,'poly1');
    fig=plot(f,SeedSeries,ROI);
    set(gca,'Fontname','Times New Roman','FontSize',8,'LineWidth',1)
    set(gcf,'unit','centimeters','position',[20 0 6 25]);
    xlabel(['DUR'],'Interpreter','none');
    ylabel(['mFC_',str2{k}],'Interpreter','none');
    xlim([0 50])
    ylim([-0.5 1])
    legend off
    R_dur(k)=r;
    P_dur(k)=p;
end
save DURcorrCluster_PT_DR.mat R_dur P_dur
saveas (gcf,'DURcorrCluster_DR_PT.tiff');
close all


