classdef TypicalVehicle
    properties
        x;
        y;
        Pt=0.2;                 %发射功率（23dbm）
        protocol;               %采用的通信协议
        moveDirection;          %移动方向
        ms;                     %行驶速度
    end
    methods
        % 构造函数
        function obj = TypicalVehicle(x, y)
            obj.x = x;
            obj.y = y;
            % obj.ms= randi([30,60]);
        end
    end
end