clear; close all; clc;

% Load 3D points
mocapData = load('mocapPoints3D.mat');
pts3D = mocapData.pts3D;

% Loading camera parameters
v1Data = load('Parameters_V1.mat');
paramsV1 = v1Data.Parameters;

v2Data = load('Parameters_V2.mat');
paramsV2 = v2Data.Parameters;

im1 = imread('im1corrected.jpg');
im2 = imread('im2corrected.jpg');

% Project points
pts2D_V1 = projectPoints(pts3D, paramsV1.Kmat, paramsV1.Pmat);
pts2D_V2 = projectPoints(pts3D, paramsV2.Kmat, paramsV2.Pmat);

% Plot for view 1
figure;
imshow(im1);
hold on;
plot(pts2D_V1(1, :), pts2D_V1(2, :), 'ro');
title('View 1 Mocap Projections');

% Plot for view 2
figure;
imshow(im2);
hold on;
plot(pts2D_V2(1, :), pts2D_V2(2, :), 'go');
title('View 2 Mocap Projections');


save('mocapPoints2D.mat', 'pts2D_V1', 'pts2D_V2');
fprintf('Done')