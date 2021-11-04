function out = func_idct( im_dct)
    T = dctmtx(8); 
    for i=1:3
        out(:,:,i) = blkproc(im_dct(:,:,i), [8 8], 'P1*x*P2', T', T);
    end
end