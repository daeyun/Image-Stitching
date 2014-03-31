function result = ransac(XY, XY_, N, estimate_func, transform_func)
    XYb = [];
    XYb_ = [];

    select_inliers = false;

    H = [];

    for i = 1:N
        ind = randperm(size(XY,1));
        ind_s = ind(1:4);
        ind_r = ind(5:end);

        if select_inliers
            XYs = XYb;
            XYs_ = XYb_;
        else
            XYs = XY(ind_s,:);
            XYs_ = XY_(ind_s,:);
        end

        XYr = XY(ind_r,:);
        XYr_ = XY_(ind_r,:);

        H = estimate_func(XYs, XYs_);
        [XYf_] = transform_func(XYr, H);

        dists = sum((XYr_ - XYf_).^2,2).^0.5;

        ind_b = find(dists<0.5);
        num_inliers = length(ind_b);

        if num_inliers > 40
            select_inliers = true;
            XYb = XYr(ind_b,:);
            XYb_ = XYr_(ind_b,:);
        else
            select_inliers = false;
        end
    end
    
    result = H
end