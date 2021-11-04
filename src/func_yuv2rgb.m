function out = func_yuv2rgb( im)
    im = double(im); %uint8无符号，-128成负数丢失，图像显紫
    out(:,:,1) = im(:,:,1) + 1.4075*(im(:,:,3)-128);
    out(:,:,2) = im(:,:,1) - 0.3455*(im(:,:,2)-128) -0.7169*(im(:,:,3)-128);
    out(:,:,3) = im(:,:,1) + 1.779 *(im(:,:,2)-128);
    out = uint8(out);
end
