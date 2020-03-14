function Data = data_processing(Data,Meanshape)
% if first==1
     InitialShape = vec_2_shape(Meanshape);
%     load(['.\offline\initial_shape\w300Q.mat']);
%      phy  = ExtractInitPhy(Data{1},[96 128],16);
%      tmp_shape= regress( phy , Q );
%      InitialShape = vec_2_shape(tmp_shape');

% else
%      InitialShape = shape_previous;
% end
Data{1}.current_shape = resetshape(Data{1}.bbox_gt, InitialShape );
Data{1}.current_bbox = getbbox(Data{1}.current_shape);
Data{1}.initial_bbox = Data{1}.current_bbox;
Data{1}.shape_residual = bsxfun(@rdivide, Data{1}.shape_gt - Data{1}.current_shape(:,:), [Data{1}.current_bbox(3) Data{1}.current_bbox(4)]); 

end