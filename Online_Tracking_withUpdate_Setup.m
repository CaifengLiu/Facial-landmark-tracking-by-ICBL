function tracking_param = Online_Tracking_withUpdate_Setup(video_name)

tracking_param.path = 'G:\traking_dataset\300VW\300VW_Dataset_2015_12_14\';
tracking_param.classifier_path = '.\result_classifier\classifier\w300Classifier.mat';
tracking_param.video_name = video_name;%%'003';
tracking_param.format = 'vid.avi';
tracking_param.pts_file = 'annot\';
tracking_param.show = 0;
tracking_param.err_path = 'G:\博三下半年\CascadeBLS\Cascade_BLS_results\300VW\C1\online_model_10_40_800';
tracking_param.diag_err_path = 'G:\博三下半年\CascadeBLS\Cascade_BLS_results\300VW\C1\online_model_10_40_800\diag_err'; 
tracking_param.scale_err_path = 'G:\博三下半年\CascadeBLS\Cascade_BLS_results\300VW\C1\online_model_10_40_800\scale_err'; % '.\Tracking_results';
tracking_param.frame_interval = 2;
tracking_param.ifUpdateDistribution = 1;
tracking_param.online = 1;

end