%% 基于PLP的车联网道路生成_获取种子图像
close all; clearvars; clc;
randn('seed',sum(100*clock));

v2xRTDensity=5;

%% 文件保存路径
figFolder=strcat('./fig/v60/',num2str(v2xRTDensity),'/');
tmpDataFolder=strcat('./tmp/v60/',num2str(v2xRTDensity),'/');

%% 通信协议参数
%DSRC协议
DSRC.beamAngle=1;           %波束角度         [-Π,Π]
DSRC.mainLobewidth=2*pi;    %主瓣的波束宽度    [-Π,Π]
DSRC.Mt=1;                  %波束主瓣增益
DSRC.mt=1;                  %波束旁瓣增益
DSRC.delay=10;              %通信时延（ms）
DSRC.delayflu=1;            %时延波动
DSRC.bandwidth=6;           %带宽（Mbps）
DSRC.bandwidthflu=1;        %带宽波动
DSRC.plr=1.5;               %丢包率
DSRC.plrflu=1;              %丢包率波动
DSRC.jitter=3;              %网络抖动
DSRC.jitterflu=1;           %网络抖动波动
DSRC.ber=0.2;               %误码率
DSRC.berflu=0.05;           %误码率抖动
DSRC.cost=3;                %网络开销
DSRC.ee=10;                 %能耗
DSRC.rss=65;				%信号接收强度
DSRC.B=10;                  %频宽MHz
DSRC.name=1;                %结构体编号
%LTE协议
LTE.beamAngle=1;            %波束角度         [-Π,Π]
LTE.mainLobewidth=2*pi;     %主瓣的波束宽度    [-Π,Π]
LTE.Mt=1;                   %波束主瓣增益
LTE.mt=1;                   %波束旁瓣增益
LTE.delay=20;               %通信时延（ms）
LTE.delayflu=2;             %时延波动
LTE.bandwidth=11.8;         %带宽（Mbps）
LTE.bandwidthflu=3;         %带宽波动
LTE.plr=4;                  %丢包率
LTE.plrflu=1;               %丢包率波动
LTE.jitter=15;              %网络抖动
LTE.jitterflu=3;            %网络抖动波动
LTE.ber=0.1;                %误码率
LTE.berflu=0.01;            %误码率抖动
LTE.cost=4;                 %网络开销
LTE.ee=5;                   %能耗
LTE.rss=65;				    %信号接收强度
LTE.B=20;                   %频宽MHz
LTE.name=2;                 %结构体编号
%NR协议
NR.beamAngle=1;             %波束角度         [-Π,Π]
NR.mainLobewidth=pi/12;     %主瓣的波束宽度    [-Π,Π]
NR.Mt=31;                   %波束主瓣增益
NR.mt=0.031;                %波束旁瓣增益
NR.delay=10;                %通信时延（ms）
NR.delayflu=2;              %时延波动
NR.bandwidth=100;           %带宽（Mbps）
NR.bandwidthflu=20;         %带宽波动
NR.plr=0.8;                 %丢包率
NR.plrflu=0.1;              %丢包率波动
NR.jitter=1;                %网络抖动
NR.jitterflu=0.1;           %网络抖动波动
NR.ber=0.05;                %误码率
NR.berflu=0.01;             %误码率抖动
NR.cost=5;                  %网络开销
NR.ee=30;                   %能耗
NR.rss=65;				    %信号接收强度
NR.B=20;                    %频宽MHz
NR.name=3;                  %结构体编号

%V2X节点速度服从正态分布的sigma
speedsigma=5;

%基本参数
beta=0.6;             %用于计算LOS和NLOS的概率
mL=4;                 %视距(LOS)环境下的衰弱参数
mN=4;                 %非视距(NLOS)环境下的衰弱参数
alpL=2.1;             %LOS路径损耗指数，一般是2~6之间
alpN=3.5;             %NLOS路径损耗指数，一般是2~6之间
ptd=0.3;              %道路上发射机为DSRC的概率
ptl=0.5;              %道路上发射机为LTE的概率
ptn=0.2;              %道路上发射机为NR的概率
mu_s = 0;             %阴影衰弱对数正态分布的均值 (dB)
sigma_0_ub = 6;       %阴影衰弱城市对数正态分布的标准差 (dB)
sigma_0_ru = 3;       %阴影衰弱乡村对数正态分布的标准差 (dB)


%%道路及节点密度参数
%道路密度
roadDensity=2;
BSDensity = 1;
ReceiverDensity = v2xRTDensity;
TransmitterDensity = v2xRTDensity;
EavesdropperDensity = 0.1;

%% 绘制运动图像参数
FrameNums=100; %绘制100帧图像
%每次更新的时间间隔，单位（秒）
timeInterval=1;
gifdel = 0.5;
gifname=figFolder+"moveBig.gif";
gifname2=figFolder+"moveSmall.gif";

vehicleSpeed=60;
%圆盘半径
smallr=1;
ddd=0.1; %间隙控制参数
bigr=vehicleSpeed/3.6/1000*FrameNums+smallr+ddd;

