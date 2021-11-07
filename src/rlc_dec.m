function  out = rlc_dec(c,v)
    c_one_col = c;
    v_one_col = v;

    g=length(v_one_col);
    j=1;
    l=1;
    for i=1:g
        if c_one_col(j)~=0
            for p=1:c_one_col(j)
                out(l)=v_one_col(j);
                l=l+1;
            end
        end
        j=j+1;
    end
end