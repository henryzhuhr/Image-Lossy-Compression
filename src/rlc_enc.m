function  [c,v] = rlc_enc(in)
    % 游程编码，当前值与后一个值相等则计数+1，否则将该值与该值出现的次数分别写入v(value)和c(count)
    one_col = in;
    j=1;
    a=length(one_col);
    count=0;
    for n=1:a
        b=one_col(n);
        if n==a
            count=count+1;
            c(j)=count;
            v(j)=one_col(n);
        elseif one_col(n)==one_col(n+1)
            count=count+1;
        elseif one_col(n)==b
            count=count+1;
            c(j)=count;
            v(j)=one_col(n);
            j=j+1;
            count=0;
        end
    end
end