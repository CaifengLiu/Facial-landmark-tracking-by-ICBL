function new_distribution = update_distribution(distribution, new_samples)
num_old_samples = distribution.currentnum;
num_attribute = size(new_samples,2);
num_new_samples = size(new_samples,1);
[Miu_New, Sigma_New]        = mean_covariance_of_data (new_samples);
Miu_Old = distribution.Miu;
Sigma_Old = distribution.Sigma;

Miu_update = (num_old_samples.*Miu_Old + sum(new_samples,1))./(num_old_samples+num_new_samples);
Sigma_update = size(num_attribute,num_attribute);
for i = 1:num_attribute
    for j = 1:num_attribute
        Sigma_update(i,j) = num_new_samples*Miu_New(i)*Miu_New(j)+ num_old_samples*Miu_Old(i)*Miu_Old(j)+(num_old_samples+num_new_samples)*Miu_update(i)*Miu_update(j)...
                       - Miu_update(i)*(num_old_samples*Miu_Old(j)+num_new_samples*Miu_New(j)) - Miu_update(j)*(num_old_samples*Miu_Old(i)...
                       +num_new_samples*Miu_New(i))+num_old_samples*Sigma_Old(i,j)+num_new_samples*Sigma_New(i,j);
    end
end
% Sigma_update = Sigma_update + num_old_samples.* Sigma_Old + num_new_samples.*Sigma_New;
Sigma_update = Sigma_update./(num_new_samples+num_old_samples);
Sigma_update = (Sigma_update + Sigma_update.') / 2;
new_distribution.currentnum = num_old_samples+num_old_samples;
new_distribution.Miu = Miu_update;
new_distribution.Sigma = Sigma_update;
new_distribution.mean_wh = distribution.mean_wh;
clear distribution;

end