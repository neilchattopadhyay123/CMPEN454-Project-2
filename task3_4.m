clear; close all; clc;

% Task 3.4 --> Measure 3D locations in the scene to compute triangulation 


%              3 points on floor and fit a 3D plane --> verify if plane Z=0
%              3 points on wall w white vert stripes --> fit on plane eqn?


% use files we uploaded
v1Data = load('Parameters_V1_1.mat');
paramsV1 = v1Data.Parameters;

v2Data = load('Parameters_V2_1.mat');
paramsV2 = v2Data.Parameters;

im1 = imread('im1corrected.jpg');
im2 = imread('im2corrected.jpg');

% Points 1-3: floor
% Points 4-6: striped wall
% Points 7: doorway top
% Points 8: head top
% Points 9: tripod camera 

points = {
    'Floor 1', 'Floor 2', 'Floor 3', ...
    'Wall 1', 'Wall 2', 'Wall 3', 
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
if selectedPoints && isfile('selectedPoints3_4.mat')
    load('selectedPoints3_4.mat', 'points1', 'points2');

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

        % feature to select
        title(['View 1: select ', pointNames{i}]);

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

        title(['View 2: select the SAME ', pointNames{i}]);

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


% Pairs into 3D locations





