left_img = im2single(rgb2gray(imread('img/uttower_left.jpg')));
right_img = im2single(rgb2gray(imread('img/uttower_right.jpg')));

[cim, left_Y, left_X] = harris(left_img, 1, 0.03, 5, 0);
[cim2, right_Y, right_X] = harris(right_img, 1, 0.03, 5, 0);

radius = 5;

left_keypoint = cat(2, left_X, left_Y, repmat(radius, length(left_X), 1));
right_keypoint = cat(2, right_X, right_Y, repmat(radius, length(right_X), 1));

[left_descriptor_loc, left_descriptors] = vl_sift_wrapper(left_img, left_keypoint);
[right_descriptor_loc, right_descriptors] = vl_sift_wrapper(right_img, right_keypoint);

[left_matches, right_matches] = ...
    select_putative_matches(left_descriptors, right_descriptors, 350, 300);


XY = left_descriptor_loc(left_matches,:);

XY_ = right_descriptor_loc(right_matches,:);

H = ransac(XY, XY_, 500, @fit_homography, @homography_transform);

[left_img_t,xdata_left,ydata_left] = ...
    imtransform(left_img,maketform('projective',H'));

xdata_out=[min(1,xdata_left(1)) max(size(right_img,2),xdata_left(2))];
ydata_out=[min(1,ydata_left(1)) max(size(right_img,1),ydata_left(2))];

result = imtransform(left_img, maketform('projective',H'),'XData',xdata_out,'YData',ydata_out);
result = result + imtransform(right_img,maketform('affine',eye(3)),'XData',xdata_out,'YData',ydata_out);

imshow(result);