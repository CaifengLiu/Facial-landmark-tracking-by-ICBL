function mean_shape = calc_meanshape_29(dbpath_pts,num_pts )

% fid = fopen(shapepathlistfile);
% shapepathlist = textscan(fid, '%s', 'delimiter', '\n');

% if isempty(shapepathlist)
%     error('no shape file found');
%     mean_shape = [];
%     return;
% end

% shape_header = loadshape(shapepathlist{1}{1});
% 
% if isempty(shape_header)
%     error('invalid shape file');
%     mean_shape = [];
%     return;
% end
imlist = dir([dbpath_pts '/' 'image*.*g']);
mean_shape = zeros(size(num_pts,1));

num_shapes = 0;
for i = 1:length(imlist)

    if num_pts ==29
        fname = [dbpath_pts '/' imlist(i).name(1:end-4) '_original.ljson'];
        pts = loadjson(fname);
        shape_i = double(fliplr(pts.landmarks.points));
    else 
        disp(['dataset name: ' dbname ' is invalid! It is not the shape of 68 pts or 19 pts']);
    end
    if isempty(shape_i)
        continue;
    end
    shape_min = min(shape_i, [], 1);
    shape_max = max(shape_i, [], 1);
    
    % translate to origin point
    shape_i = bsxfun(@minus, shape_i, shape_min);
    
    % resize shape
    shape_i = bsxfun(@rdivide, shape_i, shape_max - shape_min);
    
    mean_shape = mean_shape + shape_i;
    num_shapes = num_shapes + 1;
end

mean_shape = mean_shape ./ num_shapes;


img = 255 * ones(400, 400, 3);

drawshapes(img, 50 + 300 * mean_shape);

end

% function shape = loadshape(path)
% % function: load shape from pts file
% file = fopen(path);
% if file == -1
%     shape = [];
%     fclose(file);
%     return;
% end
% shape = textscan(file, '%d16 %d16', 'HeaderLines', 3, 'CollectOutput', 2);
% fclose(file);
% shape = shape{1};
% end