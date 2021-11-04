function out = func_iquantization(quantified, quality_scale)
    Luminance_Quantization_Table = [
    16,  11,  10,  16,  24,  40,  51,  61;
	12,  12,  14,  19,  26,  58,  60,  55;
	14,  13,  16,  24,  40,  57,  69,  56;
	14,  17,  22,  29,  51,  87,  80,  62;
	18,  22,  37,  56,  68, 109, 103,  77;
	24,  35,  55,  64,  81, 104, 113,  92;
	49,  64,  78,  87, 103, 121, 120, 101;
	72,  92,  95,  98, 112, 100, 103,  99];
    Chrominance_Quantization_Table = [
	17,  18,  24,  47,  99,  99,  99,  99;
	18,  21,  26,  66,  99,  99,  99,  99;
	24,  26,  56,  99,  99,  99,  99,  99;
	47,  66,  99,  99,  99,  99,  99,  99;
	99,  99,  99,  99,  99,  99,  99,  99;
	99,  99,  99,  99,  99,  99,  99,  99;
	99,  99,  99,  99,  99,  99,  99,  99;
	99,  99,  99,  99,  99,  99,  99,  99];

    Luminance_Quantization_Table = Luminance_Quantization_Table * (1 - quality_scale + 0.5);
    Chrominance_Quantization_Table = Chrominance_Quantization_Table * (1 - quality_scale + 0.5);
    out(:,:,1) = blkproc(quantified(:,:,1),[8 8], 'x.*P1' ,Luminance_Quantization_Table);
    out(:,:,2) = blkproc(quantified(:,:,2),[8 8], 'x.*P1' ,Chrominance_Quantization_Table);
    out(:,:,3) = blkproc(quantified(:,:,3),[8 8], 'x.*P1' ,Chrominance_Quantization_Table);
end