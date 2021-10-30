%% run in src
pwd

%% read image
image=imread('./images/708947708.jpg');
figure; 
imshow(image);
title('image-src');
mkdir('jpeg-result')
imwrite(image,'jpeg-result/image-src.jpg','jpg');

%% RGB -> YCbCr
image_yuv=func_rgb2yuv(image); 
