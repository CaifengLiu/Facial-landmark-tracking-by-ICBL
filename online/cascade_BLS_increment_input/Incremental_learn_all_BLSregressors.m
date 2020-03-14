function [Addinput_BLS_regressors,LearnedDistribution]=Incremental_learn_all_BLSregressors( Data,LearnedDistribution,BLS_regressors,storage_new_deltshape,options)

n_cascades                    = options.n_cascades;
Addinput_BLS_regressors{n_cascades}.R   = [];

%%%start to learn the BLSregressors depending on the deltX distributions 
% if options.ifUpdateDistribution ==1
%     nData = length(Data);
%     storage_shape_gt_for_dist =  zeros(nData,2*options.num_pts);
%     mean_w= LearnedDistribution{1}.distribution.mean_wh(1);
%     mean_h = LearnedDistribution{1}.distribution.mean_wh(2);
%     for idata = 1:nData
%         Wscale_to_mean = mean_w/Data{idata}.bbox_gt(3);
%         Hscale_to_mean = mean_h/Data{idata}.bbox_gt(4);
%         tmp_ture = bsxfun(@rdivide,Data{idata}.shape_gt,Data{idata}.bbox_gt(3:4));
%         tmp_ture = bsxfun(@times,tmp_ture,[Wscale_to_mean Hscale_to_mean]);
%         storage_shape_gt_for_dist(idata,:) = shape_2_vec(tmp_ture);
%         
%     end
%     [Miu_true_New, Sigma_true_New]        = mean_covariance_of_data (storage_shape_gt_for_dist);
% end
ifUpdateDistribution = options.ifUpdateDistribution;
num_pts=options.num_pts;


tic
for icascade = 1:n_cascades

%      if ifUpdateDistribution ==1 && icascade>1
%    
%         LearnedDistribution{icascade}.distribution = update_distribution(LearnedDistribution{icascade}.distribution,...
%             storage_new_deltshape(:,(icascade-1)*2*num_pts+1:(icascade)*2*num_pts));
%      end

    R = learn_one_incremental_BLSregressor(Data,LearnedDistribution{icascade}.distribution, BLS_regressors{icascade}.R,options,icascade);%%R =
%     Addinput_BLS_regressors{icascade}.R = R;
 

end
toc

end