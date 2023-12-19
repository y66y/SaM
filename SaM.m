function [f_c,s_data]=SaM(g_data,K,lambda)
% g_data is the data matrix, K is the number of actions, and lambda is the
% parameter

%% phase I: split
N=size(g_data,1);
alpha=0.3;

L=ceil(alpha*N/K);
g_data=movmean(g_data,L);
s_data=getSimilarity(g_data);
B=[];
V=[];
for iss=L:L:N
    [val,ind]=max(s_data(iss-L+1:iss));
    B=[B;ind+iss-L];
    V=[V;val];
end
[B,vv]=unique(B);

%% phase II: merge

K_now=length(B)+1;
B=[0;B;N];
f_c=zeros(N,1);
for k=1:K_now
    f_c(B(k)+1:B(k+1))=k;
end
if merge_flag
    for KK=K_now:-1:K+1
        X=[];
        for ki=1:KK
            X=[X;mean(g_data(f_c==ki,:),1)];
        end
        indfc=[];
        for i=1:KK
            [indii,~]=find(f_c==i);
            indfc=[indfc;mean(indii)/N];
        end
        WKK=getSimilarityGraph(X,indfc,lambda);
        val=max(max(WKK));
        [x,y]=find(WKK==val);
        ind=[x y];
        f_c(f_c==ind(2))=ind(1);
        f_c=orderlabel(f_c);
    end
end
%%
    function s_data=getSimilarity(g_data)
        s_data=[];
        for is=1:size(g_data,1)-1
            a=g_data(is,:);
            a=a/norm(a,2);
            b=g_data(is+1,:);
            b=b/norm(b,2);
            w=acos(a*b')*180/pi;
            s_data=[s_data;w];
        end
        s_data=[s_data;s_data(end)];
        sig=var(s_data);
        for is=1:size(g_data,1)
            s_data(is)=exp(-real(s_data(is))/sig^2);
        end
    end
end