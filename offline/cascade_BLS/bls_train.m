function [delt_shape,RegModel] = bls_train(train_x,train_y,options,current_cascade)
% Learning Process of the proposed broad learning system
%Input: 
%---train_x,test_x : the training data and learning data 
%---train_y,test_y : the label 
%---We: the randomly generated coefficients of feature nodes
%---wh:the randomly generated coefficients of enhancement nodes
%----s: the shrinkage parameter for enhancement nodes
%----C: the regularization parameter for sparse regualarization
%----N11: the number of feature nodes  per window
%----N2: the number of windows of feature nodes

%%%%%%%%%%%%%%feature nodes%%%%%%%%%%%%%%
tic
s           = options.s(current_cascade);
C           = options.C(current_cascade);
N11          = options.N11(current_cascade);
N2          = options.N2(current_cascade);
N33          = options.N33(current_cascade); 
N1=N11; N3=N33;

train_x = zscore(train_x')';% ����ԭʼ��ݵľ�ֵ�ͱ�׼�������ݵı�׼��?
H1 = [train_x .1 * ones(size(train_x,1),1)];y=zeros(size(train_x,1),N2*N1);
for i=1:N2
    we=2*rand(size(train_x,2)+1,N1)-1;  %����-1��1֮��������
    We{i}=we;
    A1 = H1 * we;A1 = mapminmax(A1);    %����ݹ�һ����?1��1֮��
    clear we;
beta1  =  sparse_bls(A1,H1,1e-3,50)';
beta11{i}=beta1;
% clear A1;
T1 = H1 * beta1;
fprintf(1,'Feature nodes in window %f: Max Val of Output %f Min Val %f\n',i,max(T1(:)),min(T1(:)));

[T1,ps1]  =  mapminmax(T1',0,1);T1 = T1';  %%����ݹ�һ����?��1֮��
ps(i)=ps1;

% y=[y T1];
y(:,N1*(i-1)+1:N1*i)=T1;
end

clear T1;
%%%%%%%%%%%%%enhancement nodes%%%%%%%%%%%%%%%%%%%%%%%%%%%%

H2 = [y .1 * ones(size(y,1),1)];
if N1*N2>=N3
     wh=orth(2*rand(N2*N1+1,N3)-1);
else
    wh=orth(2*rand(N2*N1+1,N3)'-1)'; 
end
Wh{1} = wh;
T2 = H2 *wh;
l2 = max(max(T2));
l2 = s/l2;
fprintf(1,'Enhancement nodes: Max Val of Output %f Min Val %f\n',l2,min(T2(:)));
%T2 = max(0,T2 * l2);
%T2 = logsig(T2 * l2);
T2 = tansig(T2 * l2);
% v = randn(size(train_y,2), 1);
% v = v/norm(v);
% Y_prob = zeros(size(train_y,1), 1);
% for j = 1: size(train_y,1)
%     Y_prob(j) = sum(train_y(j,:)'.*v);
% end
% % cca_T2 = T2;
% cca_T2 = zscore(T2')';
% cov_prob = zeros(1, size(cca_T2,2));
% sigma_prob = std(Y_prob);
% score = zeros(size(cca_T2,2),1);
% for j = 1:size(cca_T2,2)
%         covmatrix = cov(Y_prob, cca_T2(:, j));
%         cov_prob(j) = covmatrix(2); 
%         sigma_T3j = std(cca_T2(:, j));
%         score(j) =  abs(cov_prob(j)/(sigma_prob*sigma_T3j));
% end
% num_maintain = size(T2,2)*0.8;
% [~,ind] = sort(score,'descend');
% T2 = T2(:,ind(1:num_maintain));
% [A,B,R,U,V] = canoncorr(train_y,T2);
% T2 = V;
T3=[y T2];
clear H2;clear T2;
beta = (T3'  *  T3+eye(size(T3',1)) * (C)) \ ( T3');
beta2=beta*train_y;
Training_time = toc;
disp('Training has been finished!');
disp(['The Total Training Time is : ', num2str(Training_time), ' seconds' ]);
%%%%%%%%%%%%%%%%%Training Accuracy%%%%%%%%%%%%%%%%%%%%%%%%%%
delt_shape = T3 * beta2;

tic;
RegModel.train_x_size2 = size(train_x,2);
RegModel.beta2  =beta2;
RegModel.beta   = beta;
RegModel.beta11 = beta11;
RegModel.ps     = ps;
RegModel.wh     = Wh;
RegModel.l2     = l2;
RegModel.T3     = T3; 
% RegModel.ind    = ind;
% RegModel.train_y = train_y;
% RegModel.H1 = H1;
% RegModel.y = y;
end

