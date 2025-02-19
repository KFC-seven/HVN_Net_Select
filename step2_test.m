%% 通过期望得到连接中断概率COP和保密中断概率SOP
close all; clearvars; clc;

v2xRTDensity=5;

% 文件路径
figFolder=strcat('./fig/v60/',num2str(v2xRTDensity),'/');
tmpDataFolder=strcat('./tmp/v60/',num2str(v2xRTDensity),'/');
dataFolder=strcat('./data1/v60/',num2str(v2xRTDensity),'/');
files=dir(strcat("./tmp/v60/",num2str(v2xRTDensity),"/small*.mat"));
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

% V2XReceivers=[];V2XReceivers1=[];V2XReceivers2=[];
% V2XTransmitters=[];V2XTransmitters1=[];V2XTransmitters2=[];
% BSs=[];BSs1=[];BSs2=[];
%参数和距离相关，alph为控制因子
alph = 5;
beta = 2;

copsopdata=[];

for fileIndex=1:length(files)
    V2XReceivers=[];V2XReceivers1=[];V2XReceivers2=[];
    V2XTransmitters=[];V2XTransmitters1=[];V2XTransmitters2=[];
    BSs=[];BSs1=[];BSs2=[];
    copsopdata1=[];copsopdata2=[];copsopdata3=[];
    filename = fullfile(files(fileIndex).folder,files(fileIndex).name);
    disp(['[+]正在计算：',filename]);
    load(filename);
    testVehicle = Vehicle;
    parfor i=1:length(smallv2xRs)
        v2xr=smallv2xRs(i);
        %生成其余两种网络制式的V2XTransmitters对象
        V2Xr1 = v2xr;
        V2Xr2 = v2xr;
        smallv2xRs(i)=v2xr;
        protocol=v2xr.protocol;
        %1 2 3分别代表DSRC LTE NR
        % index = {'1', '2', '3'};
        index = {1, 2, 3};
        if protocol.name == index{1}
            v2xr.protocol = DSRC;
            V2Xr1.protocol = LTE;
            V2Xr2.protocol = NR;
        elseif protocol.name == index{2}
            v2xr.protocol = LTE;
            V2Xr1.protocol = DSRC;
            V2Xr2.protocol = NR;
        elseif protocol.name == index{3}
            v2xr.protocol = NR;
            V2Xr1.protocol = DSRC;
            V2Xr2.protocol = LTE;
        end 
        

        [v2xr,V2Xr1,V2Xr2,copsop1] = COPSOP_test(v2xr,V2Xr1,V2Xr2,smallr,Vehicle,v2xRTDensity);
        copsopdata1=[copsopdata1;copsop1];
        roz=sqrt((v2xr.x-testVehicle.x)^2+(v2xr.y-testVehicle.y)^2);
