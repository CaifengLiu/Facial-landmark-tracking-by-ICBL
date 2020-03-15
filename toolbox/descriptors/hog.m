function desc = hog( im, pos , lmsize)

%fsize  = sqrt(norm_size);
%lmsize  = fsize;
%gsize = options.canvasSize(1) * options.descScale(1);

rect =  [pos(1) - (lmsize-1)/2, ...
         pos(2) - (lmsize-1)/2, ...
         lmsize - 1, lmsize - 1];
     
rect(1) = max(0,rect(1));
rect(1) = min(size(im,2),rect(1));
rect(2) = max(0,rect(2));
rect(2) = min(size(im,1),rect(2));
rect(3) = min(rect(3),size(im,2)-rect(1));
rect(3) = max(rect(3),0);
rect(4) = min(rect(4),size(im,1)-rect(2));   
rect(4) = max(rect(4),0);
if rect(3)==0||rect(3)<0.3*lmsize
    rect(1) = rect(1)-(lmsize-1)/2;
    rect(3) = (lmsize-1)/2-1;
end
if rect(4)==0||rect(4)<0.3*lmsize
    rect(2) = rect(2)-(lmsize-1)/2;
    rect(4) = (lmsize-1)/2-1;
end
if 0
   figure(1); imshow(im);hold on;
   %draw_shape(pos(:,1),pos(:,2),'g');
   draw_rect(rect);
   hold off;
   pause;
end

cropim = imcrop(im,rect);

%disp([size(cropim) lmsize]);

    
if size(cropim,1) ~= lmsize || size(cropim,2) ~= lmsize
     cropim = imresize(cropim,[lmsize lmsize]);
end

cellSize = 32 ;
%tmp = vl_hog(single(cropim), cellSize, 'verbose');
tmp = vl_hog(single(cropim), cellSize);

if 0
   figure(2); imshow(tmp);
   pause;
end

%desc = feat_normalize(tmp(:));
desc = tmp(:);
end
