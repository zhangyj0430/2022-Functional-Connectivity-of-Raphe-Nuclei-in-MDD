function [d] = cohen(d1,d2)
m1=mean(d1);
m2=mean(d2);
% S1=var(d1)^2;
% S2=var(d2)^2;
S1=std(d1)^2;
S2=std(d2)^2;
n1=size(d1,1);
n2=size(d2,1);
Spool=sqrt(((n1-1).*S1+(n2-1).*S2)./(n1+n2-2));
d=(m1-m2)./Spool;
end

