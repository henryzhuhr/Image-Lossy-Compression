function  out = func_quality( im_dct)
    mask = [
        1   1   1   1   0   0   0   0
        1   1   1   0   0   0   0   0
        1   1   0   0   0   0   0   0
        1   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];
    for i=1:3
        out(:,:,i) = blkproc(im_dct(:,:,i), [8 8], 'P1.*x', mask);
    end
end