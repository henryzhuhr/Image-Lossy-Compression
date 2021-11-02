% A: before(bmp)  B: after(jpeg) 
% input PATH
function [MSE,PSNR,ratio,SSIM] = evaluation(A_path,B_path)
    A = imread(A_path);
    A_info=imfinfo(A_path); 
    A_size = A_info.FileSize; % BYTE before
    B = imread(B_path);
    B_info=imfinfo(B_path);
    B_size = B_info.FileSize; % BYTE after
    [m,n]=size(A);
    MSE=sum(sum(sum((B-A).^2)))/(m*n*3);
    PSNR=20*log10(255/sqrt(MSE));
    ratio = A_size/B_size;
    SSIM = ssim(B,A); % out of memory
end