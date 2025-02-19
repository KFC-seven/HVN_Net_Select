%% 不同类的定义
% 道路类的定义
classdef road
    properties
        theta;  %道路θ
        p;      %道路径向长度p
        q;      %道路中点到端点的距离q
        point1; %道路端点1
        point2; %道路端点2
        point3; %道路端点3  道路与小圆交线的端点
        point4; %道路端点4  道路与小圆交线的端点
        len;    %道路长度
        speed;  %道路基础速度(道路限速)
        Lden;   %道路PLP线密度λ
        Pden;   %道路对应PPP密度μ
        v2xRs=[];    %当前道路上包含的V2XR节点的集合
        v2xTs=[];    %当前道路上包含的V2XT节点的集合 
        v2xEs=[];    %当前道路上包含的V2XE节点的集合 
    end
    methods
        % 构造函数
        function obj = road(theta, p, r, xx0, yy0) %输入参数分别是道路的θ、径向长度p、圆的半径R、圆心坐标(xx0,yy0)、基准速度
            baseSpeed=[5,20,40,80,120]; %道路的基础限速
            obj.theta = theta;
            obj.p = p;
            obj.speed = baseSpeed(randi(length(baseSpeed))); %随机生成该道路限速
            obj.q = sqrt(r.^2-p.^2);   
            %计算θ的三角函数值
            sin_theta=sin(theta);
            cos_theta=cos(theta);
            %计算泊松线过程的线段端点
            obj.point1=[xx0+p.*cos_theta+obj.q.*sin_theta;yy0+p.*sin_theta-obj.q.*cos_theta];
            obj.point2=[xx0+p.*cos_theta-obj.q.*sin_theta;yy0+p.*sin_theta+obj.q.*cos_theta];
            obj.point3=[0;0];
            obj.point4=[0;0];

            %道路长度
            obj.len = sqrt((obj.point1(1)-obj.point2(1))^2 + (obj.point1(2)-obj.point2(2))^2);
            %道路线密度
            obj.Lden = obj.len/(pi*r^2);
            %道路点密度
            obj.Pden = obj.Lden/pi;
        end
    end
end

