function Training_Model ()

 %% Load the Parameters
 options = setup ();
% parpool(3);

%%%%%%%%%%%%%%%%%%%Loading Data for LFPW29, HELEN68%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% imgDir = options.trainingImageDataPath;
% ptsDir = options.trainingTruthDataPath;
% disp('Loading training data...');
% Data = load_all_data_folder( imgDir, ptsDir, options );
%%Load or calculate the meanshape for the training process
% if options.meanshape_calculation == 1;
%     Meanshape = calc_meanshape_29(ptsDir,options.num_pts);
%     save('./initial_shape/Meanshape_29.mat','Meanshape');
% else
%     load('./initial_shape/Meanshape_29.mat');
% end

%%%%%%%%%%%%%%%%%%%Loading Data for 300w%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load G:/face_align_data/raw_300W_release.mat  nameList;
[nameList] = indexingData([1:3702],nameList);
root_path = options.root_path;
Data = load_all_data_flip_path( root_path, nameList,options );
%Load or calculate the meanshape for the training process
% if options.meanshape_calculation == 1;
%     Meanshape = calc_meanshape_68(root_path, nameList,options.num_pts);
%     save('./initial_shape/Meanshape_68.mat','Meanshape');
% else
%     load('./initial_shape/Meanshape_68.mat');
% end
%options.InitialShape = Meanshape;

%%%%%%%%%%%%%%%%%%%%%%Augmentation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if options.reginitial == 1
    Modeling_initial(Data, options,0.01);
end

if options.learningVariation == 1
    disp('Learning data variation...');
    do_learn_variation_w300( nameList,options );
end
load(['./model' options.slash options.datasetName ...
    '_DataVariation_offline.mat'], 'DataVariation');
load('./initial_shape/Meanshape_w300.mat');
options.InitialShape = vec_2_shape(Meanshape);
if options.flipflag == 1
    Data = data_flip(Data);
end
%%�����Ҫ�����ʼ��״�ĸ�����ʹ�ú��� Data = data_genreation_for_MultiInitial(Data,Meanshape, options);
disp('calculating the distribution...');
Data = data_genreation_for_MultiInitial(Data,DataVariation, options,0);

%%%Ԥѵ���Լ���deltX�ķֲ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if options.ifPretrain == 1
    learn_distribution_for_AllCascade(Data, options);
end

    
%%Start to train the BLS depending on the distribution%%%%%%%%%%%%%%%%%%%%%%%%
load([options.modelPath options.slash options.datasetName ...
    'LearnedDistribution_offline.mat'],'LearnedDistribution');

learn_all_BLSregressors( Data,LearnedDistribution ,options);


delete(gcp('nocreate'))


end