for FrameCount=0:FrameNums
    %v2x车辆总数
    v2xTotalNum=0;
    disp(['[+]正在绘制第',num2str(FrameCount),'帧图像']);
    %小圆中的节点
    smallv2xRs=[];
    smallv2xTs=[];
    smallv2xEs=[];
    smallBSs=[];
    if (FrameCount==0)
        %% 首先绘制初始状态图
        % 绘制圆形区域和典型车辆
        %圆盘半径
        r=bigr;
        %圆上点的数量
        circlePointNum=100000;
        %在0~2Π之间生成circlePointNum个等距的向量
        t=linspace(0,2*pi,circlePointNum); 
        
        %创建典型车辆
        %典型车辆的位置【典型车辆选为原点位置,不可随意更改】
        xx0=0;yy0=0; 
        Vehicle = TypicalVehicle(xx0,yy0);
        % 指定通信协议
        Vehicle.protocol=DSRC;
        
        %圆上点的坐标
        xc=xx0+r*cos(t); 
        yc=yy0+r*sin(t);
        %显示圆的信息
        disp('=== 初始状态-大圆 ===');
        disp(['圆的半径R:',num2str(r)]);
        disp(['圆心坐标: x:',num2str(xx0),' y:',num2str(yy0)]);

        disp(['典型车辆移动速度:',num2str(vehicleSpeed)]);
        %开始绘图
        fig1 = figure;
        fig1.Visible="off";
        set(fig1, 'position', get(0,'ScreenSize'));
        plot(xc,yc,'k'); 
        xlabel('x'); ylabel('y');
        axis square;            %设置坐标系为方型，横纵比例为1:1
        hold on;
        axis tight;
        xlim auto
        ylim auto
        % set(gca,'xtick',-1.5:0.1:1.5); 
        % set(gca,'ytick',-1.5:0.1:1.5); 
        %xticks([]);                    %去除坐标轴
        %yticks([]);
        %set(gca,'Visible','off');      %隐藏边框  
        %% 绘制道路
        %道路λ
        roadlambda=2 * pi * r * roadDensity;
        %道路数量
        roadNum=poissrnd(roadlambda);
        while(abs(roadNum/(2*pi*r) - roadDensity)>0.1)
            roadNum=poissrnd(roadlambda);
        end
        %生成道路对象
        roads=[];
        %计算道路总长度
        roadLen=0;
        for i=1:roadNum
            if i==roadNum %最后一条路需要过圆点
                theta=2*pi*rand();
                p=0;
                %生成道路对象
                ro=road(theta, p, r, xx0, yy0);
                %生成典型车辆的速度和方向
                %节点速度服从正态分布且为正
                Vehicle.ms=vehicleSpeed;
                %设定速度方向
                if (randi([0,1])==1)
                    Vehicle.moveDirection = 1;
                else
                    Vehicle.moveDirection = -1;
                end
            else
                %随机生成道路的θ和径向长度p
                theta=2*pi*rand();
                p=r*rand(); 
                %生成道路对象
                ro=road(theta, p, r, xx0, yy0);
            end
            %计算道路总长
            roadLen=roadLen+ro.len;
            %绘制当前道路
            p1=plot([ro.point1(1);ro.point2(1)],[ro.point1(2);ro.point2(2)],'k','LineWidth',1);
            hold on;
            %添加当前道路对象到roads变量中
            roads=[roads;ro];
        end
        
        roadMuk=roadLen/pi*r^2;
        %显示道路信息
        disp(['道路数量:',num2str(roadNum)]);
        disp(['道路总长:',num2str(roadLen)]);
        disp(['道路密度:',num2str(roadNum/(2*pi*r))]);
        
        
        %% 绘制典型车辆
        p2=scatter(xx0, yy0, 'k','filled','LineWidth',2);
        hold on;
        
        %% 绘制BS
        %根据BS密度在圆内随机生成BS
        
        BSlambda = pi * r^2 *BSDensity;
        BSNum = poissrnd(BSlambda);
        while(abs(BSNum/(pi * r^2) - BSDensity)>0.1)
            BSNum = poissrnd(BSlambda);
        end
        disp(['BS数量:',num2str(BSNum)]);
        disp(['BS密度:',num2str(BSNum/(pi*r^2))]);
        BSs=[];
        BSs1=[];
        BSs2=[];
        for i=1:BSNum
            %随机生成BS基站
            %随机生成BS到圆心的距离ro和夹角θ
            theta = unifrnd(0, 2*pi, 1, 1);
            ro = r * sqrt(rand());
            %生成BS对象
            bs = BS(theta, ro, xx0, yy0);
            %指定通信协议
            bs = getP(bs,DSRC,LTE,NR);
            protocol = bs.protocol;
            %计算与典型车辆的距离
            bs.ro=sqrt((bs.x-Vehicle.x)^2+(bs.y-Vehicle.y)^2);
            %计算信道H和LOS情况
            [bs.h,bs.LOS] = getH(mL,mN,beta,bs.ro);
            % 设置随机数种子为当前时间，城市环境
            randn('seed',sum(100*clock));
            S_d_ru = 10^(mu_s/10) * 10^(sigma_0_ru * randn / 10);
            S_d = S_d_ru;
            %计算天线增益，默认天线对齐
            bs.G = protocol.Mt*protocol.Mt*S_d;
            % bs.G = 1;
            % %节点速度服从正态分布且为正
            % ind = randi([1,roadNum]);
            % curroad=roads(ind);
            % while 1
            %     bs.ms=normrnd(curroad.speed,speedsigma);
            %     if bs.ms > 0 && bs.ms < 120
            %         break;
            %     end
            % end
            %生成节点时延、带宽、丢包率参数
            %参数和距离相关，alph为控制因子
            alph = 5;
            beta = 2;
            while 1
                bs.delay = exp(alph*bs.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
                bs.bandwidth = exp(-alph*bs.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                bs.plr = exp(alph*bs.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
                bs.jitter = exp(alph*bs.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
                bs.ber = exp(alph*bs.ro)+normrnd(protocol.ber,protocol.berflu)-1;
				bs.rss = protocol.rss/exp(beta*bs.ro)-130;
                bs.cost =  protocol.cost;
                bs.ee = protocol.ee;
                if bs.delay > 0 && bs.bandwidth > 0 && bs.plr >0 && bs.jitter >0 && bs.ber >0
                    break;
                end
            end
            %绘制BS
            p3=scatter(bs.x, bs.y, 60, 'blue','filled','diamond');
            hold on;
            %添加到变量中
            BSs=[BSs;bs];
        
            % %生成其余两种网络制式的BS对象
            % bs1 = bs;
            % bs2 = bs;
            % %1 2 3分别代表DSRC LTE NR
            % index = {'1', '2', '3'};
            % if protocol.name == index{1}
            %     bs1.protocol = LTE;
            %     bs2.protocol = NR;
            % elseif protocol.name == index{2}
            %     bs1.protocol = DSRC;
            %     bs2.protocol = NR;
            % elseif protocol.name == index{3}
            %     bs1.protocol = DSRC;
            %     bs2.protocol = LTE;
            % end 
            % 
            % protocol = bs1.protocol;
            % while 1
            %     bs1.delay = exp(-alph*bs1.ro)*normrnd(protocol.delay,protocol.delayflu);
            %     bs1.bandwidth = exp(-alph*bs1.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            %     bs1.plr = exp(-alph*bs1.ro)*normrnd(protocol.plr,protocol.plrflu);
            %     if bs1.delay > 0 && bs1.bandwidth > 0 && bs1.plr >0
            %         break;
            %     end
            % end
            % 
            % protocol = bs2.protocol;
            % while 1
            %     bs2.delay = exp(-alph*bs2.ro)*normrnd(protocol.delay,protocol.delayflu);
            %     bs2.bandwidth = exp(-alph*bs2.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            %     bs2.plr = exp(-alph*bs2.ro)*normrnd(protocol.plr,protocol.plrflu);
            %     if bs2.delay > 0 && bs2.bandwidth > 0 && bs2.plr >0
            %         break;
            %     end
            % end
            % 
            % BSs1=[BSs1;bs1];
            % BSs2=[BSs2;bs2];
        end

        %给BS添加ID属性
        
        for i=1:BSNum
            BSs(i).id=i;
        end

        %全局ID
        sid=i+1;

        
        %% 绘制V2X Receiver
        ReceiverNum = 0;
        % ReceiverNum = poissrnd(ReceiverDensity * roadLen);
        V2XReceivers=[];
        V2XReceivers1=[];
        V2XReceivers2=[];
        %遍历每一条道路
        for i=1:roadNum
            %选择一条道路
            curroad=roads(i);
            %生成当前道路中V2XReceiver的数量，服从泊松分布
            tempV2XReceiverNums = poissrnd(ReceiverDensity * curroad.len);
            ReceiverNum=ReceiverNum+tempV2XReceiverNums;
            %生成当前道路中的V2XReceiver节点
            for j=1:tempV2XReceiverNums
                %随机生成一个点
                t=rand();
                pointx=t*curroad.point1(1)+(1-t)*curroad.point2(1);
                pointy=t*curroad.point1(2)+(1-t)*curroad.point2(2);
                
                V2Xr=V2XReceiver(pointx,pointy);
                V2Xr.id=sid;
                sid = sid+1;

                %指定通信协议
                V2Xr=getP(V2Xr,DSRC,LTE,NR);
                protocol = V2Xr.protocol;
                %计算与典型车辆的距离
                V2Xr.ro = sqrt((V2Xr.x-Vehicle.x)^2+(V2Xr.y-Vehicle.y)^2);
                %计算信道H和LOS情况
                [V2Xr.h,V2Xr.LOS] = getH(mL,mN,beta,V2Xr.ro);
                % 设置随机数种子为当前时间，城市环境
                randn('seed',sum(100*clock));
                S_d_ru = 10^(mu_s/10) * 10^(sigma_0_ru * randn / 10);
                S_d = S_d_ru;
                %计算天线增益，默认天线对齐
                V2Xr.G = protocol.Mt*protocol.Mt*S_d;
                % V2Xr.G = 1;
                %节点速度服从正态分布且为正
                while 1
                    V2Xr.ms=normrnd(curroad.speed,speedsigma);
                    if V2Xr.ms > 0 && V2Xr.ms < 120
                        break;
                    end
                end
                %设定速度方向
                if (randi([0,1])==1)
                   V2Xr.moveDirection=1;
                else
                    V2Xr.moveDirection=-1;
                end
                %生成节点时延、带宽、丢包率参数
                %参数和距离相关，alph为控制因子
                alph = 5;
                beta = 2;
                while 1
                    V2Xr.delay = exp(alph*V2Xr.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
                    V2Xr.bandwidth = exp(-alph*V2Xr.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                    V2Xr.plr = exp(alph*V2Xr.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
                    V2Xr.jitter = exp(alph*V2Xr.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
                    V2Xr.ber = exp(alph*V2Xr.ro)+normrnd(protocol.ber,protocol.berflu)-1;
					V2Xr.rss = protocol.rss/exp(beta*V2Xr.ro)-130;
                    V2Xr.cost = protocol.cost;
                    V2Xr.ee = protocol.ee;
                    if V2Xr.delay > 0 && V2Xr.bandwidth > 0 && V2Xr.plr >0 && V2Xr.jitter >0 && V2Xr.ber >0
                        break;
                    end
                end
                %向当前道路上添加节点
                curroad.v2xRs=[curroad.v2xRs;V2Xr];
                roads(i)=curroad;
                p4=scatter(V2Xr.x, V2Xr.y, 60,'magenta','filled');
                hold on;
                %将新生成的节点添加到变量中
                V2XReceivers=[V2XReceivers;V2Xr];
            
                % %生成其余两种网络制式
                % V2Xr1 = V2Xr;
                % V2Xr2 = V2Xr;
                % %1 2 3分别代表DSRC LTE NR
                % index = {'1', '2', '3'};
                % if protocol.name == index{1}
                %     V2Xr1.protocol = LTE;
                %     V2Xr2.protocol = NR;
                % elseif protocol.name == index{2}
                %     V2Xr1.protocol = DSRC;
                %     V2Xr2.protocol = NR;
                % elseif protocol.name == index{3}
                %     V2Xr1.protocol = DSRC;
                %     V2Xr2.protocol = LTE;
                % end 
                % 
                % protocol = V2Xr1.protocol;
                % while 1
                %     V2Xr1.delay = exp(-alph*V2Xr1.ro)*normrnd(protocol.delay,protocol.delayflu);
                %     V2Xr1.bandwidth = exp(-alph*V2Xr1.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                %     V2Xr1.plr = exp(-alph*V2Xr1.ro)*normrnd(protocol.plr,protocol.plrflu);
                %     if V2Xr1.delay > 0 && V2Xr1.bandwidth > 0 && V2Xr1.plr >0
                %         break;
                %     end
                % end
                % 
                % protocol = V2Xr2.protocol;
                % while 1
                %     V2Xr2.delay = exp(-alph*V2Xr2.ro)*normrnd(protocol.delay,protocol.delayflu);
                %     V2Xr2.bandwidth = exp(-alph*V2Xr2.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                %     V2Xr2.plr = exp(-alph*V2Xr2.ro)*normrnd(protocol.plr,protocol.plrflu);
                %     if V2Xr2.delay > 0 && V2Xr2.bandwidth > 0 && V2Xr2.plr >0
                %         break;
                %     end
                % end
                % V2XReceivers1=[V2XReceivers1;V2Xr1];
                % V2XReceivers2=[V2XReceivers2;V2Xr2];
            end 
        end
%         %给V2Xr添加ID属性
%         for i=1:ReceiverNum
%             V2XReceivers(i).id=i;
%         end
        disp(['V2X Receiver数量:',num2str(ReceiverNum)]);
        disp(['V2X Receiver密度:',num2str(ReceiverNum/roadLen)]);
        v2xTotalNum=v2xTotalNum+ReceiverNum;
        
        %% 绘制V2X Transmitter
        % TransmitterNum = poissrnd(TransmitterDensity * roadLen);
        TransmitterNum=0;
        V2XTransmitters=[];
        V2XTransmitters1=[];
        V2XTransmitters2=[];
        %遍历每一条道路
        for i=1:roadNum
            %选择一条道路
            curroad=roads(i);
            %生成当前道路中V2XTransmitter的数量，服从泊松分布
            tempV2XTransmitterNums = poissrnd(TransmitterDensity * curroad.len);
            TransmitterNum=TransmitterNum+tempV2XTransmitterNums;
            %生成当前道路中的V2XTransmitter节点
            for j=1:tempV2XTransmitterNums
                %随机生成一个点
                t=rand();
                pointx=t*curroad.point1(1)+(1-t)*curroad.point2(1);
                pointy=t*curroad.point1(2)+(1-t)*curroad.point2(2);

                V2Xt=V2XTransmitter(pointx,pointy);
                V2Xt.id=sid;
                sid = sid+1;

                %指定通信协议
                V2Xt=getP(V2Xt,DSRC,LTE,NR);
                protocol = V2Xt.protocol;
                %计算与典型车辆的距离
                V2Xt.ro = sqrt((V2Xt.x-Vehicle.x)^2+(V2Xt.y-Vehicle.y)^2);
                %计算信道H和LOS情况
                [V2Xt.h,V2Xt.LOS] = getH(mL,mN,beta,V2Xt.ro);
                % 设置随机数种子为当前时间，城市环境
                randn('seed',sum(100*clock));
                S_d_ru = 10^(mu_s/10) * 10^(sigma_0_ru * randn / 10);
                S_d = S_d_ru;
                %计算天线增益，默认天线对齐
                V2Xt.G = protocol.Mt*protocol.Mt*S_d;
                % V2Xt.G = 1;
                %节点速度服从正态分布且为正
                while 1
                    V2Xt.ms=normrnd(curroad.speed,speedsigma);
                    if V2Xt.ms > 0 && V2Xt.ms < 120
                        break;
                    end
                end
                %设定速度方向
                if (randi([0,1])==1)
                   V2Xt.moveDirection=1;
                else
                    V2Xt.moveDirection=-1;
                end
                %生成节点时延、带宽、丢包率参数,必须大于0
                %参数和距离相关，alph为控制因子
                alph = 5;
                beta = 2;
                while 1
                    V2Xt.delay = exp(alph*V2Xt.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
                    V2Xt.bandwidth = exp(-alph*V2Xt.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                    V2Xt.plr = exp(alph*V2Xt.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
                    V2Xt.jitter = exp(alph*V2Xt.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
                    V2Xt.ber = exp(alph*V2Xt.ro)+normrnd(protocol.ber,protocol.berflu)-1;
                    V2Xt.rss = protocol.rss/exp(beta*V2Xt.ro)-130;
                    V2Xt.cost = protocol.cost;
                    V2Xt.ee = protocol.ee;
                    if V2Xt.delay > 0 && V2Xt.bandwidth > 0 && V2Xt.plr >0 && V2Xt.jitter >0 && V2Xt.ber >0
                        break;
                    end
                end
                %向当前道路上添加节点
                curroad.v2xTs=[curroad.v2xTs;V2Xt];
                roads(i)=curroad;
                p5=scatter(V2Xt.x, V2Xt.y, 60,'cyan','filled');
                hold on;
                %添加到变量中
                V2XTransmitters=[V2XTransmitters;V2Xt];
            
                % %生成其余两种网络制式的V2XTransmitters对象
                % V2Xt1 = V2Xt;
                % V2Xt2 = V2Xt;
                % %1 2 3分别代表DSRC LTE NR
                % index = {'1', '2', '3'};
                % if protocol.name == index{1}
                %     V2Xt1.protocol = LTE;
                %     V2Xt2.protocol = NR;
                % elseif protocol.name == index{2}
                %     V2Xt1.protocol = DSRC;
                %     V2Xt2.protocol = NR;
                % elseif protocol.name == index{3}
                %     V2Xt1.protocol = DSRC;
                %     V2Xt2.protocol = LTE;
                % end 
                % 
                % protocol = V2Xt1.protocol;
                % while 1
                %     V2Xt1.delay = exp(-alph*V2Xt1.ro)*normrnd(protocol.delay,protocol.delayflu);
                %     V2Xt1.bandwidth = exp(-alph*V2Xt1.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                %     V2Xt1.plr = exp(-alph*V2Xt1.ro)*normrnd(protocol.plr,protocol.plrflu);
                %     if V2Xt1.delay > 0 && V2Xt1.bandwidth > 0 && V2Xt1.plr >0
                %         break;
                %     end
                % end
                % 
                % protocol = V2Xt2.protocol;
                % while 1
                %     V2Xt2.delay = exp(-alph*V2Xt2.ro)*normrnd(protocol.delay,protocol.delayflu);
                %     V2Xt2.bandwidth = exp(-alph*V2Xt2.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                %     V2Xt2.plr = exp(-alph*V2Xt2.ro)*normrnd(protocol.plr,protocol.plrflu);
                %     if V2Xt2.delay > 0 && V2Xt2.bandwidth > 0 && V2Xt2.plr >0
                %         break;
                %     end
                % end
                % V2XTransmitters1=[V2XTransmitters1;V2Xt1];
                % V2XTransmitters2=[V2XTransmitters2;V2Xt2];
            end
        end
        %给V2Xt添加ID属性
        for i=1:TransmitterNum
            V2XTransmitters(i).id=i;
        end
        disp(['V2X Transmitter数量:',num2str(TransmitterNum)]);
        disp(['V2X Transmitter密度:',num2str(TransmitterNum/roadLen)]);
        v2xTotalNum=v2xTotalNum+TransmitterNum;
        
        %% V2X节点作为发射机传输消息的概率
        V2XTpt=TransmitterNum/(TransmitterNum+ReceiverNum);
        
        %% 绘制V2X Eavesdropper
        % EavesdropperNum = poissrnd(EavesdropperDensity * roadLen);
        
        EavesdropperNum=0;
        V2XEavesdroppers=[];
        %遍历每一条道路
        for i=1:roadNum
            %选择一条道路
            curroad=roads(i);
            %生成当前道路中Eavesdropper的数量，服从泊松分布
            tempEavesdropperNums = poissrnd(EavesdropperDensity * curroad.len);
            while 1
                if (tempEavesdropperNums>=0)
                    break
                else
                    tempEavesdropperNums = poissrnd(EavesdropperDensity * curroad.len);
                end
            end 
            EavesdropperNum=EavesdropperNum+tempEavesdropperNums;
            %生成当前道路中的Eavesdropper节点
            for j=1:tempEavesdropperNums
                %随机生成一个点
                t=rand();
                pointx=t*curroad.point1(1)+(1-t)*curroad.point2(1);
                pointy=t*curroad.point1(2)+(1-t)*curroad.point2(2);

                V2Xe=V2XEavesdropper(pointx,pointy);
                V2Xe.id=sid;
                sid = sid+1;

                %指定通信协议
                V2Xe=getP(V2Xe,DSRC,LTE,NR);
                protocol = V2Xe.protocol;
                %计算与典型车辆的距离
                V2Xe.ro = sqrt((V2Xe.x-Vehicle.x)^2+(V2Xe.y-Vehicle.y)^2);
                %计算信道H和LOS情况
                [V2Xe.h,V2Xe.LOS] = getH(mL,mN,beta,V2Xe.ro);
                %计算天线增益，窃听者随机增益
                V2Xe.G = getG(V2Xe,V2Xe);
                % V2Xt.G = 1;
                %节点速度服从正态分布且为正
                while 1
                    V2Xe.ms=normrnd(curroad.speed,speedsigma);
                    if V2Xe.ms > 0 && V2Xe.ms < 120
                        break;
                    end
                end
                %设定速度方向
                if (randi([0,1])==1)
                   V2Xe.moveDirection=1;
                else
                    V2Xe.moveDirection=-1;
                end
                %向当前道路上添加节点
                curroad.v2xEs=[curroad.v2xEs;V2Xe];
                roads(i)=curroad;
                p6=scatter(V2Xe.x, V2Xe.y, 100,'red','filled','pentagram');
                hold on;
                V2XEavesdroppers=[V2XEavesdroppers;V2Xe];
            end
            
        end
        %给V2Xe添加ID属性
        for i=1:EavesdropperNum
            V2XEavesdroppers(i).id=i;
        end
        disp(['V2X Eavesdropper数量:',num2str(EavesdropperNum)]);
        disp(['V2X Eavesdropper密度:',num2str(EavesdropperNum/roadLen)]);
        v2xTotalNum=v2xTotalNum+EavesdropperNum;
        disp(['大圆中的V2X车辆总数:',num2str(v2xTotalNum)]);
        
        % for i = 1:length(V2XReceivers)
        %     disp(V2XReceivers(i));
        % end
        % for i = 1:length(V2XTransmitters)
        %     disp(V2XTransmitters(i));
        % end
        % for i = 1:length(BSs)
        %     disp(BSs(i));
        % end
        
        %添加图例
        hold off;
        %legend([p1 p2 p3 p4 p5 p6],{'Road','Typical Vehicle','BS','V2X Receiver','V2X Transmitter','V2X Eavesdropper'});
        legend([p1 p2 p3 p4 p5],{'Road','Typical Vehicle','BS','V2X Receiver','V2X Transmitter'});
        total_fig_name=figFolder+"big_r_"+num2str(r)+"_t_"+num2str(FrameCount)+".fig";
        savefig(fig1,total_fig_name);
        figTitle="big r="+num2str(r)+" t="+num2str(FrameCount);
        title(figTitle);

        save(tmpDataFolder+"big_r_"+num2str(r)+"_t_"+num2str(FrameCount)+"_v_"+num2str(vehicleSpeed)+".mat");

        %% 绘制小圆1
        %绘制圆形区域和典型车辆
        % %圆盘半径
        % smallr=0.5;
        %圆上点的数量
        circlePointNum=100000;
        %在0~2Π之间生成circlePointNum个等距的向量
        t=linspace(0,2*pi,circlePointNum); 
        %圆上点的坐标
        xc=Vehicle.x+smallr*cos(t); 
        yc=Vehicle.y+smallr*sin(t);
        %显示圆的信息
        disp('===  初始状态-小圆 ===');
        disp(['圆的半径R:',num2str(smallr)]);
        disp(['圆心坐标: x:',num2str(Vehicle.x),' y:',num2str(Vehicle.y)]);
        %开始绘图
        fig2 = figure;
        fig2.Visible="off";
        set(fig2, 'position', get(0,'ScreenSize'));
        plot(xc,yc,'k'); 
        xlabel('x'); ylabel('y');
        axis square;            %设置坐标系为方型，横纵比例为1:1
        hold on;
        axis tight;
        xlim auto
        ylim auto
        % set(gca,'xtick',-1.5:0.1:1.5); 
        % set(gca,'ytick',-1.5:0.1:1.5); 
        %xticks([]);                    %去除坐标轴
        %yticks([]);
        %set(gca,'Visible','off');      %隐藏边框 
        
            
        % 找到道路与小圆的交线
        for i=1:roadNum
            ro=roads(i);
            [xi,yi] = polyxpoly([ro.point1(1) ro.point2(1)], [ro.point1(2) ro.point2(2)], xc, yc);
            if( isempty(xi) || isempty(yi))
                ro.point3=[];
                ro.point4=[];
                continue
            end
            ro.point3=[xi(1);yi(1)];
            ro.point4=[xi(2);yi(2)];
            roads(i)=ro;
        end

        % 绘制小圆的道路和节点
        for i=1:roadNum
            ro=roads(i);
            if (isempty(ro.point3)||isempty(ro.point4))
                continue
            end
            sp1=plot([ro.point3(1);ro.point4(1)],[ro.point3(2);ro.point4(2)],'k','LineWidth',1);
            hold on;
    
            % 绘制smallr范围内的V2Xr
            for j=1:length(ro.v2xRs)
                V2Xr=ro.v2xRs(j);
                d=sqrt((V2Xr.x-Vehicle.x)^2+(V2Xr.y-Vehicle.y)^2);
                if(d>smallr)
                    continue
                end
                smallv2xRs=[smallv2xRs;V2Xr];
                sp4=scatter(V2Xr.x, V2Xr.y, 60,'magenta','filled');
                hold on;
            end
    
            % 绘制所有的V2Xt
            for j=1:length(ro.v2xTs)
                V2Xt=ro.v2xTs(j);
                d=sqrt((V2Xt.x-Vehicle.x)^2+(V2Xt.y-Vehicle.y)^2);
                if(d>smallr)
                    continue
                end
                smallv2xTs=[smallv2xTs;V2Xt];
                sp5=scatter(V2Xt.x, V2Xt.y, 60,'cyan','filled');
                hold on;
            end
               
            % 绘制所有的V2Xe
            for j=1:length(ro.v2xEs)
                V2Xe=ro.v2xEs(j);
                d=sqrt((V2Xe.x-Vehicle.x)^2+(V2Xe.y-Vehicle.y)^2);
                if(d>smallr)
                    continue
                end
                smallv2xEs=[smallv2xEs;V2Xe];
                sp6=scatter(V2Xe.x, V2Xe.y, 100,'red','filled','pentagram');
                hold on;
            end
        end

        % 绘制典型车辆
        sp2=scatter(Vehicle.x, Vehicle.y, 'k','filled','LineWidth',2);
        % 绘制所有的BS
        for i=1:BSNum
            bs=BSs(i);
            d=sqrt((bs.x-Vehicle.x)^2+(bs.y-Vehicle.y)^2);
            if(d>smallr)
                continue
            end
            smallBSs=[smallBSs;bs];
            %绘制BS
            sp3=scatter(bs.x, bs.y, 60, 'blue','filled','diamond');
            hold on;
        end
        disp(['小圆中的车辆总数为:',num2str(length(smallv2xTs)+length(smallv2xRs)+length(smallv2xEs))]);
        disp(['小圆中的基站总数为:',num2str(length(smallBSs))]);
        if ~exist('sp3') && ~exist('sp6')
            legend([sp1 sp2 sp4 sp5],{'Road','Typical Vehicle','V2X Receiver','V2X Transmitter'});
        elseif  ~exist('sp3')
            legend([sp1 sp2 sp4 sp5 sp6],{'Road','Typical Vehicle','V2X Receiver','V2X Transmitter','V2X Eavesdropper'});
        elseif ~exist('sp6')
            legend([sp1 sp2 sp3 sp4 sp5],{'Road','Typical Vehicle','BS','V2X Receiver','V2X Transmitter'});
        else
            legend([sp1 sp2 sp3 sp4 sp5 sp6],{'Road','Typical Vehicle','BS','V2X Receiver','V2X Transmitter','V2X Eavesdropper'});
        end
        
        tmp_fig_name=figFolder+"small_"+num2str(smallr)+"_t_"+num2str(FrameCount)+".fig";
        savefig(fig2,tmp_fig_name);
        
        figTitle="small r="+num2str(smallr)+" t="+num2str(FrameCount);
        title(figTitle);
        %添加图例
        hold off;

        save(tmpDataFolder+"small_r_"+num2str(smallr)+"_t_"+num2str(FrameCount)+"_v_"+num2str(vehicleSpeed)+".mat","smallBSs","smallv2xRs","smallv2xEs","smallv2xTs","Vehicle","fig2","smallr");
    
    %% 帧数据处理
    else
        %% 更新运动状态的图像
        %更新典型车辆的位置
        curroad=roads(roadNum);
        Vehicled=Vehicle.ms/3.6*timeInterval/1000;
        tmptheta=curroad.theta+pi/2;
        Vehicle.x = Vehicle.x + Vehicle.moveDirection*Vehicled*cos(tmptheta);
        Vehicle.y = Vehicle.y + Vehicle.moveDirection*Vehicled*sin(tmptheta);
        
        %更新所有道路上的所有节点的位置
        for i=1:roadNum
            curroad = roads(i);
            % 取到当前道路上所有节点更新位置和参数
            for j=1:length(curroad.v2xRs)
                v2x = curroad.v2xRs(j);
                if sqrt((v2x.x-xx0)^2+(v2x.y-yy0)^2)>r
                    % delete v2x;
                    % delete curroad.v2xTs(j);
                    continue
                end
                d = v2x.ms/3.6*timeInterval/1000;
                tmptheta=curroad.theta+pi/2;
                v2x.x = v2x.x + v2x.moveDirection*d.*cos(tmptheta);
                v2x.y = v2x.y + v2x.moveDirection*d.*sin(tmptheta);
                %更新v2x节点的参数
                v2x.ro=sqrt((v2x.x-Vehicle.x)^2+(v2x.y-Vehicle.y)^2);
                %计算信道H和LOS情况
                [v2x.h,v2x.LOS] = getH(mL,mN,beta,v2x.ro);
                %计算天线增益，默认对齐
                protocol=v2x.protocol;
                v2x.G = protocol.Mt*protocol.Mt;
                while 1
                    v2x.delay = exp(alph*v2x.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
                    v2x.bandwidth = exp(-alph*v2x.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                    v2x.plr = exp(alph*v2x.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
                    v2x.jitter = exp(alph*v2x.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
                    v2x.ber = exp(alph*v2x.ro)+normrnd(protocol.ber,protocol.berflu)-1;
                    v2x.cost = protocol.cost;
                    v2x.ee = protocol.ee;
                    if v2x.delay > 0 && v2x.bandwidth > 0 && v2x.plr >0 && v2x.jitter >0 && v2x.ber >0
                        break;
                    end
                end
                curroad.v2xRs(j) = v2x;
            end
        
            for j=1:length(curroad.v2xTs)
                v2x = curroad.v2xTs(j);
                if sqrt((v2x.x-xx0)^2+(v2x.y-yy0)^2)>r
                    % delete v2x;
                    % delete curroad.v2xTs(j);
                    continue
                end
                d = v2x.ms/3.6*timeInterval/1000;
                tmptheta=curroad.theta+pi/2;
                v2x.x = v2x.x + v2x.moveDirection*d.*cos(tmptheta);
                v2x.y = v2x.y + v2x.moveDirection*d.*sin(tmptheta);
                %更新v2x节点的参数
                v2x.ro=sqrt((v2x.x-Vehicle.x)^2+(v2x.y-Vehicle.y)^2);
                %计算信道H和LOS情况
                [v2x.h,v2x.LOS] = getH(mL,mN,beta,v2x.ro);
                %计算天线增益，默认对齐
                protocol=v2x.protocol;
                v2x.G = protocol.Mt*protocol.Mt;
                while 1
                    v2x.delay = exp(alph*v2x.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
                    v2x.bandwidth = exp(-alph*v2x.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                    v2x.plr = exp(alph*v2x.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
                    v2x.jitter = exp(alph*v2x.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
                    v2x.ber = exp(alph*v2x.ro)+normrnd(protocol.ber,protocol.berflu)-1;
                    v2x.cost = protocol.cost;
                    v2x.ee = protocol.ee;
                    if v2x.delay > 0 && v2x.bandwidth > 0 && v2x.plr >0 && v2x.jitter >0 && v2x.ber >0
                        break;
                    end
                end
                curroad.v2xTs(j)=v2x;
            end
        
            for j=1:length(curroad.v2xEs)
                v2x = curroad.v2xEs(j);
                if sqrt((v2x.x-xx0)^2+(v2x.y-yy0)^2)>r
                    % delete v2x;
                    % delete curroad.v2xTs(j);
                    continue
                end
                d = v2x.ms/3.6*timeInterval/1000;
                tmptheta=curroad.theta+pi/2;
                v2x.x = v2x.x + v2x.moveDirection*d.*cos(tmptheta);
                v2x.y = v2x.y + v2x.moveDirection*d.*sin(tmptheta);
                %更新v2x节点的参数
                v2x.ro=sqrt((v2x.x-Vehicle.x)^2+(v2x.y-Vehicle.y)^2);
                %计算信道H和LOS情况
                [v2x.h,v2x.LOS] = getH(mL,mN,beta,v2x.ro);
                %计算天线增益
                v2x.G = getG(v2x,v2x);
                curroad.v2xEs(j)=v2x;
            end
            roads(i)=curroad;
        end
        
        %开始绘图
        % set(0,'DefaultFigureVisible', 'on');
        fig1 = figure;
        set(fig1, 'position', get(0,'ScreenSize'));
        %设置不展示
        fig1.Visible="off";
        %圆上点的坐标
        xc=xx0+r*cos(t); 
        yc=yy0+r*sin(t);

        plot(xc,yc,'k'); 
        xlabel('x'); ylabel('y');
        axis square;            %设置坐标系为方型，横纵比例为1:1
        hold on;
        axis tight;
        xlim auto
        ylim auto
        % set(gca,'xtick',-1.5:0.1:1.5); 
        % set(gca,'ytick',-1.5:0.1:1.5); 
    
        %xticks([]);                    %去除坐标轴
        %yticks([]);
        %set(gca,'Visible','off');      %隐藏边框 
    
        % 绘制更新的道路和节点
        for i=1:roadNum
            ro=roads(i);
            tp1=plot([ro.point1(1);ro.point2(1)],[ro.point1(2);ro.point2(2)],'k','LineWidth',1);
            hold on;
    
            % 绘制所有的V2Xr
            for j=1:length(ro.v2xRs)
                V2Xr=ro.v2xRs(j);
                if sqrt((V2Xr.x-xx0)^2+(V2Xr.y-yy0)^2)>r
                    % delete v2x;
                    % delete curroad.v2xTs(j);
                    continue
                end
                tp4=scatter(V2Xr.x, V2Xr.y, 60,'magenta','filled');
                hold on;
            end
    
            % 绘制所有的V2Xt
            for j=1:length(ro.v2xTs)
                V2Xt=ro.v2xTs(j);
                if sqrt((V2Xt.x-xx0)^2+(V2Xt.y-yy0)^2)>r
                    % delete v2x;
                    % delete curroad.v2xTs(j);
                    continue
                end
                tp5=scatter(V2Xt.x, V2Xt.y, 60,'cyan','filled');
                hold on;
            end
               
            % 绘制所有的V2Xe
            for j=1:length(ro.v2xEs)
                V2Xe=ro.v2xEs(j);
                if sqrt((V2Xe.x-xx0)^2+(V2Xe.y-yy0)^2)>r
                    % delete v2x;
                    % delete curroad.v2xTs(j);
                    continue
                end
                tp6=scatter(V2Xe.x, V2Xe.y, 100,'red','filled','pentagram');
                hold on;
            end
        end
    
        % 绘制典型车辆
        tp2=scatter(Vehicle.x, Vehicle.y, 'k','filled','LineWidth',2);
        % 绘制所有的BS
        for i=1:BSNum
            bs=BSs(i);
            %更新参数
            bs.ro=sqrt((bs.x-Vehicle.x)^2+(bs.y-Vehicle.y)^2);
            protocol=bs.protocol;
            while 1
                bs.delay = exp(alph*bs.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
                bs.bandwidth = exp(-alph*bs.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
                bs.plr = exp(alph*bs.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
                bs.jitter = exp(alph*bs.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
                bs.ber = exp(alph*bs.ro)+normrnd(protocol.ber,protocol.berflu)-1;
                bs.cost =  protocol.cost;
                bs.ee = protocol.ee;
                if bs.delay > 0 && bs.bandwidth > 0 && bs.plr >0 && bs.jitter >0 && bs.ber >0
                    break;
                end
            end
            BSs(i)=bs;
            %绘制BS
            tp3=scatter(bs.x, bs.y, 60, 'blue','filled','diamond');
            hold on;
        end
    
        legend([tp1 tp2 tp3 tp4 tp5 tp6],{'Road','Typical Vehicle','BS','V2X Receiver','V2X Transmitter','V2X Eavesdropper'});
        total_fig_name=figFolder+"big_r_"+num2str(r)+"_t_"+num2str(FrameCount)+".fig";
        savefig(fig1,total_fig_name);
        figTitle="big r="+num2str(r)+" t="+num2str(FrameCount);
        title(figTitle);
        %添加图例
        hold off;
        save(tmpDataFolder+"big_r_"+num2str(r)+"_t_"+num2str(FrameCount)+"_v_"+num2str(vehicleSpeed)+".mat");

        %% 绘制小圆2
        %绘制圆形区域和典型车辆
        %圆盘半径
        % smallr=0.5;
        %圆上点的数量
        circlePointNum=100000;
        %在0~2Π之间生成circlePointNum个等距的向量
        t=linspace(0,2*pi,circlePointNum); 
        %圆上点的坐标
        xc=Vehicle.x+smallr*cos(t); 
        yc=Vehicle.y+smallr*sin(t);
        % %显示圆的信息
        % disp(['===  初始状态-小圆 ===']);
        % disp(['圆的半径R:',num2str(smallr)]);
        % disp(['圆心坐标: x:',num2str(xx0),' y:',num2str(yy0)]);
        %开始绘图
        fig2 = figure;
        fig2.Visible="off";
        set(fig2, 'position', get(0,'ScreenSize'));
        plot(xc,yc,'k'); 
        xlabel('x'); ylabel('y');
        axis square;            %设置坐标系为方型，横纵比例为1:1
        hold on;
        axis tight;
        xlim auto
        ylim auto
        % set(gca,'xtick',-1.5:0.1:1.5); 
        % set(gca,'ytick',-1.5:0.1:1.5); 
        %xticks([]);                    %去除坐标轴
        %yticks([]);
        %set(gca,'Visible','off');      %隐藏边框 

        % 找到道路与小圆的交线
        for i=1:roadNum
            ro=roads(i);
            A=ro.point1(2)-ro.point2(2);
            B=ro.point2(1)-ro.point1(1);
            C=ro.point1(1)*ro.point2(2)-ro.point2(1)*ro.point1(2);
            d=abs(A*Vehicle.x+B*Vehicle.y+C)/sqrt(A^2+B^2);
            if d>smallr
                continue
            end
            
            [xi,yi] = polyxpoly([ro.point1(1) ro.point2(1)], [ro.point1(2) ro.point2(2)], xc, yc);
            A=yi(2)-yi(1);
            B=xi(1)-xi(2);
            C=xi(2)*yi(1)-xi(1)*yi(2);
            d=abs(A*Vehicle.x+B*Vehicle.y+C)/sqrt(A^2+B^2);
            if d>smallr
                ro.point3=[];
                ro.point3=[];
                continue
            end
            % disp(xi);
            % disp(yi);
            if( isempty(xi) || isempty(yi))
                ro.point3=[];
                ro.point3=[];
                continue
            end
            ro.point3=[xi(1);yi(1)];
            ro.point4=[xi(2);yi(2)];
            roads(i)=ro;
        end

        % 绘制小圆的道路和节点
        for i=1:roadNum
            ro=roads(i);
            if (isempty(ro.point3)||isempty(ro.point4))
                continue
            end
            sp1=plot([ro.point3(1);ro.point4(1)],[ro.point3(2);ro.point4(2)],'k','LineWidth',1);
            hold on;
    
            % 绘制smallr范围内的V2Xr
            for j=1:length(ro.v2xRs)
                V2Xr=ro.v2xRs(j);
                d=sqrt((V2Xr.x-Vehicle.x)^2+(V2Xr.y-Vehicle.y)^2);
                if(d>smallr)
                    continue
                end
                smallv2xRs=[smallv2xRs;V2Xr];
                sp4=scatter(V2Xr.x, V2Xr.y, 60,'magenta','filled');
                hold on;
            end
    
            % 绘制所有的V2Xt
            for j=1:length(ro.v2xTs)
                V2Xt=ro.v2xTs(j);
                d=sqrt((V2Xt.x-Vehicle.x)^2+(V2Xt.y-Vehicle.y)^2);
                if(d>smallr)
                    continue
                end
                smallv2xTs=[smallv2xTs;V2Xt];
                sp5=scatter(V2Xt.x, V2Xt.y, 60,'cyan','filled');
                hold on;
            end
               
            % 绘制所有的V2Xe
            for j=1:length(ro.v2xEs)
                V2Xe=ro.v2xEs(j);
                d=sqrt((V2Xe.x-Vehicle.x)^2+(V2Xe.y-Vehicle.y)^2);
                if(d>smallr)
                    continue
                end
                smallv2xEs=[smallv2xEs;V2Xe];
                sp6=scatter(V2Xe.x, V2Xe.y, 100,'red','filled','pentagram');
                hold on;
            end
        end
    
        % 绘制典型车辆
        sp2=scatter(Vehicle.x, Vehicle.y, 'k','filled','LineWidth',2);
        % 绘制所有的BS
        for i=1:BSNum
            bs=BSs(i);
            d=sqrt((bs.x-Vehicle.x)^2+(bs.y-Vehicle.y)^2);
            if(d>smallr)
                continue
            end
            smallBSs=[smallBSs;bs];
            %绘制BS
            sp3=scatter(bs.x, bs.y, 60, 'blue','filled','diamond');
            hold on;
        end
        disp(['小圆中的车辆总数为:',num2str(length(smallv2xTs)+length(smallv2xRs)+length(smallv2xEs))]);
        disp(['小圆中的基站总数为:',num2str(length(smallBSs))]);
        if ~exist('sp3') && ~exist('sp6')
            legend([sp1 sp2 sp4 sp5],{'Road','Typical Vehicle','V2X Receiver','V2X Transmitter'});
        elseif  ~exist('sp3')
            legend([sp1 sp2 sp4 sp5 sp6],{'Road','Typical Vehicle','V2X Receiver','V2X Transmitter','V2X Eavesdropper'});
        elseif ~exist('sp6')
            legend([sp1 sp2 sp3 sp4 sp5],{'Road','Typical Vehicle','BS','V2X Receiver','V2X Transmitter'});
        else
            legend([sp1 sp2 sp3 sp4 sp5 sp6],{'Road','Typical Vehicle','BS','V2X Receiver','V2X Transmitter','V2X Eavesdropper'});
        end
        tmp_fig_name=figFolder+"small_"+num2str(smallr)+"_t_"+num2str(FrameCount)+".fig";
        savefig(fig2,tmp_fig_name);
        figTitle="small r="+num2str(smallr)+" t="+num2str(FrameCount);
        title(figTitle);
        %添加图例
        hold off;

        save(tmpDataFolder+"small_r_"+num2str(smallr)+"_t_"+num2str(FrameCount)+"_v_"+num2str(vehicleSpeed)+".mat","smallBSs","smallv2xRs","smallv2xEs","smallv2xTs","Vehicle","fig2","smallr");
    
        
    end
    %保存gif运动帧图像
    frame = getframe(fig1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if FrameCount == 0
      imwrite(imind,cm,gifname,'gif','Loopcount',inf,'DelayTime',gifdel);
    else
      imwrite(imind,cm,gifname,'gif','WriteMode','append','DelayTime',gifdel);
    end

    %保存gif运动帧图像
    frame = getframe(fig2);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if FrameCount == 0
      imwrite(imind,cm,gifname2,'gif','Loopcount',inf,'DelayTime',gifdel);
    else
      imwrite(imind,cm,gifname2,'gif','WriteMode','append','DelayTime',gifdel);
    end
end

%保存变量
dataMatName=tmpDataFolder+"test.mat";
save(dataMatName);


