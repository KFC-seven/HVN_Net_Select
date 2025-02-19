%%候选网络类

classdef Candidate
    properties
        x;  
        y;
        id;                 %候选节点id
        type;               %候选节点类型
        ro;                 %当前节点到原点的距离
        theta;              %角度
        h;                  %信道增益
        G;                  %发射增益
        Pt;                 %发射功率
        protocol;           %采用的通信协议
        cop;                %连接中断概率
        sop;                %保密中断概率
        ms;                 %移动速度
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
        combinedScore;      %最终得分
        FET_Score;          %FET算法得分
        RecomScore_REMNS;   %REMNS评估得分
        RsThres_REMNS;      %REMNS评估阈值
        combinedScore_REMNS;%REMNS算法得分
    end
    methods
        % 构造函数
        function obj = Candidate(network)
            obj.x = network.x;
            obj.y = network.y;
            obj.id = network.id;
            % obj.type = network.type;
            obj.ro = network.ro;
            obj.h = network.h;                   %信道增益
            obj.G = network.G;                   %发射增益
            obj.Pt = network.Pt;                 %发射功率
            obj.protocol = network.protocol;       %采用的通信协议
            obj.cop = network.cop;               %连接中断概率
            obj.sop = network.sop;               %保密中断概率
            obj.ms = network.ms;                 %移动速度
            obj.rss = network.rss;               %信号接收强度
            obj.delay = network.delay;           %时延
            obj.bandwidth = network.bandwidth;   %带宽
            obj.plr = network.plr;               %每百万丢包率
            obj.jitter = network.jitter;         %抖动
            obj.ber = network.ber;               %误码率
            obj.cost = network.cost;             %网络开销
            obj.ee = network.ee;                 %能耗
            obj.LOS = network.LOS;               %连接是否是LOS
            
        end
    end
end