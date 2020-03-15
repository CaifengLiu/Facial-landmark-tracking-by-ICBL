function genData = data_genreation_for_MultiInitial(Data,DataVariation,options,first)
%%%%%%%%%%%%%%%%%%���ӳ�ʼ������������չoptions.augnumber ����%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%��ǰ����״�ͳ�ʼ��״�����ϵ��ת��?%%%%%%%%%%%%%%%%%%%%%%%%%
dbsize          = length(Data);
augnumber       = options.augnumber; 
M               = dbsize * augnumber;
genData         = cell(M,1);
if options.generate_initial==1 && first==1
    load([options.datasetName ...
    'Q.mat']);
else
    InitialShape = options.InitialShape;
end
h = 1;
for i = 1:dbsize  
%     indice_rotate = ceil(dbsize*rand(1, augnumber));
     indice_shift  = ceil(dbsize*rand(1, augnumber));
    scales        = 1 + 0.2*(rand([1 augnumber]) - 0.5);
    bbox_gt = getbbox(Data{i}.shape_gt);
    [rbbox] = random_init_position( ...
             bbox_gt, DataVariation, augnumber );

%%%%%initial
    if options.generate_initial==1&&first==1
         phy  = ExtractInitPhy(Data{i},options.initwinsize,options.cellsize);
         tmp_shape= regress( phy , Q );
         InitialShape = vec_2_shape(tmp_shape');
    end
    
    for sr = 1 : augnumber
        if sr == 1
          

            genData{(i-1)*augnumber+sr} = Data{i};
            %%sampling the bbox
%             idx    = rIdx(sr);%%shape_gt index
            cbbox  = rbbox(sr,:);
%             cbbox = genData{(i-1)*augnumber+sr}.bbox_gt;

            genData{(i-1)*augnumber+sr}.current_shape = resetshape(cbbox, InitialShape );
            if options.augnumber_rotate ~= 0
                genData{(i-1)*augnumber+sr}.current_shape = rotateshape(genData{(i-1)*augnumber+sr}.current_shape,options.angle_limit);
            end
            genData{(i-1)*augnumber+sr}.current_bbox = getbbox(genData{(i-1)*augnumber+sr}.current_shape);

            %%%%%%%%%%%%%%%%%%��ǰ����״�ͳ�ʼ��״�����ϵ��ת��?%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            genData{(i-1)*augnumber+sr}.initial_bbox = genData{(i-1)*augnumber+sr}.current_bbox;
            genData{(i-1)*augnumber+sr}.bbox_gt = bbox_gt;
            % calculate the residual shape from initial shape to groundtruth shape under normalization scale
            genData{(i-1)*augnumber+sr}.shape_residual = bsxfun(@rdivide, genData{(i-1)*augnumber+sr}.shape_gt - genData{(i-1)*augnumber+sr}.current_shape(:,:), [genData{(i-1)*augnumber+sr}.current_bbox(3) genData{(i-1)*augnumber+sr}.current_bbox(4)]); 
            genData{(i-1)*augnumber+sr}.shape_gt_for_distri = bsxfun(@rdivide, genData{(i-1)*augnumber+sr}.shape_gt, [genData{(i-1)*augnumber+sr}.current_bbox(3) genData{(i-1)*augnumber+sr}.current_bbox(4)]);
       
            

         
        else
           
            genData{(i-1)*augnumber+sr} = Data{i};
                        %%sampling the bbox
%             idx    = rIdx(sr);%%shape_gt index
            cbbox  = rbbox(sr,:);
%             cbbox = genData{(i-1)*augnumber+sr}.bbox_gt;

            shape = resetshape(cbbox, InitialShape); 
            
            if options.augnumber_scale ~= 0
               shape = scaleshape(shape, scales(sr));
            end   
            
            if options.augnumber_rotate ~= 0
                shape = rotateshape(shape,options.angle_limit);
            end
            
   
            if options.augnumber_shift ~= 0
                shape = translateshape(shape, Data{indice_shift(sr)}.shape_gt);
            end

            
            
            genData{(i-1)*augnumber+sr}.current_shape(:,:) = shape;
            genData{(i-1)*augnumber+sr}.current_bbox = getbbox(shape);
            genData{(i-1)*augnumber+sr}.bbox_gt = bbox_gt;
            
            
            genData{(i-1)*augnumber+sr}.initial_bbox = genData{(i-1)*augnumber+sr}.current_bbox;
            
            genData{(i-1)*augnumber+sr}.shape_residual = bsxfun(@rdivide, genData{(i-1)*augnumber+sr}.shape_gt - genData{(i-1)*augnumber+sr}.current_shape(:,:), [genData{(i-1)*augnumber+sr}.current_bbox(3) genData{(i-1)*augnumber+sr}.current_bbox(4)]);      
            genData{(i-1)*augnumber+sr}.shape_gt_for_distri = bsxfun(@rdivide, genData{(i-1)*augnumber+sr}.shape_gt, [genData{(i-1)*augnumber+sr}.current_bbox(3) genData{(i-1)*augnumber+sr}.current_bbox(4)]);
        end
        %%%%%%%%%%%%%%%%%%%testing the augmentation process
        if 0
            figure(1); imshow(genData{(i-1)*augnumber+sr}.img_gray); hold on;
            %Jregistered = imwarp(genData{(i-1)*augnumber+sr}.img_gray,genData{(i-1)*augnumber+sr}.meanshape2tf,'OutputView',imref2d(size(genData{(i-1)*augnumber+sr}.img_gray)));
            %imshow(Jregistered)%%%%%%%%%%%�����״�任���ͼ��
            draw_shape(meanshape_resize(:,1),...
            meanshape_resize(:,2),'y');
            draw_shape(genData{(i-1)*augnumber+sr}.current_shape(:,1),...
            genData{(i-1)*augnumber+sr}.current_shape(:,2),'r');
            hold off;
            pause;
        end
        if max(max(genData{(i-1)*augnumber+sr}.shape_residual))>2
            debug1(h) = (i-1)*augnumber+sr;
            h = h+1;
        end
        
    end

            
end

end