function Tracking_withoutUpdate()
tracking_param = TrackingSetup();
options = setup();
video_path = [tracking_param.path tracking_param.video_name options.slash tracking_param.format];
pts_path = [tracking_param.path tracking_param.video_name options.slash tracking_param.pts_file];
save_singleframe_path = [tracking_param.err_path '\video' tracking_param.video_name];
mkdir(save_singleframe_path);
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
incLearning = 0;
first = 1;
for i = 1:total_frames
    tic
    img_frame = ( read( obj , i ) );
    [shape] = pts68_annotation_load( [pts_path, pts_name(i).name] );
    [Data] = read_frame( img_frame,shape, options );
    tic
    [aligned_shape] = track_for_frame(Data,BLS_regressors,options);
    te = toc;
    aligned_shape = vec_2_shape(aligned_shape);
    shape_orig = shape2origimg(aligned_shape, Data{1}.bbox_original,Data{1}.width_orig,Data{1}.height_orig,options );
    err = rms_err( aligned_shape, Data{1}.shape_gt, options );    
    all_frame_err(i) = err; 
     
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
    drawnow;
    print(gcf,'-djpeg',[save_singleframe_path '\' num2str(i) '.jpg']);
end
mean_frame_err = mean(all_frame_err);
disp(mean_frame_err)
save([tracking_param.err_path options.slash tracking_param.video_name '_' ...
        num2str(mean_frame_err) 'withoutupdate' '.mat'], 'all_frame_err');
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
                'String', 'non-update', ...
                'Position',[ 100 100 100 20 ]);%10 10 100 20
%             'Callback',  @(src,evnt)change_String,
        else
            H = uicontrol('Style', 'PushButton', ...
                'String', 'non-update', ...
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
        display_err = num2str(err);
        display_err = display_err(1:5);
        set(S.err_h, 'string', sprintf('ERR: %s ',display_err));
        
      else       
        % create tracked points drawing
 %       S.pts_h   = plot(output.pred(:,1), output.pred(:,2), 'g*', 'markersize',2);
       S.pts_h   = plot(output.pred(:,1), output.pred(:,2), 'r.', 'markersize',7);

        
        % create frame/second drawing
%         S.time_h  = text(frame_w-200,100,sprintf('FPS: %d',uint8(1/te)),'fontsize',20,'color','m');
        display_err = num2str(err);
        display_err = display_err(1:5);
        S.err_h  = text(frame_w-260,40,sprintf('ERR: %s ',display_err),'fontsize',20,'color','r');
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
end
  