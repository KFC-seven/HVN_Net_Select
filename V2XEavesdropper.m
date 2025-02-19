classdef V2XEavesdropper
    properties
        x;
        y;
        id;                 %id
        ro;                 %当前节点到原点的距离
        h;                  %信道增益
        G;                  %发射增益
        Pt=0.2;             %发射功率（23dbm）
        protocol;            %采用的通信协议
        ms;                 %行驶速度
        moveDirection;      %移动方向
        LOS;                %连接是否是LOS
    end
    methods
        % 构造函数
        function obj = V2XEavesdropper(x, y)
            obj.x = x;
            obj.y = y;
            % obj.ms=randi([30,60]);
            obj.ro=sqrt(x^2+y^2);
        end
    end
end