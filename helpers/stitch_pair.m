function [result_img, H, num_inliers, residual] = ...
    stitch_pair (image, target_image, sift_r, ...
    harris_r, harris_thresh, harris_sigma, num_putative_matches, ransac_n)

image_bw = im2single(rgb2gray(image));
target_image_bw = im2single(rgb2gray(target_image));

[cim, left_Y, left_X] = harris(image_bw, harris_sigma, ...
    harris_thresh, harris_r, 0);
[cim2, right_Y, right_X] = harris(target_image_bw, harris_sigma, ...
    harris_thresh, harris_r, 0);

image_keypoint = cat(2, left_X, left_Y, ...
    repmat(sift_r, length(left_X), 1));
target_image_keypoint = cat(2, right_X, right_Y, ...
    repmat(sift_r, length(right_X), 1));

[image_descriptor_loc, left_descriptors] = ...
    vl_sift_wrapper(image_bw, image_keypoint);
[target_image_descriptor_loc, right_descriptors] = ...
    vl_sift_wrapper(target_image_bw, target_image_keypoint);

[left_matches, right_matches] = ...
    select_putative_matches(left_descriptors, right_descriptors, num_putative_matches);

XY = image_descriptor_loc(left_matches,:);
XY_ = target_image_descriptor_loc(right_matches,:);

[H, num_inliers, residual] = ransac(XY, XY_, ransac_n, ...
    @fit_homography, @homography_transform);

result_img = stitch(image, H, target_image);

end