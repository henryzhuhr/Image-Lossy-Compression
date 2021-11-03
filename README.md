# 图像有损压缩(Image Lossy Compression)
- [图像有损压缩(Image Lossy Compression)](#图像有损压缩image-lossy-compression)
- [背景](#背景)
- [JPEG图像压缩算法原理](#jpeg图像压缩算法原理)
  - [1. 颜色空间转换及色度采样](#1-颜色空间转换及色度采样)
    - [色彩空间转换](#色彩空间转换)
  - [色度采样](#色度采样)
  - [2. DCT变换](#2-dct变换)
    - [DCT 离散余弦变换](#dct-离散余弦变换)
    - [JPEG中的DCT](#jpeg中的dct)
  - [量化](#量化)
  - [DC和AC分量编码](#dc和ac分量编码)
  - [熵编码](#熵编码)
- [结果](#结果)
  - [评价指标](#评价指标)
- [参考资料](#参考资料)

# 背景

1min 4k30fps 的视频，每帧图像大小 3840 × 2180 × 3 = 24.3 MB ， 1min 视频 3840 × 2180 × 3 × 30 × 60 = 42.7 GB

常用的视频编码流程

input -> 映射 -> 量化 -> 压缩编码


# JPEG图像压缩算法原理
input -> 采样 -> 分块 -> DCT  -> 量化 （Z形扫描） -> DC差分 -> AC RLC -> Huffman -> output


将图像分为若干 $8 \times 8 \neq 0$ 大小的子块，如果不是8x8的整数倍，需在边界进行补充
## 1. 颜色空间转换及色度采样
### 色彩空间转换
<!-- 将YUV分成8x8的小块，对于每个小块做2D的DCT转换到频率空间，通常将0~255的空间映射到-128~127这样一个比较对称的空间，然后DCT变换取整。DCT其实就是将空间域转换到频率域，这样可以使得能量更加集中，方便之后的去除高频部分，有的人认为转换就已经进行了压缩，而转换其实也方便了后面的处理和运算。 -->


需要将 RGB 颜色空间转化为 YUV 颜色空间，也叫 YCbCr，其中，Y 是亮度 (Luminance)，U 和 V 表示色度 (Chrominance) 和浓度 (Chroma)，UV 分量同时表示色差

研究表明，红绿蓝三基色所贡献的亮度不同，绿色所贡献亮度最多，蓝色所贡献亮度最少。假定红色贡献为 $K_R$，蓝色贡献为 $K_B$，则亮度可以表示为
$$\begin{aligned}
    Y = K_R \cdot R + (1-K_R-K_B) \cdot G + K_B \cdot B
\end{aligned}$$

根据经验值 $K_R=0.299, K_B=0.114$，则有
$$\begin{aligned}
    Y = 0.299 \cdot R + 0.587 \cdot G + 0.114 \cdot B
\end{aligned}$$

蓝色和红色的色差为
$$\begin{aligned}
    Y   &= 0.299   \cdot R + 0.587    \cdot G + 0.114 \cdot B \\
    C_b &= -0.1687 \cdot R - 0.3313   \cdot G + 0.5 \cdot B +128\\
    C_r &= 0.5   \cdot R - 0.4187   \cdot G - 0.0813 \cdot B +128\\
\end{aligned}$$
或
$$\begin{aligned}
    \begin{bmatrix}
        Y \\ U \\ V
    \end{bmatrix}
    =\begin{bmatrix}
        0.299   & 0.587    & 0.114 & \\
        -0.1687 & -0.3313   & 0.5 & \\
        0.5     & -0.4187   & -0.0813 &
    \end{bmatrix}
    \begin{bmatrix}
        R \\ G \\ B
    \end{bmatrix}
    +\begin{bmatrix}
        0 \\ 128 \\ 128
    \end{bmatrix}
\end{aligned}$$

## 色度采样

## 2. DCT变换
### DCT 离散余弦变换

将一系列离散的一维数据 $[x_0,x_1,...,x_n]$ 分解为一系列
$$\begin{aligned}
    \begin{bmatrix}
        x_0 \\ x_1 \\ x_2 \\ ... \\ x_{n-1}
    \end{bmatrix}
    = \frac{F_0}{n}
    \begin{bmatrix}
        1 \\ 1 \\ 1 \\ ... \\ 1
    \end{bmatrix}
    +
    \sum_{k=1}^{n-1} \frac{2F_k}{n}
    \begin{bmatrix}
        \cos\frac{k}{2n}\pi \\
        \cos\frac{2k}{2n}\pi \\
        \cos\frac{3k}{2n}\pi \\
        ... \\
        \cos\frac{(2n-1)k}{2n}\pi
    \end{bmatrix}
\end{aligned}$$

其中，变换系数 $F_m$ 为
$$\begin{aligned}
    F_m=\sum_{k=0}^{n-1} x_k \cos[\frac{\pi}{n}m(k+\frac{1}{2})],\quad m=0,1,...,n-1
\end{aligned}$$


一般的二维DCT变换
$$\begin{aligned}
    F(u,v) &=c(u)c(v) \sum_{i=0}^{M-1} \sum_{j=0}^{N-1} f(i,j) \cos(\frac{i+0.5}{M}u\pi) \cos(\frac{j+0.5}{N}u\pi) \\
    c(u) &=\left\{\begin{aligned}
        & \sqrt{\frac{1}{N}}, & \quad u=0 \\
        & \sqrt{\frac{2}{N}}, & \quad u\neq 0
    \end{aligned}\right.
    \quad u,v=0,1,2,...,7
\end{aligned}$$
当 $M=N$ 时， DCT 变换可以表示为矩阵相乘的形式， $F$ 的 DCT 变换则是 $T=AFA^T$。变换矩阵 $A$ 为
$$\begin{aligned}
    A=\frac{2}{\sqrt{N}}
    \begin{bmatrix}
        \frac{1}{\sqrt{2}}      & \frac{1}{\sqrt{2}}        & ...   & \frac{1}{\sqrt{2}} \\
        \cos\frac{\pi}{2N}      & \cos\frac{3\pi}{2N}       & ...   & \cos\frac{(2N-1)\pi}{2N} \\
        ...                     & ...                       &       & ... \\
        \cos\frac{(N-1)\pi}{2N} & \cos\frac{3(N-1)\pi}{2N}  & ...   & \cos\frac{(2N-1)(N-1)\pi}{2N}
    \end{bmatrix}
\end{aligned}$$

### JPEG中的DCT
当原始图像从 RGB 颜色空间转换到 YCbCr 颜色空间之后，需要对每一个 $8 \times 8$ 的图像块进行二维DCT变换
$$\begin{aligned}
    F(u,v) &=c(u)c(v) \sum_{i=0}^{7} \sum_{j=0}^{7} f(i,j) \cos(\frac{i+0.5}{8}u\pi) \cos(\frac{j+0.5}{8}u\pi) \\
    c(u) &=\left\{\begin{aligned}
        & \sqrt{\frac{1}{8}},   & \quad u=0 \\
        & \frac{1}{2},          & \quad u\neq 0
    \end{aligned}\right.
    \quad u,v=0,1,2,...,7
\end{aligned}$$

这时候的 DCT 变换矩阵为
$$\begin{aligned}
    A=\frac{1}{\sqrt{2}}
    \begin{bmatrix}
        \frac{1}{\sqrt{2}}      & \frac{1}{\sqrt{2}}        & ...   & \frac{1}{\sqrt{2}} \\
        \cos\frac{\pi}{16}      & \cos\frac{3\pi}{16}       & ...   & \cos\frac{(16-1)\pi}{16} \\
        ...                     & ...                       &       & ... \\
        \cos\frac{(N-1)\pi}{16} & \cos\frac{3(N-1)\pi}{16}  & ...   & \cos\frac{(16-1)(N-1)\pi}{16}
    \end{bmatrix}
\end{aligned}$$

在 Matlab 中可以用 `T = dctmtx(8)` 查看
```Matlab
T =
    0.3536    0.3536    0.3536    0.3536    0.3536    0.3536    0.3536    0.3536
    0.4904    0.4157    0.2778    0.0975   -0.0975   -0.2778   -0.4157   -0.4904
    0.4619    0.1913   -0.1913   -0.4619   -0.4619   -0.1913    0.1913    0.4619
    0.4157   -0.0975   -0.4904   -0.2778    0.2778    0.4904    0.0975   -0.4157
    0.3536   -0.3536   -0.3536    0.3536    0.3536   -0.3536   -0.3536    0.3536
    0.2778   -0.4904    0.0975    0.4157   -0.4157   -0.0975    0.4904   -0.2778
    0.1913   -0.4619    0.4619   -0.1913   -0.1913    0.4619   -0.4619    0.1913
    0.0975   -0.2778    0.4157   -0.4904    0.4904   -0.4157    0.2778   -0.0975
```

## 量化
量化的目的是为了丢弃不显著信息分块



标准亮度分量量化表
```c
static const unsigned int std_luminance_quant_tbl[DCTSIZE2] = {
    16,  11,  10,  16,  24,  40,  51,  61,
    12,  12,  14,  19,  26,  58,  60,  55,
    14,  13,  16,  24,  40,  57,  69,  56,
    14,  17,  22,  29,  51,  87,  80,  62,
    18,  22,  37,  56,  68, 109, 103,  77,
    24,  35,  55,  64,  81, 104, 113,  92,
    49,  64,  78,  87, 103, 121, 120, 101,
    72,  92,  95,  98, 112, 100, 103,  99
};
```

标准色度分量量化表
```c
static const unsigned int std_chrominance_quant_tbl[DCTSIZE2] = {
    17,  18,  24,  47,  99,  99,  99,  99,
    18,  21,  26,  66,  99,  99,  99,  99,
    24,  26,  56,  99,  99,  99,  99,  99,
    47,  66,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99
};
```
量化表搞掉了很多高频量，对DCT变换进行量化后得到量化结果，会出现大量的0，使用Z形扫描，可以将大量的0连到一起，减小编码后的大小。越偏离左上方，表示频率越高，这里其实是通过量化，将图像的高频信息干掉了。

## DC和AC分量编码
DC进行DPCM编码，AC进行RLC编码，这两种编码都有中间格式，进一步减小存储量，原理可自行wiki

## 熵编码
在得到DC系数的中间格式和AC系数的中间格式之后，为进一步压缩图像数据，有必要对两者进行熵编码，通过对出现概率较高的字符采用较小的bit数编码达到压缩的目的。JPEG标准具体规定了两种熵编码方式：Huffman编码和算术编码。JPEG基本系统规定采用Huffman编码。

Huffman编码：对出现概率大的字符分配字符长度较短的二进制编码，对出现概率小的字符分配字符长度较长的二进制编码，从而使得字符的平均编码长度最短。Huffman编码的原理请参考数据结构中的Huffman树或者最优二叉树。

Huffman编码时DC系数与AC系数分别采用不同的Huffman编码表，对于亮度和色度也采用不同的Huffman编码表。因此，需要4张Huffman编码表才能完成熵编码的工作。具体的Huffman编码采用查表的方式来高效地完成。然而，在JPEG标准中没有定义缺省的Huffman表，用户可以根据实际应用自由选择，也可以使用JPEG标准推荐的Huffman表。或者预先定义一个通用的Huffman表，也可以针对一副特定的图像，在压缩编码前通过搜集其统计特征来计算Huffman表的值。

# 结果
## 评价指标
- 图像质量：客观和主观。主观就是用人去观察评分；客观就是对压缩还原后的图像与原始图像误差进行定量计算。一般都是进行某种平均，得到均方误差；另一种是信噪比。
- 压缩效果：压缩比=原始图像每像素的比特数同压缩后图像每像素的比特数的比值。

# 参考资料
- [Difference between Lossy and Lossless Compression](https://www.thecrazyprogrammer.com/2019/12/lossy-and-lossless-compression.html)
- [JPEG算法解密](https://thecodeway.com/blog/?tag=%e5%8e%8b%e7%bc%a9)
- [数字图像处理（八）图像压缩-有损压缩/压缩算法+matlab](https://blog.csdn.net/packdge_black/article/details/107230600)
- [基于DCT变换的JPEG图像压缩原理](https://blog.csdn.net/lxj_bsplee/article/details/53215077)