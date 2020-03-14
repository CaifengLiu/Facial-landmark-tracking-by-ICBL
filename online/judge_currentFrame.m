function judge_tag = judge_currentFrame(img, current_shape, Classifier,classifier_params)


PS = Classifier.PS;
svmModel = Classifier.svmModel; 

tmp = local_descriptors(img, current_shape, classifier_params, 3);
Testing_data = tmp(:)';
Testing_data = mapminmax('apply',Testing_data',PS);
Testing_data = Testing_data';
judge_tag = svmclassify(svmModel,Testing_data);
end