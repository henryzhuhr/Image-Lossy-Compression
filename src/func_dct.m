function out = func_dct(image)
    T = dctmtx(8); % 8*8DCT
    % dctmtx(N)可以生成N*N的DCT变换矩阵。
    % 对图像进行二维DCT变换有两种方法：
    %   1 直接使用dct2()函数。
    %   2 用dctmtx()获取DCT变换矩阵，再T×A×T'。反变换T'×A×T
    func=@(block) T*block.data*T';
    for i=1:3
        out(:,:,i) = blockproc(image(:,:,i), [8 8], func);
        % blkproc函数为分块操作函数，即对所有8*8的块执行DCT。
        % 对于不能整除的情况，会自动用0填充右边缘和下边缘，
        % 在计算结束后自动删除它们
    end
end