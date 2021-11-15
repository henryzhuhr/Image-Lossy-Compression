clc;clear all;

quality_scale = 0.5; % 0-1之间的值，用来指定压缩的质量 
% im=imread('mavic3.tiff');
im=imread('lena512color.tiff');
imwrite(uint8( im),'../docs/pages/jpeg/origin.jpg');
[h,w,~] = size(im);

%% 像素值转为yuv
% YCbCr是一种经过矫正，特殊的YUV，这里使用的是BT.601-4标准
im_yuv = func_rgb2yuv(im);
imwrite(uint8( im_yuv(:,:,1)),'../docs/pages/jpeg/yuv-y.jpg');
imwrite(uint8( im_yuv(:,:,2)),'../docs/pages/jpeg/yuv-u.jpg');
imwrite(uint8( im_yuv(:,:,3)),'../docs/pages/jpeg/yuv-v.jpg');

%% 对色度图像二次采样
% YUV有三种采集方式
% 4:4:4采样：每一个Y对应一个U和一个V。大小为3*width*height（width和height是一帧的大小）。
% 4:2:2采样：每两个Y共用一对U和V。大小为2*width*height（其中U分量和V分量各占1/2个帧大小）。
% 4:2:0采样：每四个Y共用一对U和V。大小为3/2*width*height（其中U分量和V分量各占1/4个帧大小）
im_yuv = func_subsampling_420( im_yuv);
imwrite(uint8( im_yuv(:,:,1)),'../docs/pages/jpeg/yuv420-y.jpg');
imwrite(uint8( im_yuv(:,:,2)),'../docs/pages/jpeg/yuv420-u.jpg');
imwrite(uint8( im_yuv(:,:,3)),'../docs/pages/jpeg/yuv420-v.jpg');

%% 对图像分块8*8并DCT变换
im_dct = func_dct(im_yuv);

%% 量化 丢弃不显著信息分块
% 使用JPEG2000推荐的标准亮度量化表和标准色差量化表
quantified =  func_quantization(im_dct,quality_scale);
% figure; imshow( uint8( im_dct(:,:,1))); title('分块DCT结果');
imwrite(uint8( im_dct(:,:,1)),'../docs/pages/jpeg/block.jpg');
% figure; imshow( uint8(quantified(:,:,1))); title('量化结果');
imwrite(uint8( quantified(:,:,1)),'../docs/pages/jpeg/block-quantify.jpg');

%% zigzag
% 对每个8*8块进行z形编码，形成一个64*1的向量
% 需要对y,cb,cr三个通道中进行操作，所以这一步会生成64*4096*3的矩阵
zigzag=[ 1  2  9 17 10  3  4 11
        18 25 33 26 19 12  5  6
        13 20 27 34 41 49 42 35 
        28 21 14  7  8 15 22 29
        36 43 50 57 58 51 44 37
        30 23 16 24 31 38 45 52
        59 60 53 46 39 32 40 47
        54 61 62 55 48 56 63 64];
