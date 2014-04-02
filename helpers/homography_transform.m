function [XY_] = homography_transform(XY, H)
    Xi = cat(1, XY', ones(1, size(XY, 1)));
    lambdaXi_ = H*Xi;
    lambdaXi_ = lambdaXi_';
    XY_ = lambdaXi_(:,1:2);
    XY_(:,1)=XY_(:,1)./lambdaXi_(:,3);
    XY_(:,2)=XY_(:,2)./lambdaXi_(:,3);
end