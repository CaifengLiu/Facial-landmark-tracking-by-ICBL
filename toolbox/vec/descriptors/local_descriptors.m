function desc = local_descriptors(img, xy, options, stage)
featType = options.descType;
dsize = options.descScale(stage) * size(img,1);
dbins = options.descBins;
if strcmp(featType,'sift')
    %     i = randi([1 68],1,1);
%     rect = [xy(18,:) - [dsize/2 dsize/2] dsize dsize];
%     
%     if 1
%         figure(2); imshow(img); hold on;
%         rectangle('Position',  rect, 'EdgeColor', 'g');
%         hold off;
%         pause;
%     end
    
    
    if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
    else
        im = im2double(uint8(img));
    end
    
    xy = xy - repmat(dsize/2,size(xy,1),2);
    
    desc = xx_sift(im,xy,'nsb',dbins,'winsize',dsize);
    
elseif  strcmp(featType,'hog')
    if size(img,3) == 3
        im = im2double(rgb2gray(uint8(img)));
    else
        im = im2double(uint8(img));
    end
    
    npts = size(xy,1);
    
    parfor ipts = 1 : npts
        %disp(ipts);
        desc(ipts,:) = hog(im,xy(ipts,:),dsize);
    end
    
end

end