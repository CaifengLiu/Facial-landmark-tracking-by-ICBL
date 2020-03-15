function [x,Testing_time] = test_LBS(test_x,BLS_regressors_icascade,options,current_cascade )
beta2    = BLS_regressors_icascade.beta2;
beta11  = BLS_regressors_icascade.beta11;
ps      = BLS_regressors_icascade.ps;
wh      = BLS_regressors_icascade.wh{1};
l2      = BLS_regressors_icascade.l2;
s           = options.s(current_cascade);
C           = options.C(current_cascade);
N11          = options.N11(current_cascade);
N2          = options.N2(current_cascade);
N33          = options.N33(current_cascade); 
% C = 2^-30; s = .8;%the l2 regularization parameter and the shrinkage scale of the enhancement nodes
% N11=10;%feature nodes  per window
% N2=10;% number of windows of feature nodes
% N33=11000;% number of enhancement nodes
% epochs=1;% number of epochs 
 N1=N11; N3=N33; 

tic;
test_x = zscore(test_x')';
HH1 = [test_x .1 * ones(size(test_x,1),1)];
%clear test_x;
yy1=zeros(size(test_x,1),N2*N1);
for i=1:N2
    beta1=beta11{i};ps1=ps(i);
    TT1 = HH1 * beta1;
    TT1  =  mapminmax('apply',TT1',ps1)';

clear beta1; clear ps1;
%yy1=[yy1 TT1];
yy1(:,N1*(i-1)+1:N1*i)=TT1;
end
clear TT1;clear HH1;
HH2 = [yy1 .1 * ones(size(yy1,1),1)]; 
TT2 = tansig(HH2 * wh * l2);%%%¼¤»îº¯Êý
% TT2 = max(0,HH2 * wh * l2);
%TT2 = logsig(HH2 * wh * l2);
TT3=[yy1 TT2];
clear HH2;clear wh;clear TT2;
%%%%%%%%%%%%%%%%% testing accuracy%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = TT3 * beta2;
% y = result(x);
% test_yy = result(test_y);
% TestingAccuracy = length(find(y == test_yy))/size(test_yy,1);
% clear TT3;
Testing_time = toc;
% disp('Testing has been finished!');
% disp(['The Total Testing Time is : ', num2str(Testing_time), ' seconds' ]);



end