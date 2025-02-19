function [v2x,v2x1,v2x2,copsopdata] = COPSOP_test(v2x,v2x1,v2x2,r,Vehicle,v2xRTDensity)
    % % %% 通信协议的参数指定
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
    % 
    %%测试道路及节点密度参数
    %道路密度
    testroadDensity=2;
    testBSDensity = 1;
    testReceiverDensity = v2xRTDensity;
    testTransmitterDensity = v2xRTDensity;
    testEavesdropperDensity = 0.1;

    % %% 创建测试图像
    % 
    % %圆盘半径
    % r=1;
    % %圆上点的数量
    % circlePointNum=10000;
    % %在0~2Π之间生成circlePointNum个等距的向量
    % t=linspace(0,2*pi,circlePointNum); 
    % 
    % %创建典型车辆
    % %典型车辆的位置【典型车辆选为原点位置,不可随意更改】
    
    testVehicle = Vehicle;
    xx0=Vehicle.x;
    yy0=Vehicle.y;
    % %指定通信协议
    % testVehicle.protocol=DSRC;
    % 
    % %圆上点的坐标
    % xc=xx0+r*cos(t); 
    % yc=yy0+r*sin(t);
    % % %显示圆的信息
    % % disp(['圆的半径R:',num2str(r)]);
    % % disp(['圆心坐标: x:',num2str(xx0),' y:',num2str(yy0)]);
    % %开始绘图
    % % fig = figure;
    % % plot(xc,yc,'k'); 
    % % xlabel('x'); ylabel('y');
    % % axis square;            %设置坐标系为方型，横纵比例为1:1
    % % hold on;
    % % axis tight;
    % %xticks([]);                    %去除坐标轴
    % %yticks([]);
    % %set(gca,'Visible','off');      %隐藏边框  
  
    %保持种子图中的v2x节点不变，其余节点服从泊松分布生成并计算当前节点的SINR，循环loop次
    SINR=[];SINR1=[];SINR2=[];loop=1000;
    v2xeSINRs=[];v2xeSINRs1=[];v2xeSINRs2=[];
