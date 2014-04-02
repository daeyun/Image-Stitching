images = cell(1, 3);
images{1} = imread('image_stitching/img/ledge/1.JPG');
images{2} = imread('image_stitching/img/ledge/2.JPG');
images{3} = imread('image_stitching/img/ledge/3.JPG');

[result, H, num_inliers, residual] = ...
    stitch_images(images, 5, 5, 0.03, 1, 100, 4000);

imshow(result);