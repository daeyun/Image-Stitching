% Testing the fit_homography function based on numbers from
% http://www.leet.it/home/giusti/teaching/matlab_sessions/stitching/stitch.html

x1 = 1.0e+03 * [0.8860;
     1.5505;
     1.5835;
     1.3225];
y1 = [371.7500;
      386.7500;
      833.7500;
      881.7500];
x2 = [41.5000;
      697.0000;
      724.0000;
      482.5000];
y2 = 1.0e+03 * [0.5563;
     0.5668;
     0.9823;
     1.0588];

T = maketform('projective', [x2 y2], [x1 y1]);
H=(T.tdata.T)';
H=fit_homography(x2, y2, x1, y1);

X = [x2 y2 ones(size(y1,1),1)]';

X_=H*X;

X_(1,:)=X_(1,:)./X_(3,:);
X_(2,:)=X_(2,:)./X_(3,:);
X_(3,:)=X_(3,:)./X_(3,:);

% Display results
X
X_
