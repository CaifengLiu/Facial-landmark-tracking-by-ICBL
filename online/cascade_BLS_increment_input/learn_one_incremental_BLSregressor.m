function [Reg_model] = learn_one_incremental_BLSregressor(Data,LearnedDistribution,BLS_regressors,options, current_cascade)
nData             = length(Data);
n_points          = size(Data{1}.shape_gt,1);
shape_dim         = 2*n_points;
GMMtag = options.GMM;

if strcmp(options.descType,'sift') == 1
    desc_dim      = 128;

elseif strcmp(options.descType,'hog') == 1
    desc_dim      = 124;
end


storage_init_desc       = zeros(nData,desc_dim*n_points);
storage_del_shape       = zeros(nData,shape_dim);
% 
% if current_cascade>1 %options.ifUpdateDistribution ==1&&current_cascade>1&&current_cascade<3
%     Miu_new = LearnedDistribution.Miu_Newtrue - (LearnedDistribution.Miu_true-LearnedDistribution.Miu);
%     a_old = options.current_n/(options.current_n+nData);
%     a_new = nData/(options.current_n+nData);
%     LearnedDistribution.Miu = a_old*LearnedDistribution.Miu+a_new*Miu_new;
%     
%     Sigma_new = LearnedDistribution.Sigma_Newtrue - (LearnedDistribution.Sigma_true-LearnedDistribution.Sigma);
%     a_old = options.current_n/(options.current_n+nData);
%     a_new = nData/(options.current_n+nData);
%     Sigma_new = (Sigma_new+Sigma_new.')/2 +0.00001 *eye(size(Sigma_new,1));
%     Sigma = a_old*LearnedDistribution.Sigma + a_new*Sigma_new;
%     LearnedDistribution.Sigma = (Sigma+Sigma.')/2 +0.00001 *eye(size(Sigma,1));
% end
%%

disp('Start to extract the features for Data')

parfor idata = 1 : nData
    %waitbar(idata/nData,h)
    if current_cascade == 1
        current_shape               = Data{idata}.current_shape;
        shape_residual              = Data{idata}.shape_residual;
    else
         delt_shape_i_cascade    = generate_delt_shape(LearnedDistribution, GMMtag);
        
        

        delt_shape_i_cascade    = vec_2_shape(delt_shape_i_cascade');
        
        bbox_gt                 = getbbox(Data{idata}.shape_gt);
        Wscale_to_mean = bbox_gt(:,3)/LearnedDistribution.mean_wh(1);
        Hscale_to_mean = bbox_gt(:,4)/LearnedDistribution.mean_wh(2);       
%         Wscale_to_mean = Data{idata}.initial_bbox(:,3)/LearnedDistribution{current_cascade}.distribution.mean_wh(1);
%         Hscale_to_mean = Data{idata}.initial_bbox(:,4)/LearnedDistribution{current_cascade}.distribution.mean_wh(2);
        delt_shape_i_cascade    = bsxfun(@times,delt_shape_i_cascade ,[Wscale_to_mean Hscale_to_mean]);
       

        delt_shape_for_i        = bsxfun(@times, delt_shape_i_cascade, bbox_gt(3:4));
        

        current_shape           = Data{idata}.shape_gt - delt_shape_for_i;
        shape_residual          = delt_shape_i_cascade;
    end

    
    img = Data{idata}.img_gray;
    tmp = local_descriptors(img, current_shape, options, current_cascade);
    storage_init_desc(idata, :) = tmp(:);
    storage_del_shape(idata, :) = shape_2_vec(shape_residual);   
%     clear img;
%     clear current_shape;
end

disp('solving regression problem by BLS...');
% storage_init_desc = mapminmax(storage_init_desc,0,1);
% size_train =  4*nData/options.augnumber;
% options.l = 2;
options.m = nData;
% storage_init_desc_trainset = storage_init_desc(1:size_train,:); 
% storage_del_shape_train = storage_del_shape(1:size_train,:);
[~,Reg_model] = add_input_bls_train(storage_init_desc,storage_del_shape,BLS_regressors,options,current_cascade);

end

