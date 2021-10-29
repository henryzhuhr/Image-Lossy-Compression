function out = func_rgb2yuv( im_in)
    % rgb转yuv
    % BT.601-4标准
    im = double(im_in);
    out(:,:,1) =  0.299*im(:,:,1) + 0.587*im(:,:,2) + 0.114*im(:,:,3);
    out(:,:,2) = -0.169*im(:,:,1) - 0.331*im(:,:,2) + 0.5  *im(:,:,3) +128; % +128转到0-255
    out(:,:,3) =  0.5  *im(:,:,1) - 0.419*im(:,:,2) - 0.081*im(:,:,3) +128;
    %out = uint8(out);
end
