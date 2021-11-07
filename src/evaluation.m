% A: before(tiff)  B: after(jpeg) 
function [MSE,PSNR,SSIM] = evaluation(A,B)
    [m,n]=size(A);
    MSE=sum(sum(sum((B-A).^2)))/(m*n*3);
    PSNR=20*log10(255/sqrt(MSE));
    SSIM = ssim(B,A);
end