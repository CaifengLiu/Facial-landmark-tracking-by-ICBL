function mean_frame_err = Online_Tracking_withUpdate(tracking_param,error_frame_ind)



% if ~isempty(gcp('nocreate'))
%     parpool(3); %若尚未启动，则启动并行环境
% end



%tracking_param = Tracking_withUpdate_Setup();
options = setup();
video_path = [tracking_param.path tracking_param.video_name options.slash tracking_param.format];
pts_path = [tracking_param.path tracking_param.video_name options.slash tracking_param.pts_file];
%%%%%% save single frame %%%%%
% save_singleframe_path = [tracking_param.err_path '\video' tracking_param.video_name];
% 
% mkdir(save_singleframe_path);
pts_name = dir([pts_path,'*.pts']);
obj = VideoReader(video_path);
total_frames = obj.NumberOfFrames;
global err;
err = 0;
%%%Model repairation
load(['offline/' options.modelPath options.slash options.datasetName ...
    'BLS_regressors_offline.mat'],'BLS_regressors');
load(['offline/' options.modelPath options.slash options.datasetName ...
    '_DataVariation_offline.mat'], 'DataVariation');
load(['offline/' options.modelPath options.slash options.datasetName ...
    'LearnedDistribution_offline.mat'],'LearnedDistribution');
load('.\offline\initial_shape\Meanshape_w300.mat', 'Meanshape');
load (tracking_param.classifier_path, 'Classifier');

all_frame_err = zeros(total_frames,1);
all_frame_diag_err = zeros(total_frames,1);
all_frame_scale_err = zeros(total_frames,1);
incLearning = 0;
first = 1;
newsamples_for_update = cell(tracking_param.frame_interval,1);
ind = 0;
online=tracking_param.online;
options.ifUpdateDistribution = tracking_param.ifUpdateDistribution;
if tracking_param.ifUpdateDistribution==1
storage_new_deltshape = zeros(tracking_param.frame_interval,2*options.num_pts*options.n_cascades); 
end
for i = 1:total_frames
    if ~isempty(error_frame_ind) && ismember(i,error_frame_ind )        
        continue;

    end
    img_frame = ( read( obj , i ) );
    
    [shape] = pts68_annotation_load( [pts_path, pts_name(i).name] );
    [Data] = read_frame( img_frame,shape, options );
    Data = data_processing(Data,Meanshape);
%     tic
    [aligned_shape,new_deltshape] = track_for_frame(Data,BLS_regressors,LearnedDistribution,options);%%bug
%     te = toc;
    aligned_shape = vec_2_shape(aligned_shape);
    shape_orig = shape2origimg(aligned_shape, Data{1}.bbox_original,Data{1}.width_orig,Data{1}.height_orig,options );
    err = rms_err( aligned_shape, Data{1}.shape_gt, options );    
    all_frame_err(i) = err; 
    all_frame_diag_err(i) = compute_diag_error(aligned_shape, Data{1}.shape_gt);
    all_frame_scale_err(i) = compute_scale_error(aligned_shape, Data{1}.shape_gt);
    %%%judge whether the current sample needs to be updated
    if online==1
        judge_tag = judge_currentFrame(Data{1}.img_gray, aligned_shape, Classifier,options);
        if judge_tag==1
            ind = ind+1;
            newsamples_for_update{ind} = Data{1};
            newsamples_for_update{ind}.shape_gt = aligned_shape;
            storage_new_deltshape(ind,:) = new_deltshape;
        end
    end

    if ind == tracking_param.frame_interval && online ==1
        if tracking_param.ifUpdateDistribution == 1
            

            [ BLS_regressors,LearnedDistribution]=Incremental_learn_all_BLSregressors( newsamples_for_update, LearnedDistribution,BLS_regressors,...
                                           storage_new_deltshape, options);
            
            
        else
            [ BLS_regressors, ~]=Incremental_learn_all_BLSregressors( newsamples_for_update, LearnedDistribution,BLS_regressors,...
                               storage_new_deltshape, options);
            

        end
        ind = 0;
%         tracking_param.frame_interval=20;
    end
     
%%%%%%%%%%%%%%%%%%%%%%display%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    output.pred = shape_orig;
   
    if tracking_param.show && first
        first = false;
        frame_w = size(img_frame,2);
        draw_figure( size(img_frame,2) , size( img_frame, 1 ) );
        set(S.im_h,'cdata',img_frame);
       % drawow;
    end
    if tracking_param.show
        set(S.im_h,'cdata',img_frame);
        if isempty(output.pred) % if lost/no face, delete all drawings
            if drawed, delete_handlers(); end
        else % else update all drawings
            update_GUI();
        end
    end
