function shape_orig = shape2origimg(shape, orig_bbox,width_orig,height_orig,options )

sr = width_orig/options.canvasSize(1);
sc = height_orig/options.canvasSize(2);
shape_orig = bsxfun(@times, shape, [sr sc]); 
shape_orig = bsxfun(@plus, shape_orig,...
    double([orig_bbox(1) orig_bbox(2)]));
end