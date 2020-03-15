function [Reg_model,rms] = learn_one_BLSregressor(Data,LearnedDistribution, options, current_cascade)

nData             = length(Data);
n_points          = size(Data{1}.shape_gt,1);
shape_dim         = 2*n_points;
n_init_randoms    = options.augnumber;

if strcmp(options.descType,'sift') == 1
    desc_dim      = 128;

elseif strcmp(options.descType,'hog') == 1
    desc_dim      = 124;
end


storage_init_desc       = zeros(nData*n_init_randoms,desc_dim*n_points);
storage_del_shape       = zeros(nData*n_init_randoms,shape_dim);
stroage_current_shape   = zeros(nData*n_init_randoms,shape_dim);


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
        meanshape2tf = cell(1,current_cascade);
        tf2meanshape = cell(1,current_cascade);
        current_bbox                = zeros(current_cascade,4);
        new_stage                   = Data{idata}.current_shape;
        meanshape2tf{1}             = Data{idata}.meanshape2tf;
        tf2meanshape{1}             = Data{idata}.tf2meanshape;
        current_bbox(1,:)           = Data{idata}.current_bbox;
        for icascade = 1:current_cascade-1
            delt_shape_i_cascade    = generate_delt_shape(LearnedDistribution{icascade}.distribution,options.GMM);
            delt_shape_i_cascade    = vec_2_shape(delt_shape_i_cascade');
            [u,v]                   = transformPointsForward(meanshape2tf{icascade},...
                                    delt_shape_i_cascade(:,1)',delt_shape_i_cascade(:,2)');
            delt_shape_for_i        = [u',v'];
            delt_shape_for_i        = bsxfun(@times, delt_shape_for_i, current_bbox(icascade,3:4));
            new_stage               =  new_stage + delt_shape_for_i;
            current_bbox(icascade+1,:)= getbbox(new_stage); 
            meanshape_resize        = resetshape(current_bbox(icascade+1,:), options.InitialShape);
            shape_residual          = bsxfun(@rdivide, Data{idata}.shape_gt - new_stage, current_bbox(icascade+1, 3:4));
            tf2meanshape{icascade+1}  = fitgeotrans(bsxfun(@minus, new_stage(:,:), mean(new_stage(:,:))),...
                                    bsxfun(@minus, meanshape_resize(:,:), mean(meanshape_resize(:,:))), 'NonreflectiveSimilarity');
            
            meanshape2tf{icascade+1}   = fitgeotrans(bsxfun(@minus, meanshape_resize(:,:), mean(meanshape_resize(:,:))),...
                                    bsxfun(@minus, new_stage(:,:), mean(new_stage(:,:))),'NonreflectiveSimilarity');
                                
            [u,v] = transformPointsForward(tf2meanshape{icascade+1}, shape_residual(:,1), shape_residual(:,2));
            shape_residual(:,1) = u';
            shape_residual(:,2) = v';       
            current_shape = new_stage;
        end

    end
    
    img = Data{idata}.img_gray;
    tmp = local_descriptors(img, current_shape, options, current_cascade);
    storage_init_desc(idata, :) = tmp(:);
    storage_del_shape(idata, :) = shape_2_vec(shape_residual);   
    stroage_current_shape(idata,:) = shape_2_vec(current_shape);

end
%delete(h);
disp('solving regression problem by BLS...');
[delt_shape,Reg_model] = bls_train(storage_init_desc,storage_del_shape,options,current_cascade);

for idata = 1:nData
    tmp_shape                  = vec_2_shape(delt_shape(idata,:)');
    if current_cascade ==1
        [u, v]                     = transformPointsForward(Data{idata}.meanshape2tf,...
                                        tmp_shape(:,1)',tmp_shape(:,2)');
        delt_shape_for_i           = [u',v'];
        delt_shape_for_i           = bsxfun(@times, delt_shape_for_i, Data{idata}.current_bbox(3:4));
    else
        [u, v]                     = transformPointsForward(meanshape2tf{current_cascade},...
                                        tmp_shape(:,1)',tmp_shape(:,2)');
        delt_shape_for_i           = [u',v'];
        delt_shape_for_i           = bsxfun(@times, delt_shape_for_i, current_bbox(current_cascade,3:4));
        
    end
    shape_newCascade           =  stroage_current_shape(idata,:) + shape_2_vec(delt_shape_for_i)';
    err(idata) = rms_err(vec_2_shape(shape_newCascade'), Data{idata}.shape_gt,options);
end

rms = 100*mean(err);
disp(['rms = ' num2str(rms)]);
disp(['There are ' num2str(options.augnumber) 'Initials and average err is : ' num2str(100*mean(err))]);
end