clear; close all; clc;

% Read in images
im1 = imread('Project2DataFiles\im1corrected.jpg');
im2 = imread('Project2DataFiles\im2corrected.jpg');

% Initialize the fundamental matrix and pts
F = [];
pts1 = [];
pts2 = [];

% If saved points exist load them, if not make user pick them
if exist('eightpoint_savepoints.mat','file') == 2
    S = load('eightpoint_savepoints.mat');
    x1 = S.savx1;
    y1 = S.savy1;
    x2 = S.savx2;
    y2 = S.savy2;

    [F, pts1, pts2] = eightpoint(im1, im2, [x1, y1], [x2, y2]);
else
    [F, pts1, pts2] = eightpoint(im1, im2);
end

% Display selected points for image 1
figure;
imshow(im1);
hold on;
plot(pts1(:,1), pts1(:,2), 'r.', 'MarkerSize', 15);
hold off;
title('pts1 on im1');

% Display selected points for image 2
figure;
imshow(im2);
hold on;
plot(pts2(:,1), pts2(:,2), 'g.', 'MarkerSize', 15);
hold off;
title('pts2 on im2');

% Save selected points to eightpoint_savepoints.mat
savx1 = pts1(:,1);
savy1 = pts1(:,2);
savx2 = pts2(:,1);
savy2 = pts2(:,2);
save('eightpoint_savepoints.mat','savx1','savy1','savx2','savy2');

% Save computed fundamental matrix to EightPointFundamentalMatrix
save("EightPointFundamentalMatrix.mat", "F");