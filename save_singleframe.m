options = setup();
video_name = '505';
tracking_param = Online_Tracking_withUpdate_Setup(video_name);
video_path = [tracking_param.path tracking_param.video_name options.slash tracking_param.format];
save_singleframe_path = [ '.\paper_graph\'];
obj = VideoReader(video_path);
total_frames = obj.NumberOfFrames;
for i = 1:total_frames
    img_frame = ( read( obj , i ) );
    imwrite(img_frame,[save_singleframe_path '\505' num2str(i) '.jpg']); 

end