classdef BS
    properties
        x;  
        y;
        id;                 %候选节点id
        ro;                 %当前节点到原点的距离
        theta;              %角度
        h;                  %信道增益
        G;                  %发射增益
        Pt=40;              %发射功率（46dbm）
        protocol;           %采用的通信协议
        cop;                %连接中断概率
        sop;                %保密中断概率
        ms=0;               %移动速度
        rss;                %信号接收强度
        delay;              %时延
        bandwidth;          %带宽
        plr;                %每百万丢包率
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
        function obj = BS(theta, ro, xx0, yy0)
            obj.theta = theta;
            obj.ro = ro;
            [xx, yy] = pol2cart(theta, ro);
            obj.x = xx+xx0;
            obj.y = yy+yy0;
        end
    end
end