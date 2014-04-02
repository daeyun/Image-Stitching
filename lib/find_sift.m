function sift_arr = find_sift(I, circles, enlarge_factor)
%%
%% Compute non-rotation-invariant SIFT descriptors of a set of circles 
%% I is the image
%% circles is an Nx3 array where N is the number of circles, where the
%%    first column is the x-coordinate, the second column is the y-coordinate,
%%    and the third column is the radius
%% enlarge_factor is by how much to enarge the radius of the circle before
%%    computing the descriptor (a factor of 1.5 or larger is usually necessary
%%    for best performance)
%% The output is an Nx128 array of SIFT descriptors
%%
%% Note that this code is not rotation-invariant, i.e., it does not attempt 
%% to normalize the patches by rotating them so that the horizontal direction 
%% is aligned with the dominant gradient orientation of the patch. 
%%
%% (c) Lana Lazebnik
%%

if ndims(I) == 3
    I = im2double(rgb2gray(I));
else
    I = im2double(I);
end


fprintf('Running find_sift\n');

% parameters (default SIFT size)
num_angles = 8;
num_bins = 4;
num_samples = num_bins * num_bins;
alpha = 9; % smoothing for orientation histogram

if nargin < 3
    enlarge_factor = 1.5;
end

angle_step = 2 * pi / num_angles;
angles = 0:angle_step:2*pi;
angles(num_angles+1) = []; % bin centers

[hgt wid] = size(I);
num_pts = size(circles,1);

sift_arr = zeros(num_pts, num_samples * num_angles);

% edge image
sigma_edge = 1;


[G_X,G_Y]=gen_dgauss(sigma_edge);
I_X = filter2(G_X, I, 'same'); % vertical edges
I_Y = filter2(G_Y, I, 'same'); % horizontal edges
I_mag = sqrt(I_X.^2 + I_Y.^2); % gradient magnitude
I_theta = atan2(I_Y,I_X);
I_theta(isnan(I_theta)) = 0; % necessary????

% make default grid of samples (centered at zero, width 2)
interval = 2/num_bins:2/num_bins:2;
interval = interval - (1/num_bins + 1);
[grid_x grid_y] = meshgrid(interval, interval);
grid_x = reshape(grid_x, [1 num_samples]);
grid_y = reshape(grid_y, [1 num_samples]);

% make orientation images
I_orientation = zeros(hgt, wid, num_angles);
% for each histogram angle
for a=1:num_angles    
    % compute each orientation channel
    tmp = cos(I_theta - angles(a)).^alpha;
    tmp = tmp .* (tmp > 0);
    
    % weight by magnitude
    I_orientation(:,:,a) = tmp .* I_mag;
end

% for all circles
for i=1:num_pts
    cx = circles(i,1);
    cy = circles(i,2);
    r = circles(i,3) * enlarge_factor;

    % find coordinates of sample points (bin centers)
    grid_x_t = grid_x * r + cx;
    grid_y_t = grid_y * r + cy;
    grid_res = grid_y_t(2) - grid_y_t(1);
    
    % find window of pixels that contributes to this descriptor
    x_lo = floor(max(cx - r - grid_res/2, 1));
    x_hi = ceil(min(cx + r + grid_res/2, wid));
    y_lo = floor(max(cy - r - grid_res/2, 1));
    y_hi = ceil(min(cy + r + grid_res/2, hgt));
    
    % find coordinates of pixels
    [grid_px, grid_py] = meshgrid(x_lo:x_hi,y_lo:y_hi);
    num_pix = numel(grid_px);
    grid_px = reshape(grid_px, [num_pix 1]);
    grid_py = reshape(grid_py, [num_pix 1]);
        
    % find (horiz, vert) distance between each pixel and each grid sample
    dist_px = abs(repmat(grid_px, [1 num_samples]) - repmat(grid_x_t, [num_pix 1])); 
    dist_py = abs(repmat(grid_py, [1 num_samples]) - repmat(grid_y_t, [num_pix 1])); 
    
    % find weight of contribution of each pixel to each bin
    weights_x = dist_px/grid_res;
    weights_x = (1 - weights_x) .* (weights_x <= 1);
    weights_y = dist_py/grid_res;
    weights_y = (1 - weights_y) .* (weights_y <= 1);
    weights = weights_x .* weights_y;
        
    % make sift descriptor
    curr_sift = zeros(num_angles, num_samples);
    for a = 1:num_angles
        tmp = reshape(I_orientation(y_lo:y_hi,x_lo:x_hi,a),[num_pix 1]);        
        tmp = repmat(tmp, [1 num_samples]);
        curr_sift(a,:) = sum(tmp .* weights);
    end    
    sift_arr(i,:) = reshape(curr_sift, [1 num_samples * num_angles]);    
    
%     % visualization
%     if sigma_edge >= 3
%         subplot(1,2,1);
%         rescale_and_imshow(I(y_lo:y_hi,x_lo:x_hi) .* reshape(sum(weights,2), [y_hi-y_lo+1,x_hi-x_lo+1]));
%         subplot(1,2,2);
%         rescale_and_imshow(curr_sift);
%         pause;
%     end
end


%%
%% normalize the SIFT descriptors more or less as described in Lowe (2004)
%%
tmp = sqrt(sum(sift_arr.^2, 2));
normalize_ind = find(tmp > 1);

sift_arr_norm = sift_arr(normalize_ind,:);
sift_arr_norm = sift_arr_norm ./ repmat(tmp(normalize_ind,:), [1 size(sift_arr,2)]);

% suppress large gradients
sift_arr_norm(find(sift_arr_norm > 0.2)) = 0.2;

% finally, renormalize to unit length
tmp = sqrt(sum(sift_arr_norm.^2, 2));
sift_arr_norm = sift_arr_norm ./ repmat(tmp, [1 size(sift_arr,2)]);

sift_arr(normalize_ind,:) = sift_arr_norm;




function [GX,GY]=gen_dgauss(sigma)

f_wid = 4 * floor(sigma);
G = normpdf(-f_wid:f_wid,0,sigma);
G = G' * G;
[GX,GY] = gradient(G); 

GX = GX * 2 ./ sum(sum(abs(GX)));
GY = GY * 2 ./ sum(sum(abs(GY)));
