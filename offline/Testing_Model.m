function err = Testing_Model(options)

% options = setup();
options.angle_limit = 60;
options.augnumber=1;
%%%%%Loading the testing Data%%%%%%%%%%%%%%%%%%%
% imgDir = options.testingImageDataPath;
% ptsDir = options.testingTruthDataPath;
% disp('Loading testing data...');
% Data = load_data_folder_for_testing( imgDir, ptsDir, options );
% load('./initial_shape/Meanshape_29.mat');
% options.InitialShape = vec_2_shape(Meanshape);

%%%%%%%%%%%%%%%%%%%Loading Data for 300w%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load /share/Caifeng/data/raw_300W_release.mat  nameList;
[nameList] = indexingData([3149:3702],nameList);
%%%3149-3702 common  3703-3837 challange
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Loading the Models%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([options.modelPath options.slash options.datasetName ...
    'BLS_regressors.mat'],'BLS_regressors');
load(['./model' options.slash options.datasetName ...
    '_DataVariation.mat'], 'DataVariation');
load('./initial_shape/Meanshape_w300.mat');
options.InitialShape = vec_2_shape(Meanshape);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ndata = length(Data);
err = zeros(ndata,1);
model = BLS_regressors;
%%generation
Data = data_genreation_for_MultiInitial(Data, DataVariation,options,0);
augnumber = options.augnumber;
parfor idata = 1:ndata

    disp(['Image: ' num2str(idata)]);
    true_shape =  Data{(idata-1)*augnumber+1}.shape_gt;
    tmpdata = cell(augnumber,1);
    tmpdata(1:augnumber) = Data((idata-1)*augnumber+1:(idata-1)*augnumber+augnumber);
    aligned_shape = face_alignment_for_idata( tmpdata,...
                model, options);
    err(idata) = rms_err( aligned_shape, true_shape, options );
    display(num2str(err(idata)));
    %%display
        if 0
            figure(1); imshow(Data{(idata-1)*augnumber+1}.img_gray); hold on;
            draw_shape(true_shape(:,1), true_shape(:,2),'r');
            draw_shape(aligned_shape(:,1), aligned_shape(:,2),'g');
            hold off;
            pause;
        end
end
output_err = mean(err);
 err_4k=err;
% err_4k_agnumber15 = err;
save('err_4k.mat','err_4k')
% save('err_4k_agnumber15.mat','err_4k_agnumber15')
disp(num2str(mean(err)));

end