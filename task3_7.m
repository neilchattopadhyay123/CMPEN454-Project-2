clear; close all; clc;

% Load 2d points from 3.2 and fundamental matrices found in 3.5 and 3.6
load('mocapPoints2D.mat', 'pts2D_V1', 'pts2D_V2');

F_3_5 = load('fundamentalMatrix.mat').F;
F_3_6 = load('EightPointFundamentalMatrix.mat').F;

% Calculate SED for each fundamental matrix
Fs = {F_3_5, F_3_6};
names = {'Fundamental Matrix 3.5', 'Fundamental Matrix 3.6'};

for k = 1:length(Fs)
    F = Fs{k};
    totalError = 0;
    numPoints = size(pts2D_V1, 2);

    for i = 1:numPoints
        % Get matching points in images 1 and 2
        x1 = pts2D_V1(1, i);
        y1 = pts2D_V1(2, i);
        x2 = pts2D_V2(1, i);
        y2 = pts2D_V2(2, i);

        % Convert points to homogeneous coordinates
        p1 = [x1; y1; 1];
        p2 = [x2; y2; 1];

        % Epipolar line in image 2: l2 = F * p1
        l2 = F * p1;
        d2 = (l2' * p2)^2 / (l2(1)^2 + l2(2)^2);

        % Epipolar line in image 1: l1 = F' * p2
        l1 = F' * p2;
        d1 = (l1' * p1)^2 / (l1(1)^2 + l1(2)^2);

        % Sum squared distances
        totalError = totalError + d1 + d2;
    end

    % Find mean over both directions and all point matches
    SED = totalError / (2 * numPoints);

    fprintf('%s SED = %.6f\n', names{k}, SED);
end