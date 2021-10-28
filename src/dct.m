clear;
clc;
X=round(rand(4)*10)   %产生随机矩阵
A=zeros(4);
for i=0:3
    for j=0:3
        if i==0
            a=sqrt(1/4);
        else
            a=sqrt(2/4);
        end            
        A(i+1,j+1)=a*cos(pi*(j+0.5)*i/4);
   end
end
Y=A*X*A'        %DCT变换


YY=dct2(X)      %Matlab自带的dct变换