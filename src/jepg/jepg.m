close all;
clear all;
clc;

%% read image
image = imread('./images/708947708.jpg');

mkdir('jepg-result')
imwrite(image, 'jepg-result/image-src.jpg', 'jpg');

% figure;
% imshow(image);
% title('image-src');

%%
[M, N, C] = size(image);

image_yuv=rgb2ycbcr(image);

image_dct=image_yuv;
T = dctmtx(8); % 8*8DCT变换矩阵
func = @(block_struct) T*block_struct*T';

for channel=1:3
    image_dct(:,:,channel)=blockproc(image_yuv(:,:,channel),[8 8],func);
end
