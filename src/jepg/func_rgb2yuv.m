function yuv = func_rgb2yuv(rgb)
    %fun - Description
    %
    % Syntax: yuv = func_rgb2yuv(rgb)
    %
    % Long description
    rgb = double(rgb);
    yuv(:, :, 1) = 0.299 * rgb(:, :, 1) + 0.587 * rgb(:, :, 2) + 0.114 * rgb(:, :, 3);
    yuv(:, :, 2) = -0.1687 * rgb(:, :, 1) - 0.331 * rgb(:, :, 2) + 0.5 * rgb(:, :, 3) + 128; % +128转到0-255
    yuv(:, :, 3) = 0.5 * rgb(:, :, 1) - 0.4187 * rgb(:, :, 2) - 0.0813 * rgb(:, :, 3) + 128;
end
