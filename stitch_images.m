% STITCH_IMAGES - Given a set of images with overlapping regions,
%                 automatically compute a panorama image.
%
% Usage:    [result_img, H, num_inliers, residual] ...
%               = stitch_images (images, sift_r, harris_r, ...
%               harris_thresh, harris_sigma, num_putative_matches, ransac_n)
%
% Usage example:
%           stitch_images(images, 5, 5, 0.03, 1, 100, 4000)
%
% Arguments:
%           images        - 1 by n cell array of images.
%           sift_r        - radius of the SIFT descriptor.
%           harris_r      - radius of the Harris corner detector.
%           harris_thresh - Harris corner detector threshold.
%           harris_sigma  - standard deviation of smoothing Gaussian
%           num_putative_matches  - number of putative matches to run
%                                   RANSAC.
%           ransac_n      - number of RANSAC iterations.
%
% Returns:
%           result_img    - Computed paranoma image.
%           H             - n by n cell array of homography matrices.
%                           H{i, j} is the homography matrix between images
%                           i and j.
%           num_inliers   - n by n array of number of inliers. num_inliers{i,
%                           j} is the number of inliers between images i and
%                           j.
%           residual      - n by n array of sum of squared disrances.
%                           residual{i, j} is the residual between images i
%                           and j.
%
% Dependencies:
%           VLFeat        - Download at http://www.vlfeat.org/download.html
%
% Author:
% Daeyun Shin
% daeyun@daeyunshin.com  daeyunshin.com
%
% March 2014

function [result_img, H, num_inliers, residual] = stitch_images...
    (images, sift_r, harris_r, harris_thresh, harris_sigma, num_putative_matches, ransac_n)

    image_order =  find_ordered_homography(images, sift_r, harris_r, harris_thresh, ...
        harris_sigma, num_putative_matches, ransac_n);

    n_img = length(images);
    num_inliers = zeros(n_img, n_img);
    H = cell(n_img, n_img);
    residual = zeros(n_img, n_img);

    result_img = images{image_order(1)};
    for image_ind = 2:length(image_order)
        prev_ind = image_order(image_ind-1);
        ind = image_order(image_ind);

        [result_img, H{prev_ind, ind}, num_inliers(prev_ind, ind), residual(prev_ind, ind)] ...
            = stitch_pair(images{ind}, result_img, sift_r, harris_r, harris_thresh, ...
                          harris_sigma, num_putative_matches, ransac_n);

        H{ind, prev_ind} = H{prev_ind, ind};
        num_inliers(ind, prev_ind) = num_inliers(prev_ind, ind);
        residual(ind, prev_ind) = residual(prev_ind, ind);
    end
end