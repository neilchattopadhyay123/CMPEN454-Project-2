clear; clc;

files = {'Parameters_V1_1.mat', 'Parameters_V2_1.mat'};

for i = 1:length(files)
    fprintf('Checking file %d\n', i);
    data = load(files{i});
    params = data.Parameters;

    % Rebuild K from intrinsics
    fx = params.foclen;
    fy = params.foclen * params.aspectratio;
    s  = params.skew;
    u0 = params.prinpoint(1);
    v0 = params.prinpoint(2);

    K_calc = [fx,  s, u0; 0, fy, v0; 0,  0,  1];

    diff_K = norm(K_calc - params.Kmat);
    fprintf('Difference in K: %e\n', diff_K);

    % Check R rotation matrix properties
    R = params.Rmat;
    diff_ortho = norm(R * R' - eye(3));
    det_R = det(R);
    fprintf('R orthonormality error: %e, det(R): %.4f\n', diff_ortho, det_R);

    C = params.position(:);
    t = -R * C;
    P_calc = [R, t];

    diff_P = norm(P_calc - params.Pmat);
    fprintf('Difference in P: %e\n\n', diff_P);
end
