function Gxy = getG(x, y)
    % 设置随机数种子为当前时间
    randn('seed',sum(100*clock));

    % 输入参数
    mu_s = 0;      % 对数正态分布的均值 (dB)

    % 城市环境下
    sigma_0_ub = 6;   % 对数正态分布的标准差 (dB)
    % 乡村环境下
    sigma_0_ru = 3;   % 对数正态分布的标准差 (dB)


    % 城市环境下对数正态分布
    S_d_ub = 10^(mu_s/10) * 10^(sigma_0_ub * randn / 10);
    
    % 乡村环境下对数正态分布
    S_d_ru = 10^(mu_s/10) * 10^(sigma_0_ru * randn / 10);
    
    S_d = S_d_ru;
    % 获取主瓣的波束宽度
    mw = y.protocol.mainLobewidth/2;

    % 计算概率
    p1 = (mw / (2 * pi))^2;
    p2 = mw * (2 * pi - mw) / ((2 * pi)^2);
    p3 = (2 * pi - mw) * mw / ((2 * pi)^2);
    p4 = ((2 * pi - mw) / (2 * pi))^2;

    if p1+p2+p3+p4<1 && p1+p2+p3+p4>1
        disp('[Error]p1+p2+p3+p4!=1');
    end

    % 确定天线增益
    t = rand();
    px=x.protocol;
    py=y.protocol;
    if t < p1
        Gxy = px.Mt * py.Mt * S_d;
    elseif t < p1 + p2
        Gxy = px.Mt * py.mt * S_d;
    elseif t < p1 + p2 + p3
        Gxy = px.mt * py.Mt * S_d;
    else
        Gxy = px.mt * py.mt * S_d;
    end
end
