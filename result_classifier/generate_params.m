function classifier_params = generate_params()

classifier_params.datasetName = 'w300';  %% 'lfpw', 'helen' or 'w300'
classifier_params.num_pts = 68;             %% 'lfpw_29' should be 29,w300 'lfpw', 'helen'shoud be 68
classifier_params.root_path  =   'G:/face_align_data';  
classifier_params.slash      = '/'; %% For linux
classifier_params.generate_initial=0;
classifier_params.Classifier_Path  = './classifier';
classifier_params.flipflag = 0;
classifier_params.datageneration = 0;
classifier_params.augnumber = 5;
classifier_params.augnumber_scale = 1;
classifier_params.augnumber_rotate = 1;
classifier_params.augnumber_shift = 1;
classifier_params.angle_limit = 60;
classifier_params.Aug_BoxScale = 2.0; %%%%%set a scale for tailoring a face area in original image.
classifier_params.canvasSize  = [400 400];
classifier_params.descType  = 'sift';%%'sift'or 'hog'
classifier_params.descScale = [0.16,0.12,0.08,0.06];
classifier_params.descBins  =  4;
end