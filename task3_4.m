clear; close all; clc;

% Task 3.4 --> Measure 3D locations in the scene to compute triangulation 


%              3 points on floor and fit a 3D plane --> verify if plane Z=0
%              3 points on wall w white vert stripes --> fit on plane eqn?


% use files we uploaded
v1Data = load('Project2DataFiles/Parameters_V1_1.mat');
paramsV1 = v1Data.Parameters;

v2Data = load('Project2DataFiles/Parameters_V2_1.mat');
paramsV2 = v2Data.Parameters;

im1 = imread('Project2DataFiles/im1corrected.jpg');
im2 = imread('Project2DataFiles/im2corrected.jpg');

% Points 1-3: floor
% Points 4-6: striped wall
% Points 7: doorway top
% Points 8: head top
% Points 9: tripod camera 

points = {
    'Floor 1', 'Floor 2', 'Floor 3', ...
    'Wall 1', 'Wall 2', 'Wall 3', ...
    'Doorway Top', 'Head Top', 'Tripod Camera'
    };

numPoints = length(points);

% select points --> false to reselect
selectedPoints = true;

%% Images
fig1 = figure;
imshow(im1);
hold on;
title('View 1')

fig2 = figure;
imshow(im2);
hold on;
title('View 2')

% Select Points/load points
% isfile --> checks saved selections file 
%   selectedPoints = true
%   The file exists
if selectedPoints && isfile('Project2DataFiles/selectedPoints3_4.mat')
    load('Project2DataFiles/selectedPoints3_4.mat', 'points1', 'points2');

    % Check if saved points matches
    % checks matrix u x v with 9 columns, 1 for each feature
    assert(isequal(size(points1), [2, numPoints]) && isequal(size(points2), [2, numPoints]), ...
        'Set selectedPoints = false to select points again.');

    fprintf('Loaded previously selected points.\n');
else 
    % create a matrix to hold data of our points
    
    points1 = zeros(2, numPoints);
    points2 = zeros(2, numPoints);

    % do for all nine features
    for i = 1:numPoints

        % first image window
        figure(fig1);
        title(['View 1: select ', points{i}]);

        % one mouse click --> ginput returns the pixel coordinates 
        [u1, v1] = ginput(1);

        % enter without clicking --> returns empty result
        if isempty(u1)
            error('Cancelled');
        end

        % store feature 
        points1(:, i) = [u1; v1];

        % draw something at selected feature
        plot(u1, v1, 'r+', 'MarkerSize', 10, 'LineWidth', 2);


        % second image window
        figure(fig2);

        title(['View 2: select the SAME ', points{i}]);

        [u2, v2] = ginput(1);

        if isempty(u2)
            error('Selection cancelled.');
        end

        points2(:, i) = [u2; v2];

        plot(u2, v2, 'r+', ...
            'MarkerSize', 10, 'LineWidth', 2);
    end
    save('selectedPoints3_4.mat', 'points1', 'points2');
end

% display selected points on images
figure(fig1);
imshow(im1);
hold on;
plot(points1(1, :), points1(2, :), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
title('View 1 selected points')

figure(fig2);
imshow(im2);
hold on;
plot(points2(1, :), points2(2, :), 'r+', 'MarkerSize', 10, 'LineWidth', 2)
title('View 2 selected points')

% pairs into 3D locations
% for each pair
%   find viewing direction from camera 1/2
%   find closest point to viewing line

points3D = triangulateRays(points1, points2, paramsV1, paramsV2);


% columns 1-3 --> three floor points
floor3D = points3D(:, 1:3);

% columns 4-6 --> three striped wall points
wall3D = points3D(:, 4:6);

% column 7 --> doorway top point
door3D = points3D(:, 7);

% column 8 --> head top point
head3D = points3D(:, 8);

% column 9 --> tripod camera 
camera3D = points3D(:, 9);


% wall plane equations
% aX + bY + cZ + d = 0
floorPlane = fitPlane(floor3D);
wallPlane = fitPlane(wall3D);

fprintf('\nTASK 3.4 RESULTS\n');
fprintf('Floor plane (mm):\n');

fprintf('%.6f X + %.6f Y + %.6f Z + %.3f = 0\n', floorPlane);

fprintf('Floor point Z coordinates (mm):\n');
disp(floor3D(3, :));

fprintf('Striped wall plane:\n');

fprintf('%.6f X + %.6f Y + %.6f Z + %.3f = 0\n\n', ...
    wallPlane);


% doorway and head heights in meters
doorHeight = door3D(3);
headHeight = head3D(3);

fprintf('Doorway height: %.1f mm = %.3f m\n', doorHeight, doorHeight / 1000);

fprintf('Head height: %.1f mm = %.3f m\n', headHeight, headHeight / 1000);


% camera location 
fprintf('Tripod camera location: (%.1f, %.1f, %.1f) mm\n', camera3D);

% plotting in 3D
figure;
hold on;
grid on;

% floor points: blue circles.
plot3(floor3D(1, :), floor3D(2, :), floor3D(3, :), 'bo', 'MarkerSize', 8);

% wall points: black squares
plot3(wall3D(1, :), wall3D(2, :), wall3D(3, :), 'wo', 'MarkerSize', 8);

% doorway top: magenta circle
plot3(door3D(1), door3D(2), door3D(3), 'mo', 'MarkerSize', 8);

% head top: green circle
plot3(head3D(1), head3D(2), head3D(3), 'go', 'MarkerSize', 8);

% tripod camera: red circle
plot3(camera3D(1), camera3D(2), camera3D(3), 'ro', 'MarkerSize', 8);

xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('Z (mm)');

title('Task 3.4 reconstructed scene points');

legend('Floor', 'Wall', 'Doorway top', 'Head top', 'Tripod camera', 'Location', 'best');
view(3);


% plane = [a; b; c; d]
% a*X + b*Y + c*Z + d = 0

function plane = fitPlane(points3D)

    % find average location of the points
    center = mean(points3D, 2);
    centeredPoints = points3D - center;


    if rank(centeredPoints) < 2
        error('Plane points are collinear. Select different points.');
    end


    % SVD separates the point cloud into perpendicular directions
    % transpose centeredPoints so each row represents one point
    [~, ~, V] = svd(centeredPoints');

    normal = V(:, end);
    % normal = [a; b; c]

    [~, largestComponent] = max(abs(normal));

    if normal(largestComponent) < 0
        normal = -normal;
    end

    % d = -(a*centerX + b*centerY + c*centerZ)
    d = -normal' * center;

    % combines four coefficients into one column vector
    plane = [normal; d];

end



