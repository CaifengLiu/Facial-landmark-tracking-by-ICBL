function [Data] = read_frame( img,shape, options )

Data = cell(1, 1);
iimgs = 1;
Data{iimgs}.shape_gt = shape;
Data{iimgs}.width_orig  = size(img,2);
Data{iimgs}.height_orig = size(img,1);
%% load shape
if size(img,3) > 1
    img = rgb2gray(uint8(img));
end
Data{iimgs}.bbox_gt = getbbox(Data{iimgs}.shape_gt);
%% enlarge region of face
region     = enlargingbbox(Data{iimgs}.bbox_gt, options.Aug_BoxScale);
region(2)  = double(max(region(2), 1));
region(1)  = double(max(region(1), 1));
Data{iimgs}.bbox_original = region;
bottom_y   = double(min(region(2) + region(4) - 1, ...
    Data{iimgs}.height_orig));
right_x    = double(min(region(1) + region(3) - 1, ...
    Data{iimgs}.width_orig));

img_region = img(region(2):bottom_y, region(1):right_x, :);
Data{iimgs}.shape_gt = bsxfun(@minus, Data{iimgs}.shape_gt,...
    double([region(1) region(2)]));
Data{iimgs}.bbox_gt = getbbox(Data{iimgs}.shape_gt);
Data{iimgs}.img_gray = img_region;

Data{iimgs}.width    = size(img_region, 2);
Data{iimgs}.height   = size(img_region, 1);
sr = options.canvasSize(1)/Data{iimgs}.width;
sc = options.canvasSize(2)/Data{iimgs}.height;
Data{iimgs}.img_gray = imresize(Data{iimgs}.img_gray,options.canvasSize);
Data{iimgs}.height_orig = Data{iimgs}.height;
Data{iimgs}.width_orig = Data{iimgs}.width;

Data{iimgs}.width    = options.canvasSize(1);
Data{iimgs}.height   = options.canvasSize(2);
Data{iimgs}.shape_gt = bsxfun(@times, Data{iimgs}.shape_gt, [sr sc]); 
Data{iimgs}.bbox_gt  = getbbox(Data{iimgs}.shape_gt);

end

function region = enlargingbbox(bbox, scale)

region(1) = floor(bbox(1) - (scale - 1)/2*bbox(3));
region(2) = floor(bbox(2) - (scale - 1)/2*bbox(4));

region(3) = floor(scale*bbox(3));
region(4) = floor(scale*bbox(4));

end