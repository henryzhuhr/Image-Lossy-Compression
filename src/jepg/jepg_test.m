%% run in src
% pwd


%% read image
image=imread('./images/708947708.jpg');
% figure; 
% imshow(image);
% title('image-src');
% mkdir('jpeg-result')
% imwrite(image,'jpeg-result/image-src.jpg','jpg');

%% RGB -> YCbCr
image_yuv=func_rgb2yuv(image); 
% image_yuv = func_subsampling_420(image_yuv);

%% DCT test
% X=rand(8,8,3);
% X
% Y=func_DCT(X);
% Y


%% image DCT
image_dct=func_DCT(image_yuv)