%         disp(['第',num2str(i),'个Receiver(',num2str(v2xr.x),',',num2str(v2xr.y),')的roz：',num2str(roz),' cop：',num2str(v2xr.cop),' sop：',num2str(v2xr.sop)]);
%         disp(['第',num2str(i),'个Receiver(',num2str(V2Xr1.x),',',num2str(V2Xr1.y),')的roz：',num2str(roz),' cop：',num2str(V2Xr1.cop),' sop：',num2str(V2Xr1.sop)]);
%         disp(['第',num2str(i),'个Receiver(',num2str(V2Xr2.x),',',num2str(V2Xr2.y),')的roz：',num2str(roz),' cop：',num2str(V2Xr2.cop),' sop：',num2str(V2Xr2.sop)]);
        protocol = V2Xr1.protocol;
        while 1
            V2Xr1.delay = exp(alph*V2Xr1.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
            V2Xr1.bandwidth = exp(-alph*V2Xr1.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            V2Xr1.plr = exp(alph*V2Xr1.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
            V2Xr1.jitter = exp(alph*V2Xr1.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
            V2Xr1.ber = exp(alph*V2Xr1.ro)+normrnd(protocol.ber,protocol.berflu)-1;
            V2Xr1.rss = protocol.rss/exp(beta*V2Xr1.ro)-130;
            V2Xr1.cost = protocol.cost;
            V2Xr1.ee = protocol.ee;
            if V2Xr1.delay > 0 && V2Xr1.bandwidth > 0 && V2Xr1.plr >0 && V2Xr1.jitter >0 && V2Xr1.ber >0
                break;
            end
        end

        protocol = V2Xr2.protocol;
        while 1
            V2Xr2.delay = exp(alph*V2Xr2.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
            V2Xr2.bandwidth = exp(-alph*V2Xr2.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            V2Xr2.plr = exp(alph*V2Xr2.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
            V2Xr2.jitter = exp(alph*V2Xr2.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
            V2Xr2.ber = exp(alph*V2Xr2.ro)+normrnd(protocol.ber,protocol.berflu)-1;
            V2Xr2.rss = protocol.rss/exp(beta*V2Xr2.ro)-130;
            V2Xr2.cost = protocol.cost;
            V2Xr2.ee = protocol.ee;
            if V2Xr2.delay > 0 && V2Xr2.bandwidth > 0 && V2Xr2.plr >0 && V2Xr2.jitter >0 && V2Xr2.ber >0
                break;
            end
        end

        % roz=sqrt((v2xr.x-testVehicle.x)^2+(v2xr.y-testVehicle.y)^2);
        % disp(['第',num2str(i),'个Receiver(',num2str(v2xr.x),',',num2str(v2xr.y),')的roz：',num2str(roz),' cop：',num2str(v2xr.cop),' sop：',num2str(v2xr.sop)]);
        V2XReceivers=[V2XReceivers;v2xr];
        V2XReceivers1=[V2XReceivers1;V2Xr1];
        V2XReceivers2=[V2XReceivers2;V2Xr2];
    end
    
    parfor i=1:length(smallv2xTs)
        V2Xt=smallv2xTs(i);
        %生成其余两种网络制式的V2XTransmitters对象
        V2Xt1 = V2Xt;
        V2Xt2 = V2Xt;
        smallv2xTs(i)=V2Xt;
        protocol=V2Xt.protocol;
        %1 2 3分别代表DSRC LTE NR
        % index = {'1', '2', '3'};
        index = {1, 2, 3};
        if protocol.name == index{1}
            V2Xt.protocol = DSRC;
            V2Xt1.protocol = LTE;
            V2Xt2.protocol = NR;
        elseif protocol.name == index{2}
            V2Xt.protocol = LTE;
            V2Xt1.protocol = DSRC;
            V2Xt2.protocol = NR;
        elseif protocol.name == index{3}
            V2Xt.protocol = NR;
            V2Xt1.protocol = DSRC;
            V2Xt2.protocol = LTE;
        end 
        

        [V2Xt,V2Xt1,V2Xt2,copsop2] = COPSOP_test(V2Xt,V2Xt1,V2Xt2,smallr,Vehicle,v2xRTDensity);
        copsopdata2=[copsopdata2;copsop2];
        roz=sqrt((V2Xt.x-testVehicle.x)^2+(V2Xt.y-testVehicle.y)^2);
%         disp(['第',num2str(i),'个Transmitter(',num2str(V2Xt.x),',',num2str(V2Xt.y),')的roz：',num2str(roz),' cop：',num2str(V2Xt.cop),' sop：',num2str(V2Xt.sop)]);
%         disp(['第',num2str(i),'个Transmitter(',num2str(V2Xt1.x),',',num2str(V2Xt1.y),')的roz：',num2str(roz),' cop：',num2str(V2Xt1.cop),' sop：',num2str(V2Xt1.sop)]);
%         disp(['第',num2str(i),'个Transmitter(',num2str(V2Xt2.x),',',num2str(V2Xt2.y),')的roz：',num2str(roz),' cop：',num2str(V2Xt2.cop),' sop：',num2str(V2Xt2.sop)]);
        protocol = V2Xt1.protocol;
        while 1
            V2Xt1.delay = exp(alph*V2Xt1.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
            V2Xt1.bandwidth = exp(-alph*V2Xt1.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            V2Xt1.plr = exp(alph*V2Xt1.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
            V2Xt1.jitter = exp(alph*V2Xt1.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
            V2Xt1.ber = exp(alph*V2Xt1.ro)+normrnd(protocol.ber,protocol.berflu)-1;
            V2Xt1.rss = protocol.rss/exp(beta*V2Xt1.ro)-130;
            V2Xt1.cost = protocol.cost;
            V2Xt1.ee = protocol.ee;
            if V2Xt1.delay > 0 && V2Xt1.bandwidth > 0 && V2Xt1.plr >0 && V2Xt1.jitter >0 && V2Xt1.ber >0
                break;
            end
        end

        protocol = V2Xt2.protocol;
        while 1
            V2Xt2.delay = exp(alph*V2Xt2.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
            V2Xt2.bandwidth = exp(-alph*V2Xt2.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            V2Xt2.plr = exp(alph*V2Xt2.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
            V2Xt2.jitter = exp(alph*V2Xt2.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
            V2Xt2.ber = exp(alph*V2Xt2.ro)+normrnd(protocol.ber,protocol.berflu)-1;
            V2Xt2.rss = protocol.rss/exp(beta*V2Xt2.ro)-130;
            V2Xt2.cost = protocol.cost;
            V2Xt2.ee = protocol.ee;
            if V2Xt2.delay > 0 && V2Xt2.bandwidth > 0 && V2Xt2.plr >0 && V2Xt2.jitter >0 && V2Xt2.ber >0
                break;
            end
        end

        V2XTransmitters=[V2XTransmitters;V2Xt];
        V2XTransmitters1=[V2XTransmitters1;V2Xt1];
        V2XTransmitters2=[V2XTransmitters2;V2Xt2];

        % roz=sqrt((v2xr.x-testVehicle.x)^2+(v2xr.y-testVehicle.y)^2);
        % disp(['第',num2str(i),'个Transmitter(',num2str(v2xr.x),',',num2str(v2xr.y),')的roz：',num2str(roz),' cop：',num2str(v2xr.cop),' sop：',num2str(v2xr.sop)]);
          
    end
    
    parfor i=1:length(smallBSs)
        bs=smallBSs(i);
        %生成其余两种网络制式的BS对象
        bs1 = bs;
        bs2 = bs;
        smallBSs(i)=bs;
        protocol=bs.protocol;
        %1 2 3分别代表DSRC LTE NR
        % index = {'1', '2', '3'};
        index = {1, 2, 3};
        if protocol.name == index{1}
            bs.protocol = DSRC;
            bs1.protocol = LTE;
            bs2.protocol = NR;
        elseif protocol.name == index{2}
            bs.protocol = LTE;
            bs1.protocol = DSRC;
            bs2.protocol = NR;
        elseif protocol.name == index{3}
            bs.protocol = NR;
            bs1.protocol = DSRC;
            bs2.protocol = LTE;
        end 
        

        [bs,bs1,bs2,copsop3] = COPSOP_test(bs,bs1,bs2,smallr,Vehicle,v2xRTDensity);
        copsopdata3=[copsopdata3;copsop3];
        roz=sqrt((bs.x-testVehicle.x)^2+(bs.y-testVehicle.y)^2);
%         disp(['第',num2str(i),'个bs(',num2str(bs.x),',',num2str(bs.y),')的roz：',num2str(roz),' cop：',num2str(bs.cop),' sop：',num2str(bs.sop)]);
%         disp(['第',num2str(i),'个bs(',num2str(bs1.x),',',num2str(bs1.y),')的roz：',num2str(roz),' cop：',num2str(bs1.cop),' sop：',num2str(bs1.sop)]);
%         disp(['第',num2str(i),'个bs(',num2str(bs2.x),',',num2str(bs2.y),')的roz：',num2str(roz),' cop：',num2str(bs2.cop),' sop：',num2str(bs2.sop)]);
        protocol = bs1.protocol;
        while 1
            bs1.delay = exp(alph*bs1.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
            bs1.bandwidth = exp(-alph*bs1.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            bs1.plr = exp(alph*bs1.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
            bs1.jitter = exp(alph*bs1.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
            bs1.ber = exp(alph*bs1.ro)+normrnd(protocol.ber,protocol.berflu)-1;
            bs1.rss = protocol.rss/exp(beta*bs1.ro)-130;
            bs1.cost =  protocol.cost;
            bs1.ee =  protocol.ee;
            if bs1.delay > 0 && bs1.bandwidth > 0 && bs1.plr >0 && bs1.jitter >0 && bs1.ber >0
                break;
            end
        end

        protocol = bs2.protocol;
        while 1
            bs2.delay = exp(alph*bs2.ro)+normrnd(protocol.delay,protocol.delayflu)-1;
            bs2.bandwidth = exp(-alph*bs2.ro)*normrnd(protocol.bandwidth,protocol.bandwidthflu);
            bs2.plr = exp(alph*bs2.ro)+normrnd(protocol.plr,protocol.plrflu)-1;
            bs2.jitter = exp(alph*bs2.ro)+normrnd(protocol.jitter,protocol.jitterflu)-1;
            bs2.ber = exp(alph*bs2.ro)+normrnd(protocol.ber,protocol.berflu)-1;
            bs2.rss = protocol.rss/exp(beta*bs2.ro)-130;
            bs2.cost = protocol.cost;
            bs2.ee = protocol.ee;
            if bs2.delay > 0 && bs2.bandwidth > 0 && bs2.plr >0 && bs2.jitter >0 && bs2.ber >0
                break;
            end
        end

        BSs=[BSs;bs];
        BSs1=[BSs1;bs1];
        BSs2=[BSs2;bs2];
        
        % disp(['第',num2str(i),'个BS(',num2str(v2xr.x),',',num2str(v2xr.y),')的rob：',num2str(rob),' cop：',num2str(v2xr.cop),' sop：',num2str(v2xr.sop)]);
        smallBSs(i)=bs;
    end
    
    %将三种网络制式的对象分别存储到一起
    V2XReceivers = [V2XReceivers;V2XReceivers1;V2XReceivers2];
    V2XTransmitters = [V2XTransmitters;V2XTransmitters1;V2XTransmitters2];
    BSs = [BSs;BSs1;BSs2];
%     copsopdata=[copsopdata1;copsopdata2;copsopdata3];
    savefilename=fullfile(dataFolder,files(fileIndex).name);
    save(savefilename);
    % clearvars V2XReceivers V2XReceivers1 V2XReceivers2 V2XTransmitters V2XTransmitters1 V2XTransmitters2;
%     break
end
disp('[!]SOP/COP计算完成...');


