clear; close all; clc;

% Task 3.5: Calculate F from the camera calibration
% F*x1 gives a line in image 2
% F'*x2 gives a line in image 1

% load camera parameters
v1Data = load('Parameters_V1_1.mat');
paramsV1 = v1Data.Parameters;

v2Data = load('Parameters_V2_1.mat');
paramsV2 = v2Data.Parameters;

% intrinsic matrices
intmat_1 = paramsV1.Kmat;
intmat_2 = paramsV2.Kmat;

% rotation matrices from world coordinates to camera coordinates
rot_matrix1 = paramsV1.Rmat;
rot_matrix2 = paramsV2.Rmat;

% camera positions to world coordinates
camera1 = paramsV1.position(:);
camera2 = paramsV2.position(:);

% camera 2's position relative to camera 1
baseline1 = rot_matrix1 * (camera2 - camera1);

fprintf('Camera 2 position in camera 1 coordinates (mm):\n');
disp(baseline1);

% directions from camera 1 coordinates to camera 2 coordinates
% R1' goes back to world coordinates
% R2 goes into camera 2
R = rot_matrix2 * rot_matrix1';

fprintf('Relative rotation from camera 1 to camera 2:\n');
disp(R);

% cross product matrix for baseline
bx = baseline1(1);
by = baseline1(2);
bz = baseline1(3);

S = [  0, -bz,  by;
      bz,   0, -bx;
     -by,  bx,   0];

% essential matrix
E = R * S;

% E --> fundamental matrix with pixels
F = (intmat_2' \ E) / intmat_1;

% normalize 
F = F / norm(F, 'fro');

% F and -F --> same epipolar lines
if F(3, 3) < 0
    F = -F;
end

format long e;
fprintf('Essential matrix E:\n');
disp(E);

fprintf('Fundamental matrix F:\n');
disp(F);

% F = rank 2
fprintf('Singular values of F:\n');
disp(svd(F));

%  projected mocap points from Task 3.2
mocap2D = load('mocapPoints2D.mat');

p2D_V1 = mocap2D.pts2D_V1;
p2D_V2 = mocap2D.pts2D_V2;

numPoints = size(p2D_V1, 2);

% Add row of ones so each point = [u; v; 1]
x1 = [p2D_V1; ones(1, numPoints)];
x2 = [p2D_V2; ones(1, numPoints)];

% find epipolar lines in both images
% each line has coefficients [a; b; c]
% a*u + b*v + c = 0.
lineIn2 = F * x1;
lineIn1 = F' * x2;

% check if matching points lie on epipolar lines
r2 = sum(x2 .* lineIn2, 1);
r1 = sum(x1 .* lineIn1, 1);

fprintf('Max absolute epipolar residual (Image 2): %.6e\n', max(abs(r2)));

fprintf('Max absolute epipolar residual (Image 1): %.6e\n', max(abs(r1)));

% load images
im1 = imread('im1corrected.jpg');
im2 = imread('im2corrected.jpg');

pointIDs = [1, 6, 17, 24, 31, 38];
pointIDs = pointIDs(pointIDs <= numPoints);
colors = lines(length(pointIDs));

% epipolar lines in View 1
figure;
imshow(im1);
hold on;

for i = 1:length(pointIDs)

    j = pointIDs(i);

    % point j in image 2
    drawEpipolarLine(lineIn1(:, j), size(im1, 2), size(im1, 1), colors(i, :));

    % point in image 1
    plot(p2D_V1(1, j), p2D_V1(2, j), 'o', 'Color', colors(i, :), 'MarkerSize', 7, 'LineWidth', 1.5);

    text(p2D_V1(1, j) + 8, p2D_V1(2, j) - 8, num2str(j), 'Color', colors(i, :));
end

title('View 1: epipolar lines from F^T x_2');
xlim([1, size(im1, 2)]);
ylim([1, size(im1, 1)]);

% epipolar lines in View 2
figure;
imshow(im2);
hold on;

for i = 1:length(pointIDs)

    j = pointIDs(i);

    % point j in image 1
    drawEpipolarLine(lineIn2(:, j), size(im2, 2), size(im2, 1), colors(i, :));

    % point in image 2
    plot(p2D_V2(1, j), p2D_V2(2, j), 'o', 'Color', colors(i, :), 'MarkerSize', 7, 'LineWidth', 1.5);

    text(p2D_V2(1, j) + 8, p2D_V2(2, j) - 8, num2str(j), 'Color', colors(i, :));
end

title('View 2: epipolar lines from F x_1');
xlim([1, size(im2, 2)]);
ylim([1, size(im2, 1)]);

% saving matrix
save('fundamentalMatrix.mat', 'F', 'E', 'R', 'S', 'baseline1');


% draw line --> a*u + b*v + c = 0
function drawEpipolarLine(lineCoefficients, width, height, color)

    a = lineCoefficients(1);
    b = lineCoefficients(2);
    c = lineCoefficients(3);

    % skip if direction unknown
    if norm([a; b]) < eps
        return;
    end

    if abs(b) >= abs(a)

        u = [1, width];
        v = -(a * u + c) / b;

    else
        v = [1, height];
        u = -(b * v + c) / a;

    end

    plot(u, v, 'Color', color, 'LineWidth', 1);

end
