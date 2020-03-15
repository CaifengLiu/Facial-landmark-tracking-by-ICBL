function del_shape = generate_delt_shape(distribution, GMMtag)

if GMMtag == 1
    del_shape = random(distribution.GMMparameters,1);
else    
    
    del_shape = mvnrnd(distribution.Miu, distribution.Sigma, 1);
end

end