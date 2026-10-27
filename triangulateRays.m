function pts3D_recovered = triangulateRays(pts2D_V1, pts2D_V2, paramsV1, paramsV2)
numPts = size(pts2D_V1, 2);
pts3D_recovered = zeros(3, numPts);

C1 = paramsV1.position(:);
C2 = paramsV2.position(:);
R1 = paramsV1.Rmat;
R2 = paramsV2.Rmat;
K1_inv = inv(paramsV1.Kmat);
K2_inv = inv(paramsV2.Kmat);

b = C2 - C1;

for i = 1:numPts
    x1 = [pts2D_V1(:, i); 1];
    x2 = [pts2D_V2(:, i); 1];

    % Ray directions
    v1 = R1' * (K1_inv * x1);
    d1 = v1 / norm(v1);
    v2 = R2' * (K2_inv * x2);
    d2 = v2 / norm(v2);

    % Solve for closest points along rays
    d1_dot_d2 = dot(d1, d2);
    A = [1, -d1_dot_d2; 
        d1_dot_d2, -1];
    rhs = [dot(b, d1); 
        dot(b, d2)];

    st = A \ rhs;
    pt1 = C1 + st(1) * d1;
    pt2 = C2 + st(2) * d2;

    pts3D_recovered(:, i) = (pt1 + pt2) / 2;
end
end