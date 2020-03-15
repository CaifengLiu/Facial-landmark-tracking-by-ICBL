singleframes_path = '.\Tracking_by_online_model_C1\video126';
out = VideoWriter([singleframes_path '.avi']);
out.FrameRate = 25;
open(out);
all_frames = 1300;
for i = 1:all_frames

frame = imread(strcat(singleframes_path,'\',num2str(i),'.jpg'));
writeVideo(out,frame);

end
close(out);