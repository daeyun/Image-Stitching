target_image = imread('img/uttower_left.jpg');
image = imread('img/uttower_right.jpg');
stitch_pair(image, target_image, 5, 5, 0.03, 1, 200, 4000);