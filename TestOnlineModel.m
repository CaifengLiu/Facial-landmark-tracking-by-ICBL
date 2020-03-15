%%%此函数为计算offline模型的tracking结果for category 1 2 3
function TestOnlineModel()

%     parpool(4); %若尚未启动，则启动并行环境

catagory_one_including ={ '114'};%'114', '124', '125', '126', 
catagory_one_err ={'401'};% '125', '126', '150', '158', '505', '506', '507', '509', '510', 
% catagory_one_including ={'511', '514', '515',...
%                            '519', '520', '521', '522', '524', '525', '537', '538', '541', '546','401', '402', '508','518', '540', '547', '548'};%'114', '124', '125', '126', 
% catagory_one_err ={'401', '402', '508','518', '540', '547', '548'};
%'203', '208',
% catagory_one_including ={  '211', '212', '213', '214', '218', '224', '403', '404', '405', '406', '407',...
%                              '408', '409', '412', '550','551','553'};%'114', '124', '125', '126', 
% catagory_one_err ={ '551','553'};
% 
% catagory_one_including ={ '410', '411', '516', '517', '526', '528', '529', '530', '531', '533', '557', '558', '559', '562'};%
% catagory_one_err ={  '410', '411', '529', '530', '531', '533', '557'};
error_load = [];
video_num = length(catagory_one_including) ;
for i = 1:video_num
tracking_param = Online_Tracking_withUpdate_Setup(cell2mat(catagory_one_including(i)));



if ismember(catagory_one_including(i), catagory_one_err);
    err_path =  [tracking_param.path tracking_param.video_name '.mat'];
    load(err_path,'error');
    error_load = error;
end
current_video_err=Online_Tracking_withUpdate(tracking_param,error_load);
err_by_online_for_catagory(i) = current_video_err;
error_load = [];
end
mean(err_by_online_for_catagory)
save([tracking_param.err_path '\' 'category1_onlineModel_err_part.mat'], 'err_by_online_for_catagory');%%数据集中有一部分视频的标签有误，
%%%%故无误的为part1，有误的为part2,分别计算。

end
                       
                       