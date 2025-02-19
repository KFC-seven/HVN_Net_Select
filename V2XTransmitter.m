classdef V2XTransmitter
    properties
        x;
        y;
        id;                 %id
        ro;                 %当前节点到原点的距离
        h;                  %信道增益
        G;                  %发射增益
        Pt=0.2;             %发射功率（23dbm）
        protocol;           %采用的通信协议
        cop;                %连接中断概率
        sop;                %保密中断概率
        ms;                 %移动速度
        rss;                %信号接收强度
        moveDirection;      %移动方向
        delay;              %时延
        bandwidth;          %带宽
        plr;                %丢包率
        jitter;             %抖动
        ber;                %误码率
        cost;               %网络开销
        ee;                 %能耗
        RecomScore;         %评估得分
        RsThres;            %评估阈值
        LOS;                %连接是否是LOS
    end
    methods
        % 构造函数
        function obj = V2XTransmitter(x, y)
            obj.x = x;
            obj.y = y;
            % obj.ms=randi([30,60]);
            obj.ro=sqrt(x^2+y^2);
        end
    end
end