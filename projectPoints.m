function pts2D = projectPoints(pts3D, K, P)


M = K * P;

% Converting to homogeneous coordinates
pts_homog = M * [pts3D; ones(1, size(pts3D, 2))];

% Dividing by scale factor
pts2D = [pts_homog(1, :) ./ pts_homog(3, :); 
    pts_homog(2, :) ./ pts_homog(3, :)];
end