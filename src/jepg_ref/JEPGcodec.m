clc;clear;
%im=imread('cat.jpg');
%im=imread('d.jpg');
image=imread('lena.tif');

%% 像素值转为yuv
image_yuv = func_rgb2yuv(image);

%figure; imshow( func_yuv2rgb( im_yuv));title('原图'); % 显示原图

%% 对色度图像二次采样
%im_yuv = func_subsampling_420( im_yuv);
%figure; imshow( func_yuv2rgb( im_yuv));title('二次采样'); % 显示二次采样图

%% 对图像分块8*8并DCT变换
image_dct = func_dct(image_yuv);

%% 量化 丢弃不显著信息分块
image_dct2 = func_quality( image_dct);

dct1 = image_dct(:,:,1);
dct2 = image_dct2(:,:,1);
%figure; imshow( uint8( im_dct(:,:,1))); title('未量化dct');
%figure; imshow( uint8( im_dct2(:,:,1))); title('量化dct');
imwrite(uint8( image_dct(:,:,1)),'未量化dct.jpg','jpg');
imwrite( uint8( image_dct2(:,:,1)),'量化dct.jpg','jpg');

%% IDCT变换 显示
image_idct = func_idct( image_dct);
image_idct2 = func_idct( image_dct2);

%figure; imshow( func_yuv2rgb( im_idct));title('未量化'); % 显示IDCT结果
imwrite(func_yuv2rgb( image_idct),'未量化.jpg','jpg');

%figure; imshow( func_yuv2rgb( im_idct2));title('量化'); % 显示量化IDCT结果
imwrite(func_yuv2rgb( image_idct2),'量化.jpg','jpg');
