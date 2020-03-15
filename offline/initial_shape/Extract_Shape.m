function [extract_shape ] = Extract_Shape(Data,options )
%%intilization
ndata           = length(Data);
shape_dim       = 2*size(Data{1}.shape_gt,1);
extract_shape = zeros(ndata , shape_dim);
%%start extrac the data matrixes
disp('extract the data matrixes for class')
box_standard =getbbox(Data{1}.shape_gt);
winsize_width = options.initwinsize(1);
winsize_height = options.initwinsize(2);
parfor idata = 1 : ndata
    shape_gt = Data{idata}.shape_gt;
    bbox = getbbox(shape_gt);
    sr = winsize_width /bbox(3);
    sc = winsize_height/bbox(4);
    shape_gt = bsxfun(@times, shape_gt, [sr sc]); 
%     shape_gt = bsxfun(@minus, (shape_gt), shape_gt(1,:));%��
%      shape_gt = bsxfun(@minus, (shape_gt), (min(shape_gt)));%��
%     shape_gt = resetshape(box_standard ,shape_gt);
%     shape_gt = bsxfun(@plus, shape_gt, double([box_standard(1) box_standard(2)]));
    extract_shape(idata ,:) = shape_2_vec(shape_gt);%%deltshape
end
end