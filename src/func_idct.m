function out = func_idct( im_dct)
    T = dctmtx(8); % 8*8DCT变换矩阵
    for i=1:3
        % 分块8*8 每个块进行IDCT变换 T转置*块*T
        out(:,:,i) = blkproc( im_dct(:,:,i), [8 8], 'P1*x*P2', T', T);
    end
end