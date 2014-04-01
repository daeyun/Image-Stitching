function [as, bs] = select_putative_matches(d1, d2, num)
    d1 = zscore(d1')';
    d2 = zscore(d2')';
    
    dist = dist2(d1, d2);
%     [as, bs] = find(dist>threshold);

    [h, w] = size(dist);
    dist = reshape(dist, 1, []);
    [B, I] = sort(dist);
    [rr, cc] = ind2sub([h, w], I(1:num));
    
    as = rr';
    bs = cc';
end