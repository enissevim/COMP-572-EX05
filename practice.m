close('all');   % close all open figures so we start with a clean slate!

% Image Set 2: Orange and Apple
im_bg2 = im2double(imread('Orange.jpeg'));        % background image
im_obj2 = im2double(imread('Apple.jpg'));       % source image

% Hard-coded coordinates for apple on orange
poly_x2 = [575.9386 554.8860 544.3596 530.3246 519.7982 491.7281 470.6754 446.1140 435.5877 414.5351 396.9912 386.4649 375.9386 372.4298 365.4123 365.4123 365.4123 396.9912 407.5175 435.5877 460.1491 502.2544 530.3246 604.0088 698.7456 814.5351 982.9561 1088.2193 1246.1140 1351.3772 1330.3246 1298.7456 1351.3772 1386.4649 1418.0439 1439.0965 1460.1491 1477.6930 1614.5351 1782.9561 1912.7807 1993.4825 2133.8333 2291.7281 2393.4825 2470.6754 2523.3070 2582.9561 2625.0614 2639.0965 2646.1140 2639.0965 2628.5702 2618.0439 2593.4825 2554.8860 2523.3070 2491.7281 2446.1140 2418.0439 2393.4825 2365.4123 2319.7982 2281.2018 2239.0965 2196.9912 2140.8509 2070.6754 1933.8333 1877.6930 1660.1491 1614.5351 1470.6754 1414.5351 1291.7281 1246.1140 1186.4649 1077.6930 961.9035 881.2018 835.5877 772.4298 596.9912 582.9561];
poly_y2 = [2104.0088 2051.3772 2019.7982 1970.6754 1925.0614 1882.9561 1830.3246 1749.6228 1682.9561 1602.2544 1556.6404 1482.9561 1409.2719 1367.1667 1304.0088 1212.7807 1125.0614 1030.3246 956.6404 851.3772 791.7281 735.5877 672.4298 598.7456 539.0965 475.9386 402.2544 377.6930 360.1491 360.1491 318.0439 296.9912 265.4123 230.3246 230.3246 275.9386 314.5351 360.1491 360.1491 346.1140 335.5877 328.5702 381.2018 465.4123 567.1667 630.3246 728.5702 861.9035 977.6930 1104.0088 1251.3772 1409.2719 1504.0088 1654.8860 1760.1491 1861.9035 1967.1667 2040.8509 2118.0439 2212.7807 2314.5351 2419.7982 2504.0088 2567.1667 2612.7807 2675.9386 2725.0614 2767.1667 2781.2018 2749.6228 2812.7807 2819.7982 2781.2018 2767.1667 2749.6228 2756.6404 2798.7456 2781.2018 2749.6228 2714.5351 2654.8860 2546.1140 2114.5351 2082.9561];

objmask2 = poly2mask(poly_x2, poly_y2, size(im_obj2, 1), size(im_obj2, 2));
center_x2 = 346.4556;
bottom_y2 = 554.7117;

padding = 0;
[im_s2, mask_s2] = alignSource(im_obj2, objmask2, im_bg2, center_x2, bottom_y2, padding);
mask_s2 = im2double(mask_s2);
result2 = cut_and_paste(im_bg2, im_s2, mask_s2);
figure; montage({im_bg2, im_obj2, mask_s2, result2});
title('Image Set 2: Orange and Apple');

% Image Set 3: Eye and Hand (placeholder)
% im_bg3 = im2double(imread('hand.jpg'));
% im_obj3 = im2double(imread('eye.jpg'));
% [Add your coordinates here]
% [Repeat the same pattern as above]

% Image Set 4: Your choice (placeholder)
% [Add your images and coordinates here]

% Image Set 5: Personal photos (placeholder)
% [Add your personal images and coordinates here]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Blending function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function im_cut_and_paste = cut_and_paste(im_bg, im_s, mask_s)
    m3 = cat(3, mask_s, mask_s, mask_s);
    im_cut_and_paste = im_bg .* (1 - m3) + im_s .* m3;
end


function [poly_x, poly_y] = getPolygonForMask(im)
    % Asks user to draw polygon around input image.  
    disp('Draw polygon around source object in clockwise order, q to stop');
    fig=figure; hold off; imagesc(im); axis image;
    poly_x = [];
    poly_y = [];
    while 1
        figure(fig)
        [x, y, b] = ginput(1);
        if b=='q'
            break;
        end
        poly_x(end+1) = x;
        poly_y(end+1) = y;
        hold on; plot(poly_x, poly_y, '*-');
    end
    close(fig);
end


function [center_x, bottom_y] = getBottomCenterLoc(im_t)
    disp('choose target bottom-center location');
    fig=figure; hold off; imagesc(im_t); axis image;
    figure(fig)
    [center_x, bottom_y, ~] = ginput(1);
    close(fig);
end


function [im_s2, mask2] = alignSource(im_s, mask, im_t, center_x, bottom_y, padding)
    % Inputs:  source image, mask, target/background image, ...
    % center_x, bottom_y are the coordinates of the bottom center location on the target image
    % padding is the number of extra rows/coumns to include around the
    % object to allow for feathering/blending.
    % Outputs: an aligned source image and also an aligned blending mask.
    
    % find the bounding box of the mask, and enlarge it by the amount of
    % padding
    [y, x] = find(mask);
    y1 = min(y)-1-padding; y2 = max(y)+1+padding; 
    x1 = min(x)-1-padding; x2 = max(x)+1+padding;
    im_s2 = zeros(size(im_t));

    yind = (y1:y2);
    yind2 = yind - max(y) + round(bottom_y);
    xind = (x1:x2);
    xind2 = xind - round(mean(x)) + round(center_x);
    
    % if the padding exceeds the image boundaries,
    % clip to image boundary
    yind(yind > size(im_s, 1)) = size(im_s, 1);
    yind(yind < 1) = 1;
    xind(xind > size(im_s, 2)) = size(im_s, 2);
    xind(xind < 1) = 1;
   
    yind2(yind2 > size(im_t, 1)) = size(im_t, 1);
    yind2(yind2 < 1) = 1;
    xind2(xind2 > size(im_t, 2)) = size(im_t, 2);
    xind2(xind2 < 1) = 1;

    y = y - max(y) + round(bottom_y);
    x = x - round(mean(x)) + round(center_x);
    ind = y + (x-1)*size(im_t, 1);
    mask2 = false(size(im_t, 1), size(im_t, 2));
    mask2(ind) = true;
    
    im_s2(yind2, xind2, :) = im_s(yind, xind, :);    
end