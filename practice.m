close all; clc;

% Load your two images (apple -> source, orange -> background)
im_bg  = im2double(imread('Orange.jpeg'));
im_obj = im2double(imread('Apple.jpg'));

%% 1) Draw polygon around the APPLE (click points clockwise, press q to finish)
[poly_x, poly_y] = getPolygonForMask(im_obj);

% Print in paste-ready format
fprintf('\n----- COPY THESE INTO YOUR CODE -----\n');
fprintf('poly_x = [');
fprintf('%.4f ', poly_x);
fprintf('];\n');

fprintf('poly_y = [');
fprintf('%.4f ', poly_y);
fprintf('];\n');

%% 2) Click bottom-center placement on the ORANGE
[center_x, bottom_y] = getBottomCenterLoc(im_bg);

% Print in paste-ready format
fprintf('center_x = %.4f;\n', center_x);
fprintf('bottom_y = %.4f;\n', bottom_y);
fprintf('-------------------------------------\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions (same as in the assignment)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [poly_x, poly_y] = getPolygonForMask(im)
    disp('Draw polygon around source object in clockwise order, press q to stop');
    fig = figure; hold off; imagesc(im); axis image off;
    poly_x = []; poly_y = [];
    while true
        figure(fig);
        [x, y, b] = ginput(1);
        if isequal(b,'q'); break; end
        poly_x(end+1) = x; %#ok<AGROW>
        poly_y(end+1) = y; %#ok<AGROW>
        hold on; plot(poly_x, poly_y, 'y*-', 'LineWidth', 1.5);
    end
    close(fig);
end

function [center_x, bottom_y] = getBottomCenterLoc(im_t)
    disp('Click the desired bottom-center location on the BACKGROUND image');
    fig = figure; hold off; imagesc(im_t); axis image off;
    [center_x, bottom_y, ~] = ginput(1);
    close(fig);
end