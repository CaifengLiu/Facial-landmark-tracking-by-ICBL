function [ error_per_image ] = compute_scale_error( detected_points ,ground_truth_points)
%compute_error
%   compute the average point-to-point Euclidean error normalized by the
%   diag bounding box distance (measured as the Euclidean distance between the
%   outer corners of the eyes)
%
%   Inputs:
%          grounth_truth_all, size: num_of_points x 2 x num_of_images
%          detected_points_all, size: num_of_points x 2 x num_of_images
%   Output:
%          error_per_image, size: num_of_images x 1
    num_of_points = 68;

    diag_distance = sqrt((min(ground_truth_points(:,1)) - max(ground_truth_points(:,1)))* (min(ground_truth_points(:,2)) - max(ground_truth_points(:,2))));

    sum=0;
    for j=1:num_of_points
        sum = sum+norm(detected_points(j,:)-ground_truth_points(j,:));
    end
    error_per_image = sum/(num_of_points*diag_distance);


end