%     maxrounum=0;maxrounum1=0;maxrounum2=0;%每一轮生成中窃听者的SINR大于保密中断阈值的数量
    % %基本参数
    % beta=0.8;             %用于计算LOS和NLOS的概率
    % mL=4;                 %视距(LOS)环境下的衰弱参数
    % mN=4;                 %非视距(NLOS)环境下的衰弱参数
    % alpL=2.1;             %LOS路径损耗指数，一般是2~6之间
    % alpN=3.5;             %NLOS路径损耗指数，一般是2~6之间
        
    %基本参数
    beta=0.6;             %用于计算LOS和NLOS的概率
    mL=4;                 %视距(LOS)环境下的衰弱参数
    mN=4;                 %非视距(NLOS)环境下的衰弱参数
    alpL=2.1;             %LOS路径损耗指数，一般是2~6之间
    alpN=3.5;             %NLOS路径损耗指数，一般是2~6之间
    ptd=0.3;              %道路上发射机为DSRC的概率
    ptl=0.5;              %道路上发射机为LTE的概率
    ptn=0.2;              %道路上发射机为NR的概率
    PNoice=0.001;         %噪声功率(0dbm)
    %betat=0.01;          %连接中断阈值,计算期望的阈值,COP=sinr小于betat的期望
    v2xr=v2x;
    v2xr1=v2x1;
    v2xr2=v2x2;
    for i=1:loop
        randn('seed',sum(100*clock));
        %% 绘制道路
        %道路λ
        testroadlambda=2 * pi * r * testroadDensity;
        %道路数量
        testroadNum=poissrnd(testroadlambda);
        %生成道路对象
        testroads=[];
        %计算道路总长度
        testroadLen=0;
        parfor i=1:testroadNum
            if i==testroadNum %最后一条路需要过圆点
                testtheta=2*pi*rand();
                testp=0;
                %生成道路对象
                testro=road(testtheta, testp, r, xx0, yy0);
            else
                %随机生成道路的θ和径向长度p
                testtheta=2*pi*rand();
                testp=r*rand(); 
                %生成道路对象
                testro=road(testtheta, testp, r, xx0, yy0);
            end
            %计算道路总长
            testroadLen=testroadLen+testro.len;
            %绘制当前道路
            % p1=plot([testro.point1(1);testro.point2(1)],[testro.point1(2);testro.point2(2)],'k','LineWidth',1);
            % hold on;
            %添加当前道路对象到roads变量中
            testroads=[testroads;testro];
        end
        
        testroadMuk=testroadLen/pi*r^2;
        % %显示道路信息
        % disp(['道路数量:',num2str(testroadNum)]);
        % disp(['道路总长:',num2str(testroadLen)]);
        % disp(['道路密度:',num2str(testroadNum/2*pi*r)]);
        
        
        % %% 绘制典型车辆
        % p2=scatter(xx0, yy0, 'k','filled','LineWidth',2);
        % hold on;
        
        %% 绘制BS
        %根据BS密度在圆内随机生成BS
        testBSlambda = pi * r^2 *testBSDensity;
        testBSNum = poissrnd(testBSlambda);
        % disp(['BS数量:',num2str(testBSNum)]);
        % disp(['BS密度:',num2str(testBSNum/pi*r^2)]);
        testBSs=[];
        parfor i=1:testBSNum
            %随机生成BS基站
            %随机生成BS到圆心的距离ro和夹角θ
            testtheta = unifrnd(0, 2*pi, 1, 1);
            testro = r * sqrt(rand());
            %生成BS对象
            bs = BS(testtheta, testro, xx0, yy0);
            %随机生成通信协议
            bs = getP(bs,DSRC,LTE,NR);
            % %绘制BS
            % p3=scatter(bs.x, bs.y, 60, 'blue','filled','diamond');
            % hold on;
            %添加到变量中
            testBSs=[testBSs;bs];
        end
        
        %% 绘制V2X Receiver
        testReceiverNum = 0;
        % disp(['V2X Receiver数量:',num2str(testReceiverNum)]);
        % disp(['V2X Receiver密度:',num2str(testReceiverNum/testroadLen)]);
        testV2XReceivers=[];
        parfor i=1:testroadNum
            curroad = testroads(i);
            tempReceiverNum = poissrnd(testReceiverDensity * curroad.len);
            testReceiverNum = testReceiverNum+tempReceiverNum;
            for j=1:tempReceiverNum
                %随机生成一个点
                t=rand();
                pointx=t*curroad.point1(1)+(1-t)*curroad.point2(1);
                pointy=t*curroad.point1(2)+(1-t)*curroad.point2(2);
                testV2Xr=V2XReceiver(pointx,pointy);
                %指定通信协议
                testV2Xr=getP(testV2Xr,DSRC,LTE,NR);
                %向当前道路上添加节点
                curroad.v2xRs=[curroad.v2xRs;testV2Xr];
                testV2XReceivers=[testV2XReceivers;testV2Xr];
            end
            testroads(i)=curroad;
            % p4=scatter(testV2Xr.x, testV2Xr.y, 60,'magenta','filled');
            % hold on;
            
        end
        % disp(["testV2XReceivers:",num2str(testReceiverNum)]);
        
        %% 绘制V2X Transmitter
        testTransmitterNum = 0;
        % disp(['V2X Transmitter数量:',num2str(testTransmitterNum)]);
        % disp(['V2X Transmitter密度:',num2str(testTransmitterNum/testroadLen)]);
        testV2XTransmitters=[];
        parfor i=1:testroadNum    
            curroad=testroads(i);
            tempTransmitterNum = poissrnd(testTransmitterDensity * curroad.len);
            testTransmitterNum = testTransmitterNum + tempTransmitterNum;
            for j=1:tempTransmitterNum
                %随机生成一个点
                t=rand();
                pointx=t*curroad.point1(1)+(1-t)*curroad.point2(1);
                pointy=t*curroad.point1(2)+(1-t)*curroad.point2(2);
                testV2Xt=V2XTransmitter(pointx,pointy);
                %通信协议
                testV2Xt = getP(testV2Xt,DSRC,LTE,NR);
                %向当前道路上添加节点
                curroad.v2xTs=[curroad.v2xTs;testV2Xt];
                testV2XTransmitters=[testV2XTransmitters;testV2Xt];
            end
            testroads(i)=curroad;
            % p5=scatter(V2Xt.x, V2Xt.y, 60,'cyan','filled');
            % hold on;
            
        end
        
        %% V2X节点作为发射机传输消息的概率
        testV2XTpt=testTransmitterNum/(testTransmitterNum+testReceiverNum);
        
        %% 绘制V2X Eavesdropper
        testEavesdropperNum = 0;
        % disp(['V2X Eavesdropper数量:',num2str(testEavesdropperNum)]);
        % disp(['V2X Eavesdropper密度:',num2str(testEavesdropperNum/testroadLen)]);
        testV2XEavesdroppers=[];
        parfor i=1:testroadNum
            curroad=testroads(i);
            tempEavesdropperNum = poissrnd(testEavesdropperDensity * curroad.len);
            testEavesdropperNum = testEavesdropperNum + tempEavesdropperNum;
            for j=1:tempEavesdropperNum
                %随机生成一个点
                t=rand();
                pointx=t*curroad.point1(1)+(1-t)*curroad.point2(1);
                pointy=t*curroad.point1(2)+(1-t)*curroad.point2(2);
                testV2Xe=V2XEavesdropper(pointx,pointy);
                %指定通信协议
                testV2Xe=getP(testV2Xe,DSRC,LTE,NR);
                %向当前道路上添加节点
                curroad.v2xEs=[curroad.v2xEs;testV2Xe];
                testV2XEavesdroppers=[testV2XEavesdroppers;testV2Xe];
            end
            testroads(i)=curroad;
            % p6=scatter(V2Xe.x, V2Xe.y, 100,'red','filled','pentagram');
            % hold on;
        end

        %% 计算本次生成后待测试节点的SINR
        
        %当前拟接入节点v2xr与典型车辆的距离
        roz=sqrt((v2xr.x-testVehicle.x)^2+(v2xr.y-testVehicle.y)^2);
        % 每个无线信道都经历独立的Nakagami-m衰落
        % [hoz,LOSoz]=getH(mL,mN,beta,roz);       %信道增益，服从伽马分布，归一化的伽马随机变量
        % 天线增益
        % Goz=getG(testVehicle,v2xr);
        %计算其他节点的干扰  IzV(其他V2X节点干扰)  IzB(其他基站的干扰)
        IzV=0;  %其他V2X节点干扰
        IzV1=0;  %其他V2X节点干扰
        IzV2=0;  %其他V2X节点干扰
        IzB=0;  %其他BS基站干扰
        IzB1=0;  %其他BS基站干扰
        IzB2=0;  %其他BS基站干扰
        %计算其他V2X节点的干扰
        parfor j=1:testTransmitterNum
            v2xt=testV2XTransmitters(j);
            %计算距离
            ruz=sqrt((v2xr.x-v2xt.x)^2+(v2xr.y-v2xt.y)^2);
            %每个无线信道都经历独立的Nakagami-m衰落
            [huz,LOSuz]=getH(mL,mN,beta,ruz);       %信道增益，服从伽马分布，归一化的伽马随机变量，Gamma(m, 1/m)，假定当前为视距(LOS)
            %确定天线增益
            Guz=getG(v2xt,v2xr);
            Guz1=getG(v2xt,v2xr1);
            Guz2=getG(v2xt,v2xr2);
            %当前节点的干扰
            if LOSuz
                I=v2xt.Pt*Guz*huz*(ruz^-alpL);
                I1=v2xt.Pt*Guz1*huz*(ruz^-alpL);
                I2=v2xt.Pt*Guz2*huz*(ruz^-alpL);
            else
                I=v2xt.Pt*Guz*huz*(ruz^-alpN);
                I1=v2xt.Pt*Guz1*huz*(ruz^-alpN);
                I2=v2xt.Pt*Guz2*huz*(ruz^-alpN);
            end
            IzV=IzV+I;
            IzV1=IzV1+I1;
            IzV2=IzV2+I2;
        end
        %计算其他BS基站的干扰
        parfor j=1:testBSNum
            obs=testBSs(j);
            %计算距离
            rwz=sqrt((v2xr.x-obs.x)^2+(v2xr.y-obs.y)^2);
            %每个无线信道都经历独立的Nakagami-m衰落
            [hwz,LOSwz]=getH(mL,mN,beta,rwz);      %信道增益，服从伽马分布，归一化的伽马随机变量，Gamma(m, 1/m)，假定当前为视距(LOS)
            %确定天线增益
            Gwz=getG(obs,v2xr);
            Gwz1=getG(obs,v2xr1);
            Gwz2=getG(obs,v2xr2);
            %当前节点的干扰
            if LOSwz
                I=obs.Pt*Gwz*hwz*(rwz^-alpL);
                I1=obs.Pt*Gwz1*hwz*(rwz^-alpL);
                I2=obs.Pt*Gwz2*hwz*(rwz^-alpL);
            else
                I=obs.Pt*Gwz*hwz*(rwz^-alpN);
                I1=obs.Pt*Gwz1*hwz*(rwz^-alpN);
                I2=obs.Pt*Gwz2*hwz*(rwz^-alpN);
            end
            IzB=IzB+I;
            IzB1=IzB1+I1;
            IzB2=IzB2+I2;
        end
        Iz=IzV+IzB;
        Iz1=IzV1+IzB;
        Iz2=IzV2+IzB;
        %计算当前V2XR的信干燥比
        if v2xr.LOS
            sinr=testVehicle.Pt*v2xr.G*v2xr.h*(roz^-alpL)/(Iz+PNoice);
        else
            sinr=testVehicle.Pt*v2xr.G*v2xr.h*(roz^-alpN)/(Iz+PNoice);
        end
        %计算当前V2XR1的信干噪比
        if v2xr1.LOS
            sinr1=testVehicle.Pt*v2xr1.G*v2xr1.h*(roz^-alpL)/(Iz1+PNoice);
        else
            sinr1=testVehicle.Pt*v2xr1.G*v2xr1.h*(roz^-alpN)/(Iz1+PNoice);
        end
        %计算当前V2XR2的信干噪比
        if v2xr2.LOS
            sinr2=testVehicle.Pt*v2xr2.G*v2xr2.h*(roz^-alpL)/(Iz2+PNoice);
        else
            sinr2=testVehicle.Pt*v2xr2.G*v2xr2.h*(roz^-alpN)/(Iz2+PNoice);
        end

        SINR=[SINR;sinr];
        SINR1=[SINR1;sinr1];
        SINR2=[SINR2;sinr2];

        % betae=sinr/3;
        % betae1=sinr1/3;
        % betae2=sinr2/3;
        %% 计算本次生成后所有窃听者的SINR
        v2xeSINR=[];v2xeSINR1=[];v2xeSINR2=[];
        %遍历每一个V2XEavesdropper节点计算信干噪比（SINR）
        parfor i=1:testEavesdropperNum
            v2xe=testV2XEavesdroppers(i);
            % 当前V2XEavesdropper与典型车辆的距离
            roe=sqrt((v2xe.x-testVehicle.x)^2+(v2xe.y-testVehicle.y)^2);
            % 每个无线信道都经历独立的Nakagami-m衰落
            [v2xe.h,v2xe.LOS]=getH(mL,mN,beta,roe);       %信道增益，服从伽马分布，归一化的伽马随机变量
            % 天线增益,v2xe通信协议应该与v2xr等保持一致
            Goe=getG(v2xr,v2xe);
            Goe1=getG(v2xr1,v2xe);
            Goe2=getG(v2xr2,v2xe);
            % 计算其他节点的干扰  IzV(其他V2X节点干扰)  IzB(其他基站的干扰)
            IeV=0;  %其他V2X节点干扰
            IeV1=0;  %其他V2X节点干扰
            IeV2=0;  %其他V2X节点干扰
            IeB=0;  %其他BS基站干扰
            IeB1=0;  %其他BS基站干扰
            IeB2=0;  %其他BS基站干扰
            % 计算其他V2X节点的干扰
            for j=1:testTransmitterNum
                ot=testV2XTransmitters(j);
                %计算距离
                rue=sqrt((ot.x-v2xe.x)^2+(ot.y-v2xe.y)^2);
                %每个无线信道都经历独立的Nakagami-m衰落
                [hue,LOSue]=getH(mL,mN,beta,rue);       %信道增益，服从伽马分布，归一化的伽马随机变量，Gamma(m, 1/m)
                %确定天线增益，v2xe通信协议应该与v2xr等保持一致
                Gue=getG(v2xr,ot);
                Gue1=getG(v2xr1,ot);
                Gue2=getG(v2xr2,ot);
                %当前节点的干扰
                if LOSue
                    I=ot.Pt*Gue*hue*(rue^-alpL);
                    I1=ot.Pt*Gue1*hue*(rue^-alpL);
                    I2=ot.Pt*Gue2*hue*(rue^-alpL);
                else
                    I=ot.Pt*Gue*hue*(rue^-alpN);
                    I1=ot.Pt*Gue1*hue*(rue^-alpN);
                    I2=ot.Pt*Gue2*hue*(rue^-alpN);
                end
                IeV=IeV+I;
                IeV1=IeV1+I1;
                IeV2=IeV2+I2;
            end
            %计算其他BS基站的干扰
            for j=1:testBSNum
                obs=testBSs(j);
                %计算距离
                rwe=sqrt((v2xe.x-obs.x)^2+(v2xe.y-obs.y)^2);
                %每个无线信道都经历独立的Nakagami-m衰落
                [hwe,LOSwe]=getH(mL,mN,beta,rwe);      %信道增益，服从伽马分布，归一化的伽马随机变量，Gamma(m, 1/m)，假定当前为视距(LOS)
                %确定天线增益，v2xe通信协议应该与v2xr等保持一致
                Gwe=getG(v2xr,v2xe);
                Gwe1=getG(v2xr1,v2xe);
                Gwe2=getG(v2xr2,v2xe);
                %当前节点的干扰
                if LOSwe
                    I=obs.Pt*Gwe*hwe*(rwe^-alpL);
                    I1=obs.Pt*Gwe1*hwe*(rwe^-alpL);
                    I2=obs.Pt*Gwe2*hwe*(rwe^-alpL);
                else
                    I=obs.Pt*Gwe*hwe*(rwe^-alpN);
                    I1=obs.Pt*Gwe1*hwe*(rwe^-alpN);
                    I2=obs.Pt*Gwe2*hwe*(rwe^-alpN);
                end
                IeB=IeB+I;
                IeB1=IeB1+I;
                IeB2=IeB2+I;
            end
            %计算当前V2XE的信干燥比
            if v2xe.LOS
            sinr=testVehicle.Pt*Goe*v2xe.h*(roe^-alpL)/(IeV+IeB+PNoice);
            sinr1=testVehicle.Pt*Goe1*v2xe.h*(roe^-alpL)/(IeV1+IeB1+PNoice);
            sinr2=testVehicle.Pt*Goe2*v2xe.h*(roe^-alpL)/(IeV2+IeB2+PNoice);
            else
            sinr=testVehicle.Pt*Goe*v2xe.h*(roe^-alpN)/(IeV+IeB+PNoice);
            sinr1=testVehicle.Pt*Goe1*v2xe.h*(roe^-alpN)/(IeV1+IeB+PNoice);
            sinr2=testVehicle.Pt*Goe2*v2xe.h*(roe^-alpN)/(IeV2+IeB+PNoice);
            end
            v2xeSINR=[v2xeSINR;sinr];
            v2xeSINR1=[v2xeSINR1;sinr1];
            v2xeSINR2=[v2xeSINR2;sinr2];
        end
        v2xeSINRs=[v2xeSINRs;max(v2xeSINR)];
        v2xeSINRs1=[v2xeSINRs1;max(v2xeSINR1)];
        v2xeSINRs2=[v2xeSINRs2;max(v2xeSINR2)];
