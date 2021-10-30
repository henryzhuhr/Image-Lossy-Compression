function y = func_DCT(x)
    %func_DCT - Description
    %
    % Syntax: y = func_DCT(x)
    %
    % Long description
    T = dctmtx(8); % 8*8 DCT matrix

    for channel = 1:3
        y(:, :,channel) = blockproc( x(:,:,channel), [8  8], 'P1*x*P2', T, T');
    end

end
