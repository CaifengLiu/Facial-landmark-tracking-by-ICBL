function shape = face_alignment_for_idata(Data,BLS_regressors,options)
augnumber    = options.augnumber;
num_pts      = options.num_pts;
aligned_shape = zeros(augnumber,2*num_pts );

parfor ir = 1:augnumber

tmp  = cascaded_BLSregress(Data{ir}, BLS_regressors, options);
aligned_shape(ir,:) = shape_2_vec(tmp);


end
if augnumber == 1
    shape = vec_2_shape(aligned_shape(1,:)');
else
    shape = vec_2_shape(mean(aligned_shape)');
end

end