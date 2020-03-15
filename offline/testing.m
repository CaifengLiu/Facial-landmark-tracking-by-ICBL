function testing()
 initial_folder = ['results/' num2str(0) ];
i = 1;
t = 200;
test_N3 = 1000;
%%%%cascade 1
for test_N1 = 35:5:50
    for test_N2 = 30:5:50
        mkdir(initial_folder);
        options = setup ();
        model_folder = [initial_folder '/' options.modelPath];
        mkdir(model_folder);
        options.modelPath = model_folder;
        options.N11 = [test_N1 test_N1 test_N1 test_N1];
        options.N2  = [test_N2 test_N2 test_N2 test_N2];
        options.N33 = [test_N3 test_N3 test_N3 test_N3];
        options.modelPath = model_folder;
        Training_Model(options);
        err = Testing_Model(options);
        save([initial_folder '/' 'err.mat'],'err');
        %saving the results
        save([initial_folder '/' 'options.mat'],'options');
        new_foldername = ['results/' num2str(t) num2str(mean(err))];
        movefile(initial_folder, new_foldername);
        i = i+1;
        t = t+1;
    end
end
%






% [~,ind] = min(information(:,1));
% N1_1_sure = information(ind,2);
% N2_1_sure = information(ind,3);
% N1_1_sure = 10;
% N2_1_sure = 20;
% i  = 54;
% %%%cascade 2
% for test_N1_2 = 5:5:30
%     for test_N2_2 = 10:5:50
%         mkdir(initial_folder);
%         options = setup ();
%         model_folder = [initial_folder options.modelPath];
%         mkdir(model_folder);
%         options.modelPath = model_folder;
%         options.N11(1) = N1_1_sure;
%         options.N2(1)  = N2_1_sure;
%         options.N11(2) = test_N1_2;
%         options.N2(2)  = test_N2_2;
%         options.modelPath = model_folder;
%         Training_Model(options);
%         err = Testing_Model(options);
%         %%saving the results
%         information2(i,1) = err;
%         information2(i,2) = test_N1_2;
%         information2(i,3) = test_N2_2;
%         save([initial_folder '/' 'options.mat'],'options');
% %         err_str = vpa(err,3);
%         new_foldername = ['results/' num2str(i) num2str(err)];
%         movefile(initial_folder, new_foldername);
%         i = i+1;
%     end
% end
% [~,ind] = min(information2(:,1));
% N1_2_sure = information2(ind,2);
% N2_2_sure = information2(ind,3);

%%%%%%%%%%%%%%%%%%%%cascade 3
% i = 108;
% N1_2_sure = 30;
% N2_2_sure = 20;
% for test_N1_3 = 5:5:50
%     for test_N2_3 = 5:5:50
%         mkdir(initial_folder);
%         options = setup ();
%         model_folder = [initial_folder options.modelPath];
%         mkdir(model_folder);
%         options.modelPath = model_folder;
%         options.N11(1) = N1_1_sure;
%         options.N2(1)  = N2_1_sure;
%         options.N11(2) = N1_2_sure;
%         options.N2(2)  = N2_2_sure;
%         options.N11(3) = test_N1_3;
%         options.N2(3)  = test_N2_3;        
%         options.modelPath = model_folder;
%         Training_Model(options);
%         err = Testing_Model(options);
%         %%saving the results
%         information3(i,1) = err;
%         information3(i,2) = test_N1_3;
%         information3(i,3) = test_N2_3;
%         save([initial_folder '/' 'options.mat'],'options');
% %         err_str = vpa(err,3);
%         new_foldername = ['results/' num2str(i) num2str(err)];
%         movefile(initial_folder, new_foldername);
%         i = i+1;
%     end
% end

% [~,ind] = min(information3(:,1));
% N1_3_sure = information3(ind,2);
% N2_3_sure = information3(ind,3);

% N1_3_sure = 10;
% N2_3_sure = 45;
% i = 300;
% for test_N3 = 200:200:2000
%     mkdir(initial_folder);
%     options = setup ();
%     model_folder = [initial_folder options.modelPath];
%     mkdir(model_folder);
%     options.N11(1) = N1_1_sure;
%     options.N2(1)  = N2_1_sure;
%     options.N11(2) = N1_2_sure;
%     options.N2(2)  = N2_2_sure;
%     options.N11(3) = N1_3_sure;
%     options.N2(3)  = N2_3_sure; 
%     options.N33     = [test_N3 test_N3 test_N3 test_N3];
%     options.modelPath = model_folder;
%     Training_Model(options);
%     err = Testing_Model(options);
%     %%saving the results
%     save([initial_folder '/' 'options.mat'],'options');
% %     err_str = vpa(err,3);
%     new_foldername = ['results/' num2str(i) num2str(err)];
%     movefile(initial_folder, new_foldername);
%     i = i+1;
% end


end