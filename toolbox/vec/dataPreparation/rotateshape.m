function shape_rotated = rotateshape(shape,angle_limit)
%ROTATESHAPE Summary of this function goes here
%   Rotate input shape randomly
%   Detailed explanation goes here
%   Input:
%       shape: original shape
%   Output:
%       shape_rotated: rotated shape

anti_clockwise_angle = angle_limit*rand(1);%%original 120
%shape_rotated = rotatepoints(shape,mean(shape),anti_clockwise_angle - 60, 1);
shape_rotated = rotatepoints(shape,mean(shape),anti_clockwise_angle - angle_limit/2, 1);

end

