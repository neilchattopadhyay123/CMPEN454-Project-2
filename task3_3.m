clear; close all; clc;

% Load ground truth 3D points
mocapData = load('mocapPoints3D.mat');
pts3D_gt = mocapData.pts3D;

% Load projected 2D coordinates
mocap2D = load('mocapPoints2D.mat');
pts2D_V1 = mocap2D.pts2D_V1;
pts2D_V2 = mocap2D.pts2D_V2;

% Load camera parameters
v1Data = load('Parameters_V1_1.mat');
paramsV1 = v1Data.Parameters;
v2Data = load('Parameters_V2_1.mat');
paramsV2 = v2Data.Parameters;

% Run triangulation
pts3D_recovered = triangulateRays(pts2D_V1, pts2D_V2, paramsV1, paramsV2);


diffs = pts3D_recovered - pts3D_gt;
mse = mean(sum(diffs.^2, 1));
max_err = max(sqrt(sum(diffs.^2, 1)));

fprintf('MSE: %e\n', mse);
fprintf('Max Error: %e\n', max_err);

% 3D plot
figure;
plot3(pts3D_gt(1, :), pts3D_gt(2, :), pts3D_gt(3, :), 'bo');
hold on;
plot3(pts3D_recovered(1, :), pts3D_recovered(2, :), pts3D_recovered(3, :), 'rx');
grid on;
axis equal;
title('Ground Truth vs Triangulated Points');
legend('Ground Truth', 'Triangulated');
view(3);
