function [delt_shape,add_input_RegModel] = add_input_bls_train(train_xf,train_yf,BLS_regressor,options,current_cascade)
%%initialization 
l = options.l;
m = options.m;
N2 = options.N2(current_cascade);
C           = options.C(current_cascade);
N1          = options.N11(current_cascade);
N11         = N1;
%y_initial = BLS_regressor.train_y_before;
T3          = BLS_regressor.T3;
beta11 = BLS_regressor.beta11;
beta2 = BLS_regressor.beta2;
beta   = BLS_regressor.beta;
ps     = BLS_regressor.ps;
wh     = BLS_regressor.wh{1};
l2     = BLS_regressor.l2;
%%%%generating the Y
test_x = zscore(train_xf')';
HH1 = [test_x .1 * ones(size(test_x,1),1)];
yy1=zeros(size(test_x,1),N2*N11);
for i=1:N2
    beta1=beta11{i};ps1=ps(i);
    TT1 = HH1 * beta1;
    TT1  =  mapminmax('apply',TT1',ps1)';
    %yy1=[yy1 TT1];
    yy1(:,N11*(i-1)+1:N11*i)=TT1;
end
clear TT1;
HH2 = [yy1 .1 * ones(size(yy1,1),1)]; 
TT2 = tansig(HH2 * wh * l2(1)); TT3=[yy1 TT2];





for e=1:l
    tic
    train_xx= zscore(train_xf((0+(e-1)*m+1):(0+e*m),:)')';
    train_yx= train_yf((0+(e-1)*m+1):(0+e*m),:);
    %train_y1= [y_initial;train_yf(1:0+e*m,:)];
    Hx1 = [train_xx .1 * ones(size(train_xx,1),1)];yx=[];
    parfor i=1:N2
        beta1=beta11{i};ps1=ps(i);
        Tx1 = Hx1 * beta1;
        Tx1  =  mapminmax('apply',Tx1',ps1)';
        % clear beta1; clear ps1;
        yx=[yx Tx1];
    end
    Hx2 = [yx .1 * ones(size(yx,1),1)];
%     wh=Wh{1};
    t2=Hx2 * wh;
    %     l2(e+1) = max(max(t2));
    %     l2(e+1) = s/l2(e+1);
    fprintf(1,'Enhancement nodes in incremental setp %f: Max Val of Output %f Min Val %f\n',e,l2(1),min(t2(:)));
    % yx=(yx-1)*2+1;
    t2 = tansig(t2 * l2(1));
    t2=[yx t2];

    d = t2*beta;
    c = t2-d*T3; % 行代表样本个数
    if all(c(:)<0.01)
        [w,q]=size(d);
        b=(eye(w)+d*d')\(d*beta'); 
        b = b';
    else
        b = (c'  *  c+eye(size(c,2)) * (C)) \ ( c' );
        %b = b';
    end
    beta=[beta-b*d b];
    T3 = [T3;t2];
%    beta2_tmp1 = beta*train_y1;
   %%论文中的更新方法
     beta2_tmp1 = beta2 + b*(train_yx - t2*beta2);
    beta2 = beta2_tmp1;
   % beta=[beta betat];     
    delt_shape = t2 * beta2;
    
    
    
%     betat = (t2'  *  t2+eye(size(t2',1)) * (C)) \ ( t2' );
%     beta=[beta betat];
%     beta2=beta*train_y1;
%     T3=[T3;t2];
    Training_time=toc;

    
end

% % % %delt_shape = TT3 * beta2;

add_input_RegModel.beta   = beta;
add_input_RegModel.beta11 = beta11;
add_input_RegModel.ps     = ps;
add_input_RegModel.wh     = BLS_regressor.wh;
add_input_RegModel.l2     = l2;
add_input_RegModel.beta2  = beta2;
add_input_RegModel.T3 = T3;
% % % add_input_RegModel.train_y_before = train_y1; 
end