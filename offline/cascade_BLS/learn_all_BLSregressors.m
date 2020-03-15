function learn_all_BLSregressors( Data,LearnedDistribution ,options)

n_cascades                    = options.n_cascades;
rms                           = zeros(n_cascades,1);
BLS_regressors{n_cascades}.R   = [];


%%%start to learn the BLSregressors depending on the deltX distributions 
for icascade = 1:n_cascades
    [R, rms(icascade)] = learn_one_BLSregressor_version2(Data,LearnedDistribution{icascade}.distribution, options,icascade);
    BLS_regressors{icascade}.R = R;


end

save([options.modelPath options.slash options.datasetName ...
    'BLS_regressors_offline.mat'],'BLS_regressors');

end