function learn_distribution_for_AllCascade(Data, options)

n_cascades                                = options.n_cascades;
rms                                       = zeros(n_cascades,1);
LearnedDistribution = cell(n_cascades,1);
if options.ifPCA_for_desc      == 1
    LearnedPCA_for_desc = cell(n_cascades,1);
end
%%%start to learn the distributions for all cascade BLS
for icascade = 1:n_cascades
    [Data,Distribution,PCAmapping, rms(icascade)] = learn_distribution_for_oneCascade(Data, options, icascade);
    if options.ifPCA_for_desc      == 1
        LearnedPCA_for_desc{icascade}.PCAmapping = PCAmapping;
    end
    
    LearnedDistribution{icascade}.distribution = Distribution;
    
end
save([options.modelPath options.slash options.datasetName ...
    'LearnedDistribution_offline.mat'],'LearnedDistribution');
if options.ifPCA_for_desc      == 1
    save([options.modelPath options.slash options.datasetName ...
        'LearnedPCA_for_desc.mat'],'LearnedPCA_for_desc');
end

end