order = reshape(zigzag',1,64);
for i=1:3
    ch = quantified(:,:,i);
    % im2col()可将每个8*8子块展成一个列向量，再将不同子块生成的列向量拼在一起
    col_block = im2col(ch, [8 8], 'distinct');
    after_zigzag(:,:,i) = col_block(order,:);
end

%% rlc
% 把64*4096*3的数据中每个通道的数据排成一列，转换为26214*3的数据，再对每个通道分别做游程编码
% （值，出现次数）分别存在rlc_count_和rlc_value_中
% 每个通道被编码为count、value两个分量，一共三个通道，所以一共有6个分量
col_vec_y = after_zigzag(:,:,1);
col_vec_y = col_vec_y(:);
col_vec_cb = after_zigzag(:,:,2);
col_vec_cb = col_vec_cb(:);
col_vec_cr = after_zigzag(:,:,3);
col_vec_cr = col_vec_cr(:);
[rlc_count_y,rlc_value_y] = rlc_enc(col_vec_y);
[rlc_count_cb,rlc_value_cb] = rlc_enc(col_vec_cb);
[rlc_count_cr,rlc_value_cr] = rlc_enc(col_vec_cr);

% 计算一下做完rlc的压缩情况
% count分量中的每个数字取值范围是[1,63]，可以用uint8存储
% value分量里存在负数，但能取到的值远小于256个，可以简单地加上一个偏移，再用uint8存储
% 总之，这里用到的变量个数*8即为RLC压缩后所需比特数
% 当quality_scale=0.5，RLC编码后压缩比达到10左右

uint8_count=size(rlc_count_y,2)+size(rlc_count_cb,2)+size(rlc_count_cr,2) * 2;
bitcost_rlc = uint8_count*8;
ratio_rlc = h*w*3*8 / bitcost_rlc;

%% huffman
% 对游程编码的6个分量分别做哈夫曼编码
% 以rlc_value_y分量为例，HC_Struct_value_y.HC_codes存储了编码表，HC_Struct_value_y.HC_tabENC存储了原始数据编码后的结果
% ALL_CELL 存储了（原符号 | 哈夫曼编码后的符号 | 该符号出现次数）
% MEAN_LEN 存储了平均码长
HC_Struct_count_y = whuffencode(rlc_count_y);
HC_Struct_count_cb = whuffencode(rlc_count_cb);
HC_Struct_count_cr = whuffencode(rlc_count_cr);

[HC_Struct_value_y, ALL_CELL,~,~,MEAN_LEN] = whuffencode(rlc_value_y);
HC_Struct_value_cb = whuffencode(rlc_value_cb);
HC_Struct_value_cr = whuffencode(rlc_value_cr);

%% inverse_huffman
% 编码函数会自动给原序列加上一个偏移值，使得送入编码器的序列不存在负数和0。所以解码时则需要将整个序列 + min(rlc_count_y) - 1
huffdecoded_count_y = whuffdecode(HC_Struct_count_y.HC_codes, HC_Struct_count_y.HC_tabENC) + min(rlc_count_y) - 1; 
huffdecoded_count_cb = whuffdecode(HC_Struct_count_cb.HC_codes, HC_Struct_count_cb.HC_tabENC) + min(rlc_count_cb) - 1; 
huffdecoded_count_cr = whuffdecode(HC_Struct_count_cr.HC_codes, HC_Struct_count_cr.HC_tabENC) + min(rlc_count_cr) - 1; 

huffdecoded_value_y = whuffdecode(HC_Struct_value_y.HC_codes, HC_Struct_value_y.HC_tabENC) + min(rlc_value_y) - 1; 
huffdecoded_value_cb = whuffdecode(HC_Struct_value_cb.HC_codes, HC_Struct_value_cb.HC_tabENC) + min(rlc_value_cb) - 1; 
huffdecoded_value_cr = whuffdecode(HC_Struct_value_cr.HC_codes, HC_Struct_value_cr.HC_tabENC) + min(rlc_value_cr) - 1; 

% 计算一下做完huffman的压缩情况
% HC_tabENC内存放的是二进制序列，求其长度则可获得编码所需比特数
% 当quality_scale=0.5，哈夫曼编码后压缩比达到16左右
bitcost_huffman = length(HC_Struct_count_y.HC_tabENC) + length(HC_Struct_count_cb.HC_tabENC)+ length(HC_Struct_count_cr.HC_tabENC) ...
+ length(HC_Struct_value_y.HC_tabENC) + length(HC_Struct_value_cb.HC_tabENC) + length(HC_Struct_value_cr.HC_tabENC);
ratio_huffman = h*w*3*8 / bitcost_huffman

%% inverse_rlc
inverse_rlc_y = rlc_dec(huffdecoded_count_y,huffdecoded_value_y);
inverse_rlc_y = reshape(inverse_rlc_y, size(after_zigzag(:,:,1),1), size(after_zigzag(:,:,1),2));
inverse_rlc_cb = rlc_dec(huffdecoded_count_cb,huffdecoded_value_cb);
inverse_rlc_cb = reshape(inverse_rlc_cb, size(after_zigzag(:,:,1),1), size(after_zigzag(:,:,1),2));
inverse_rlc_cr = rlc_dec(huffdecoded_count_cr,huffdecoded_value_cr);
inverse_rlc_cr = reshape(inverse_rlc_cr, size(after_zigzag(:,:,1),1), size(after_zigzag(:,:,1),2));
inverse_rlc = cat(3,inverse_rlc_y,inverse_rlc_cb,inverse_rlc_cr);

%% inverse_zigzag
rev = zeros(1,64);
for k = 1:length(order)
    rev(k) = find(order==k);
end

for i=1:3
    ch = inverse_rlc(:,:,i);
    rearrange = ch(rev,:);
    inverse_zigzag(:,:,i) = col2im(rearrange, [8 8], [h w], 'distinct');
end

%% inverse_quantization
iquantified = func_iquantization(inverse_zigzag, quality_scale);

%% IDCT
im_idct = func_idct(iquantified);

%% yuv->rgb
rgb = uint8(func_yuv2rgb( im_idct));
figure; imshow(rgb);
title('恢复结果'); 

%% 评价
% 用MSE,PSNR，SSIM评估压缩结果
[MSE,PSNR,SSIM] = evaluation(im,rgb)

% 使用matlab自带jpeg压缩器压缩原图，求其压缩比
imwrite(im,'lena.jpg','jpg');
jpg_info = imfinfo('lena.jpg'); 
jpg_size = jpg_info.FileSize; % BYTE before
tiff_info = imfinfo('lena512color.tiff');
tiff_size = tiff_info.FileSize; % BYTE after
ratio_by_matlab = tiff_size/jpg_size
% 用matlab自带jpeg压缩器得到了20.8154左右的压缩比
% 我们的仿真实验在quality_scale=0.5时达到16.2577，在quality_scale=0时达到20.9555，代价是MSE略有增大

