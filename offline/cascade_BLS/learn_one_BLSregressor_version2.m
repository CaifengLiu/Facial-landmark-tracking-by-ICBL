function [Reg_model,rms] = learn_one_BLSregressor_version2(Data,LearnedDistribution, options, current_cascade)
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
stroage_current_shape   = zeros(nData,shape_dim);


%%

disp('Start to extract the features for Data')
% parfor_progress(nData);
%h = waitbar(0,[num2str(current_cascade)  '-th Feature Extraction>>> Please wait...' ]);
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
    stroage_current_shape(idata,:) = shape_2_vec(current_shape);
%     clear img;
%     clear current_shape;
end
%delete(h);
if options.ifPCA_for_desc      == 1
    load([options.modelPath options.slash options.datasetName ...
        'LearnedPCA_for_desc.mat'],'LearnedPCA_for_desc');
    storage_init_desc = bsxfun(@minus, storage_init_desc, LearnedPCA_for_desc{current_cascade}.PCAmapping.mean);
    storage_init_desc = storage_init_desc * LearnedPCA_for_desc{current_cascade}.PCAmapping.M;
    clear LearnedPCA_for_desc;
end
disp('solving regression problem by BLS...');
[delt_shape,Reg_model] = bls_train(storage_init_desc,storage_del_shape,options,current_cascade);

parfor idata = 1:nData
    delt_shape_for_i                  = vec_2_shape(delt_shape(idata,:)');
    if current_cascade ==1

        delt_shape_for_i           = bsxfun(@times, delt_shape_for_i, Data{idata}.current_bbox(3:4));
    else

        delt_shape_for_i           = bsxfun(@times, delt_shape_for_i, Data{idata}.bbox_gt(3:4));
        
    end
    shape_newCascade           =  stroage_current_shape(idata,:) + shape_2_vec(delt_shape_for_i)';
    err(idata) = rms_err(vec_2_shape(shape_newCascade'), Data{idata}.shape_gt,options);
end

rms = 100*mean(err);
disp(['rms = ' num2str(rms)]);
disp(['There are ' num2str(options.augnumber) 'Initials and average err is : ' num2str(100*mean(err))]);
end

