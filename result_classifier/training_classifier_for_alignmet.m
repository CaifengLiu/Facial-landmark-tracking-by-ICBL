function training_classifier_for_alignmet()


classifier_params = generate_params();
load G:/face_align_data/raw_300W_release.mat  nameList;
[nameList] = indexingData([1:3837],nameList);
root_path = classifier_params.root_path;
Data = load_all_data_flip_path( root_path, nameList,classifier_params );
load(['../offline/model' classifier_params.slash classifier_params.datasetName ...
    '_DataVariation_offline.mat'], 'DataVariation');
load('../offline/initial_shape/Meanshape_w300.mat');
classifier_params.InitialShape = vec_2_shape(Meanshape);


Data = data_genreation_for_MultiInitial(Data,DataVariation, classifier_params,0);
nData = length(Data);
Truelabel = zeros(nData,1)+1;
Falselabel = zeros(nData,1);
n_points          = size(Data{1}.shape_gt,1);
%%%extract features for positive and negative smaples
if strcmp(classifier_params.descType,'sift') == 1
    desc_dim      = 128;

elseif strcmp(classifier_params.descType,'hog') == 1
    desc_dim      = 124;
end

storage_positive_desc = zeros(nData, desc_dim*n_points );
storage_negative_desc = zeros(nData, desc_dim*n_points );

parfor idata = 1 : nData

    current_shape               = Data{idata}.current_shape;
    shape_gt                    = Data{idata}.shape_gt;
    img = Data{idata}.img_gray;
    tmp = local_descriptors(img, current_shape, classifier_params, 3);
    storage_negative_desc(idata, :) = tmp(:);
    tmp_true = local_descriptors(img, shape_gt, classifier_params, 3);
    storage_positive_desc(idata, :) = tmp_true(:);      
end
storage_desc = [storage_positive_desc;storage_negative_desc];
storage_label = [Truelabel;Falselabel];
ntest = 1000;
ind = randperm(2*nData);
Testing_data = storage_desc(ind(1:ntest),:);
Testing_label = storage_label(ind(1:ntest),:);
Training_data = storage_desc(ind(ntest+1:end),:);
Training_label = storage_label(ind(ntest+1:end),:);
clear storage_positive_desc;
clear storage_positive_desc;
clear storage_desc;
clear storage_label;

%πÈ“ªªØ
[Training_data ,PS] = mapminmax(Training_data');
Training_data  = Training_data';
Testing_data = mapminmax('apply',Testing_data',PS);
Testing_data = Testing_data';

svmModel = svmtrain(Training_data,Training_label,'kernel_function','linear','showplot',true);

classification=svmclassify(svmModel,Testing_data,'Showplot',true);
sum(Testing_label==classification)

Classifier.PS = PS;
Classifier.svmModel = svmModel;

save([classifier_params.Classifier_Path classifier_params.slash classifier_params.datasetName ...
    'Classifier.mat'], 'Classifier');
end