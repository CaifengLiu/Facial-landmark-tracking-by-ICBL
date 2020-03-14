function [aligned_shape,storage_cascade_output] = track_for_frame(Data,model,LearnedDistribution,options)

%%generation


[tmp ,storage_cascade_output] = cascaded_BLSregress(Data{1}, model,LearnedDistribution, options);
aligned_shape = shape_2_vec(tmp);
%%display
    if 0
        figure(1); imshow(Data{(idata-1)*augnumber+1}.img_gray); hold on;
        draw_shape(true_shape(:,1), true_shape(:,2),'r');
        draw_shape(aligned_shape(:,1), aligned_shape(:,2),'g');
        hold off;
        pause;
    end


end