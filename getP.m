function V2X = getP(V2X,DSRC,LTE,NR)
    % 计算概率
    ptd=0.3;              %道路上发射机为DSRC的概率
    ptl=0.5;              %道路上发射机为LTE的概率
    ptn=0.2;              %道路上发射机为NR的概率
    if ptd+ptl+ptn ~= 1
        disp('[Error]ptd+ptl+ptn!=1');
    end

    % 确定采用通信协议
    t = rand();
    if t < ptd
        V2X.protocol = DSRC;
    elseif t < ptd + ptl
        V2X.protocol = LTE;
    elseif t < ptd + ptl + ptn
        V2X.protocol = NR;
    end
end