%         if max(v2xeSINR)>betae
%             maxrounum=maxrounum+1;
%         end
%         if max(v2xeSINR)>betae1
%             maxrounum1=maxrounum1+1;
%         end
%         if max(v2xeSINR)>betae2
%             maxrounum2=maxrounum2+1;
%         end
    end

    %% 按照梯度计算COP,SOP
    cop=[];cop1=[];cop2=[];
    sop=[];sop1=[];sop2=[];
    db = -30:2:20;
    betats=[];betaes=[];
    betats1=[];betaes1=[];
    betats2=[];betaes2=[];
    for i=1:length(db)
        idb=db(i);
        tRt= 10 ^ (idb / 10);
        tRe= 10 ^ (idb / 10);
        %betat = 10 ^ (idb / 10);
        %betae = betat;
        B=v2xr.protocol.B;
        B1=v2xr1.protocol.B;
        B2=v2xr2.protocol.B;

        betat=2^(tRt/B)-1;
        betae=2^(tRe/B)-1;
        betat1=2^(tRt/B1)-1;
        betae1=2^(tRe/B1)-1;
        betat2=2^(tRt/B2)-1;
        betae2=2^(tRe/B2)-1;
        
        betats=[betats;betat];
        betats1=[betats1;betat1];
        betats2=[betats2;betat2];
        betaes=[betaes;betae];
        betaes1=[betaes1;betae1];
        betaes2=[betaes2;betae2];
        %SINRsum=sum(SINR);
        %SINRmax=max(SINR);
        %SINRmean=SINRsum/loop;
        
        cop=[cop;sum(SINR<betat)/loop];
        cop1=[cop1;sum(SINR1<betat1)/loop];
        cop2=[cop2;sum(SINR2<betat2)/loop];
        sop=[sop;sum(v2xeSINRs>betae)/loop];
        sop1=[sop1;sum(v2xeSINRs1>betae1)/loop];
        sop2=[sop2;sum(v2xeSINRs2>betae2)/loop];
    end
    
    v2x.cop=cop;
    v2x1.cop=cop1;
    v2x2.cop=cop2;
    
    v2x.sop=sop;
    v2x1.sop=sop1;
    v2x2.sop=sop2;

    copsopdata=[betats betats1 betats2 cop cop1 cop2 sop sop1 sop2];

end
