close all; clc;

% ORANGE (source) onto APPLE (background)
im_bg  = im2double(imread('Hand.jpeg'));     % BACKGROUND
im_obj = im2double(imread('Eye.jpeg'));   % SOURCE to cut

% 1) Draw polygon around the ORANGE (source)
[poly_x, poly_y] = getPolygonForMask(im_obj);
objmask = poly2mask(poly_x, poly_y, size(im_obj,1), size(im_obj,2));

% 2) Click bottom-center placement on the APPLE (background)
[center_x, bottom_y] = getBottomCenterLoc(im_bg);

% 3) Align and composite
padding = 64;
[im_s, mask_s] = alignSource(im_obj, objmask, im_bg, center_x, bottom_y, padding);
mask_s = im2double(mask_s);
result = cut_and_paste(im_bg, im_s, mask_s);

% 4) Show and print vectors/placement for hard-coding
figure; montage({im_bg, im_obj, mask_s, result}, 'Size',[1 4], ...
    'BorderSize',[25 25], 'BackgroundColor',[1 1 1]);

fprintf('\n----- COPY THESE INTO YOUR HARD-CODED SCRIPT -----\n');
fprintf('poly_x = [%s];\n', strjoin(string(poly_x), ' '));
fprintf('poly_y = [%s];\n', strjoin(string(poly_y), ' '));
fprintf('center_x = %.4f;\n', center_x);
fprintf('bottom_y = %.4f;\n', bottom_y);
fprintf('---------------------------------------------------\n');

% -------------------- functions --------------------
function im_cut_and_paste = cut_and_paste(im_bg, im_s, mask_s)
    m3 = cat(3, mask_s, mask_s, mask_s);
    im_cut_and_paste = im_bg .* (1 - m3) + im_s .* m3;
end

function [poly_x, poly_y] = getPolygonForMask(im)
    disp('Draw polygon around source object in clockwise order, press q to finish');
    fig=figure; hold off; imagesc(im); axis image off;
    poly_x = []; poly_y = [];
    while true
        figure(fig)
        [x, y, b] = ginput(1);
        if b=='q', break; end
        poly_x(end+1) = x; %#ok<AGROW>
        poly_y(end+1) = y; %#ok<AGROW>
        hold on; plot(poly_x, poly_y, 'r*-');
    end
    close(fig);
end

function [center_x, bottom_y] = getBottomCenterLoc(im_t)
    disp('Click the desired bottom-center on the BACKGROUND image');
    fig=figure; hold off; imagesc(im_t); axis image off;
    figure(fig)
    [center_x, bottom_y, ~] = ginput(1);
    close(fig);
end

function [im_s2, mask2] = alignSource(im_s, mask, im_t, center_x, bottom_y, padding)
    [y, x] = find(mask);
    y1 = min(y)-1-padding; y2 = max(y)+1+padding; 
    x1 = min(x)-1-padding; x2 = max(x)+1+padding;
    im_s2 = zeros(size(im_t));

    yind  = (y1:y2);  yind2 = yind - max(y) + round(bottom_y);
    xind  = (x1:x2);  xind2 = xind - round(mean(x)) + round(center_x);
    
    % clip to image boundaries
    yind(yind > size(im_s,1)) = size(im_s,1); yind(yind < 1) = 1;
    xind(xind > size(im_s,2)) = size(im_s,2); xind(xind < 1) = 1;
    yind2(yind2 > size(im_t,1)) = size(im_t,1); yind2(yind2 < 1) = 1;
    xind2(xind2 > size(im_t,2)) = size(im_t,2); xind2(xind2 < 1) = 1;

    y = y - max(y) + round(bottom_y);
    x = x - round(mean(x)) + round(center_x);
    ind = y + (x-1)*size(im_t,1);
    mask2 = false(size(im_t,1), size(im_t,2));
    mask2(ind) = true;
    
    im_s2(yind2, xind2, :) = im_s(yind, xind, :);    
end