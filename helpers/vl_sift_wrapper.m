function [f, d] = vl_sift_wrapper(I, circles)
    fc = circles';
    [h, w] = size(fc);
    fc = cat(1, fc, zeros(1, w));
    
    [f, d] = vl_sift(I,'frames',fc, 'orientations') ;
    d = double(d');
    f = double(f(1:2,:)');
end