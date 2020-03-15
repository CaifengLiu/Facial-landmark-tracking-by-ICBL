function Modeling_initial(Data, options,lamda)

    [extract_shape] = Extract_Shape(Data,options);
    phy  = ExtractInitPhy(Data,options.initwinsize,options.cellsize);
    Q =linreg_initial(phy,extract_shape,lamda); 
    save(['./initial_shape/' options.datasetName ...
    'Q.mat'], 'Q');
end