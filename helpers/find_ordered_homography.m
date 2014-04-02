function image_order = ...
    find_ordered_homography(images, sift_r, harris_r, harris_thresh, ...
        harris_sigma, num_putative_matches, ransac_n)

    n_img = length(images);
    num_inliers = zeros(n_img, n_img);
    H = cell(n_img, n_img);
    residual = zeros(n_img, n_img);
    for i = 1:n_img
        for j = i+1:n_img
            [~ , H{i,j}, num_inliers(i,j), residual(i,j)] = ...
                stitch_pair(images{i}, images{j}, sift_r, harris_r, harris_thresh, ...
                harris_sigma, num_putative_matches, ransac_n);

            H{j,i} = H{i,j};
            num_inliers(j,i) = num_inliers(i,j);
            residual(j,i) = residual(i,j);
        end
    end

    link = cell(1, n_img);
    
    [~, sort_index] = sort(num_inliers(:), 'descend');
    inlier_thresh = num_inliers(sort_index(n_img*2-2));

    count_links = zeros(1, 2);
    for i = 1:n_img
        link{i} = find(num_inliers(i,:) >= inlier_thresh);
        num_links = length(link{i});
        assert(0 < num_links && num_links <= 2);
        count_links(num_links) = count_links(num_links) + 1;
    end
    assert(count_links(1) == 2);

    selected = zeros(1, n_img);
    image_order = zeros(1, n_img);
    for i = 1:n_img
        num_links = length(find(num_inliers(i,:) >= inlier_thresh));
        if num_links == 1
            selected(i) = 1;
            image_order(1) = i;
            break;
        end
    end

    for i = 1:n_img-1
        prev = image_order(i);
        for j = link{prev}
            if selected(j) == 0
                image_order(i+1) = j;
                break;
            end
        end
    end
end