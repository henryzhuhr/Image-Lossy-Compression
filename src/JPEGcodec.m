clc;clear;
quality_scale = 0.5; % 0-1之间的值，用来指定压缩的质量 

image=imread('lena512color.tiff');
figure; imshow( image);
title('原图'); % 显示原图
[h,w,~] = size(image);

%% 像素值转为yuv
% YCbCr是一种经过矫正，特殊的YUV，这里使用的是BT.601-4标准
image_yuv = func_rgb2yuv(image);

%% 对色度图像二次采样
% YUV有三种采集方式
% 4:4:4采样：每一个Y对应一个U和一个V。大小为3*width*height（width和height是一帧的大小）。
% 4:2:2采样：每两个Y共用一对U和V。大小为2*width*height（其中U分量和V分量各占1/2个帧大小）。
% 4:2:0采样：每四个Y共用一对U和V。大小为3/2*width*height（其中U分量和V分量各站1/4个帧大小）
image_yuv = func_subsampling_420( image_yuv);
% figure; imshow( func_yuv2rgb( im_yuv));
% title('二次采样'); % 显示二次采样图

%% 对图像分块8*8并DCT变换
im_dct = func_dct(image_yuv);

%% 量化 丢弃不显著信息分块
% 使用JPEG2000推荐的标准亮度量化表和标准色差量化表
quantified =  func_quantization(image_dct,quality_scale);
figure; imshow( uint8( image_dct(:,:,1))); title('分块DCT结果');
figure; imshow( uint8(quantified(:,:,1))); title('量化结果');

%% zigzag
% z形编码，im2col()可将每个8*8子块展成一个列向量，再拼成一个矩阵
zigzag=[1 2 9 17 10 3 4 11
        18 25 33 26 19 12 5 6
        13 20 27 34 41 49 42 35 
        28 21 14 7 8 15 22 29
        36 43 50 57 58 51 44 37
        30 23 16 24 31 38 45 52
        59 60 53 46 39 32 40 47
        54 61 62 55 48 56 63 64];
order = reshape(zigzag',1,64);
for i=1:3
    ch = quantified(:,:,i);
    col_block = im2col(ch, [8 8], 'distinct');
    after_zigzag(:,:,i) = col_block(order,:);
end


%% inverse_zigzag
rev = zeros(1,64);
for k = 1:length(order)
    rev(k) = find(order==k);
end

for i=1:3
    ch = after_zigzag(:,:,i);
    rearrange = ch(rev,:);
    inverse_zigzag(:,:,i) = col2im(rearrange, [8 8], [h w], 'distinct');
end

%% 反量化
iquantified = func_iquantization(inverse_zigzag, quality_scale);

%% IDCT
image_idct = func_idct(iquantified);

%% yuv->rgb
rgb = uint8(func_yuv2rgb( image_idct));
figure; imshow(rgb);
title('恢复结果'); 
imwrite(rgb,'lena.jpg','jpg');

%% 评价指标
A_path = "lena512color.tiff";
B_path = "lena.jpg";
[MSE,PSNR,ratio,SSIM] = evaluation(A_path,B_path)