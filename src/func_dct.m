function out = func_dct( im)
    T = dctmtx(8); % 8*8DCT变换矩阵
    for i=1:3
        % 分块8*8 每个块进行DCT变换 T*块*T转置
        out(:,:,i) = blkproc( im(:,:,i), [8 8], 'P1*x*P2', T, T');
    end
end