%     drawnow;
%     print(gcf,'-djpeg',[save_singleframe_path '\' num2str(i) '.jpg']);
end
if  ~isempty(error_frame_ind)
    all_frame_err(error_frame_ind(:)) = [];
    all_frame_diag_err(error_frame_ind(:)) = [];
    all_frame_scale_err(error_frame_ind(:)) = [];
end
mean_frame_err = mean(all_frame_err);
mean_frame_diag_err = mean(all_frame_diag_err);
mean_frame_scale_err = mean(all_frame_scale_err);
disp(mean_frame_err)
% if online ==1
%     if tracking_param.ifUpdateDistribution == 1
%         save(['online/model' options.slash options.datasetName tracking_param.video_name...
%         'BLS_regressors_online_upD.mat'],'BLS_regressors');
%         save(['online/model'  options.slash options.datasetName tracking_param.video_name...
%         'LearnedDistribution_online_upD.mat'],'LearnedDistribution');
%         
%     else
%         save(['online/' options.modelPath options.slash options.datasetName tracking_param.video_name...
%                 'BLS_regressors_online_non_upD.mat'],'BLS_regressors');
%     end
% end

save([tracking_param.err_path options.slash tracking_param.video_name '_IOD_' ...
        num2str(mean_frame_err) num2str(online) '.mat'], 'all_frame_err');
save([tracking_param.diag_err_path options.slash tracking_param.video_name '_diag_' ...
        num2str(mean_frame_diag_err) num2str(online) '.mat'], 'all_frame_diag_err');    
save([tracking_param.scale_err_path options.slash tracking_param.video_name '_scale_' ...
        num2str(mean_frame_scale_err) num2str(online) '.mat'], 'all_frame_scale_err');    
% movefile save_singleframe_path [save_singleframe_path num2str(mean_frame_err)]    
%define the handle function
    
     function draw_figure( frame_w , frame_h )
               
        
        % 500 -50
        S.fh = figure('units','pixels',...
            'position',[500 50 frame_w frame_h],...
            'menubar','none',...
            'name','CONTINUOUS REGRESSION',...
            'numbertitle','off',...
            'resize','off',...
            'renderer','painters');
        
        % create axes
        S.ax = axes('units','pixels',...
            'position',[1 1 frame_w frame_h],...
            'drawmode','fast');
        
        drawed = false; % nor draw anything yet
        %output.pred = [];    % prediction set to null enabling detection
        S.im_h = imshow(zeros(1*frame_h,1*frame_w,3,'uint8'));
        hold on;
        if incLearning
            H = uicontrol('Style', 'PushButton', ...
                'String', 'Online', ...
                'Position',[ 100 100 100 20 ]);%10 10 100 20
%             'Callback',  @(src,evnt)change_String,
        else
            H = uicontrol('Style', 'PushButton', ...
                'String', 'Online', ...
                'Position',[ 100 100 100 20 ]);
        end;
        
        
  
        
        
    end
    function delete_handlers() 
      delete(S.pts_h); delete(S.time_h);
      %delete(S.hh{1}); delete(S.hh{2}); delete(S.hh{3});
      drawed = false;
    end
    function update_GUI()
    
      if drawed % faster to update than to creat new drawings
        
        set(S.pts_h, 'xdata', output.pred(:,1), 'ydata',output.pred(:,2));
        % update frame/second
%         set(S.time_h, 'string', sprintf('FPS: %d ',uint8(1/te)));
%         display_err = num2str(err);
%         display_err = display_err(1:5);
        set(S.err_h, 'string', sprintf('ERR: %0.3g ',err));
        
      else       
        % create tracked points drawing
 %       S.pts_h   = plot(output.pred(:,1), output.pred(:,2), 'g*', 'markersize',2);
       S.pts_h   = plot(output.pred(:,1), output.pred(:,2), 'r.', 'markersize',7);

        
        % create frame/second drawing
%         S.time_h  = text(frame_w-200,100,sprintf('FPS: %d',uint8(1/te)),'fontsize',20,'color','m');
%         display_err = num2str(err);
%         display_err = display_err(1:5);
        S.err_h  = text(frame_w-260,40,sprintf('ERR: %0.3g ',err),'fontsize',20,'color','r');
        drawed = true;
      end
    end
%     function change_String()
%         StrVal = get(H,'String');
%         if strcmp( StrVal, 'Activate IL')
%             set(H,'String','Deactivate IL');
%         else
%             set(H,'String','Activate IL');
%         end;
%         
%         incLearning = not(incLearning);
%     end
 delete(gcp('nocreate'))
 close;
end

