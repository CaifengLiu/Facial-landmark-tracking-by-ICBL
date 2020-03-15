function Data = data_flip(Data)

    Data_flip = cell(size(Data, 1), 1);
    for i = 1:length(Data_flip)
        if size(Data{i}.img_gray,3) > 1
            Data_flip{i}.img_gray  = fliplr(rgb2gray(uint8(Data{i}.img_gray)));
        else
            Data_flip{i}.img_gray  = fliplr(Data{i}.img_gray);
        end
        Data_flip{i}.width_orig  = Data{i}.width_orig;
        Data_flip{i}.height_orig = Data{i}.height_orig; 
        Data_flip{i}.width       = Data{i}.width;
        Data_flip{i}.height      = Data{i}.height;
 
        Data_flip{i}.shape_gt    = flipshape(Data{i}.shape_gt);        
        Data_flip{i}.shape_gt(:,1) = size(Data_flip{i}.img_gray,2) - Data_flip{i}.shape_gt(:, 1);
        
        Data_flip{i}.bbox_gt = getbbox(Data_flip{i}.shape_gt);
        
        Data_flip{i}.bbox_facedet        = Data{i}.bbox_facedet;
        Data_flip{i}.bbox_facedet(1)     = Data_flip{i}.width - Data_flip{i}.bbox_facedet(1) - Data_flip{i}.bbox_facedet(3); 
        
        if 0
            figure(1); imshow(Data_flip{i}.img_gray); hold on;
            draw_shape(Data_flip{i}.shape_gt(:,1),...
                Data_flip{i}.shape_gt(:,2),'r');
            hold off;
            pause;
            imshow(Data{i}.img_gray); hold on;
            draw_shape(Data{i}.shape_gt(:,1),...
                Data{i}.shape_gt(:,2),'r');
            hold off;
            pause;
        end 
    end
    Data = [Data; Data_flip];
    clear Data_flip;


end