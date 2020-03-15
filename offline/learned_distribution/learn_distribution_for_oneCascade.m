function [Data,Distribution,PCAmapping,rms] = learn_distribution_for_oneCascade(Data, options, current_cascade)

nData             = length(Data);
n_points          = size(Data{1}.shape_gt,1);
shape_dim         = 2*n_points;
n_init_randoms    = options.augnumber;

if strcmp(options.descType,'sift') == 1
    desc_dim      = 128;

elseif strcmp(options.descType,'hog') == 1
    desc_dim      = 124;
end

storage_init_desc       = zeros(nData,desc_dim*n_points);
storage_del_shape       = zeros(nData,shape_dim);
storage_shape_gt_for_dist =  zeros(nData,shape_dim);
mean_bbox               = zeros(1,4);
current_bbox            = zeros(nData,4);
gt_bbox = zeros(nData,4);
%%%%%%%%%%%%%%%%%%%%%extract the feature for BLS%%%%%%%%%%%%%%%%%%%%%%%
disp('Start to extract the features for Data')
% parfor_progress(nData);
%h = waitbar(0,[num2str(current_cascade)  '-th Feature Extraction>>> Please wait...' ]);
parfor idata = 1 : nData

    %     parfor_progress;%set the percentage of progressing
    %waitbar(idata/nData,h)
    img  = Data{idata}.img_gray;
    shape_gt = Data{idata}.shape_gt;
    bbox_gt = shape_gt;
    current_shape = Data{idata}.current_shape;
%     current_bbox(idata,:) = getbbox(current_shape); 
%     mean_bbox = mean_bbox + current_bbox(idata,:);
    gt_bbox(idata,:) = getbbox(bbox_gt); 
    mean_bbox = mean_bbox + gt_bbox(idata,:);
    tmp = local_descriptors(img, current_shape, options, current_cascade);
    storage_init_desc(idata, :) = tmp(:);
    storage_del_shape(idata, :) = shape_2_vec(Data{idata}.shape_residual);
    storage_shape_gt_for_dist(idata,:) =  shape_2_vec(Data{idata}.shape_gt_for_distri);
%     clear img;
%     clear current_shape;
end
%delete(h);
% parfor_progress(0)
%% solving regression by BLS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('solving regression problem by BLS...');
if options.ifPCA_for_desc      == 1
    [storage_init_desc, PCAmapping] = pca(storage_init_desc, options.PCA_dims(current_cascade));
else
    PCAmapping = [];
end
[delt_shape,~] = bls_train(storage_init_desc,storage_del_shape,options,current_cascade);

%%solving the distribution
mean_bbox = mean_bbox/nData;
Wscale_to_mean = repmat(mean_bbox(3),nData,1)./gt_bbox(:,3);
Hscale_to_mean = repmat(mean_bbox(4),nData,1)./gt_bbox(:,4);
for i = 1:nData
tmp_xy =  vec_2_shape(storage_del_shape(i,:)');
tmp_xy = bsxfun(@times,tmp_xy,[Wscale_to_mean(i) Hscale_to_mean(i)]);
meanxy(i,:) = mean(tmp_xy);
storage_del_shape(i,:) = shape_2_vec(tmp_xy);
tmp_gt =  vec_2_shape(storage_shape_gt_for_dist(i,:)');
tmp_gt = bsxfun(@times,tmp_gt,[Wscale_to_mean(i) Hscale_to_mean(i)]);
storage_shape_gt_for_dist(i,:) = shape_2_vec(tmp_gt);
end

if options.GMM == 1
        DeltShapeGMM = fitgmdist(storage_del_shape,options.GMM_K_components,'RegularizationValue',0.000001);
        Distribution.GMMparameters = DeltShapeGMM;
else
    [Miu, Sigma]        = mean_covariance_of_data (storage_del_shape);
    Distribution.Miu    = Miu;
    Distribution.Sigma  = Sigma;
%     [Miu_true, Sigma_true]        = mean_covariance_of_data (storage_shape_gt_for_dist);
%     Distribution.Miu_true    = Miu_true;
%     Distribution.Sigma_true  = Sigma_true;
end
Distribution.mean_wh = [mean_bbox(3),mean_bbox(4)];
Distribution.currentnum = 4000;
%%compute the distribution

%%updating the new shape%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
err = zeros(nData,1);
parfor idata = 1:nData
     bbox_gt = getbbox(Data{idata}.shape_gt);
     delt_shape_for_i           = vec_2_shape(delt_shape(idata,:)');
     shape_currentCascade       = Data{idata}.current_shape;
     delt_shape_for_i           = bsxfun(@times, delt_shape_for_i, bbox_gt(3:4));
     shape_newCascade           = shape_currentCascade + delt_shape_for_i;
     
     
     Data{idata}.current_shape  = shape_newCascade;
     Data{idata}.current_bbox   = getbbox(shape_newCascade );
     
     
     Data{idata}.shape_residual = bsxfun(@rdivide, Data{idata}.shape_gt - shape_newCascade, bbox_gt(3:4));
     
     Data{idata}.shape_gt_for_distri = bsxfun(@rdivide,Data{idata}.shape_gt,bbox_gt(3:4));
    
    %%%compute error for each sample%%%
    err(idata) = rms_err(Data{idata}.current_shape, Data{idata}.shape_gt,options);

end



% %%%%%%%%%%generating the delt_shape by Miu, Sigma
% delt_shape = mvnrnd(Miu, Sigma, nData);


rms = 100*mean(err);
disp(['rms = ' num2str(rms)]);
disp(['There are ' num2str(options.augnumber) 'Initials and average err is : ' num2str(100*mean(err))]);

clear storage_init_des;
clear storage_del_shape;
end