function phy  = ExtractInitPhy(Data,winsize,cellsize)
n = length(Data);

%%
if n>1
    tmp_box = getbbox(Data{1}.shape_gt);
    tmp_img = imcrop(Data{1}.img_gray,tmp_box);
    tmp_img = imresize(tmp_img,winsize);
    tmp_phy =vl_hog(single(tmp_img ), cellsize);
%     tmp_phy = anna_phog(tmp_img,8,360,4,[1;winsize(1);1;winsize(2)]);
    phy_length = length(tmp_phy(:));
    clear tmp_box;
    clear tmp_img;
    clear tmp_img;
%%
    phy  = zeros(n,phy_length);
    for idata = 1:n
        tmp_box = getbbox(Data{idata}.shape_gt);
        tmp_img = imresize(imcrop(Data{idata}.img_gray,tmp_box),winsize);
%     tmp_phy = anna_phog(tmp_img,8,360,4,[1;winsize(1);1;winsize(2)]);
        tmp_phy= vl_hog(single(tmp_img ), cellsize);
        phy(idata,:) = tmp_phy(:);
    end 
else
    tmp_box = getbbox(Data.shape_gt);
    tmp_img = imcrop(Data.img_gray,tmp_box);
    tmp_img = imresize(tmp_img,winsize);
    tmp_phy =vl_hog(single(tmp_img ), cellsize);
%     tmp_phy = anna_phog(tmp_img,8,360,4,[1;winsize(1);1;winsize(2)]);
    phy(1,:) = tmp_phy(:);
end
end