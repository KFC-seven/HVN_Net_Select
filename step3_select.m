%% 对每个网络进行筛选并做评估
close all; clearvars; clc;

v2xRTDensity = 6;

% 文件路径
files=dir(strcat('./data/v60/',num2str(v2xRTDensity),'/small*.mat'));
filesFolder=strcat('./data/v60/',num2str(v2xRTDensity),'/');

for fileIndex=1:length(files)
    %对文件重新排序
    for i = 1 : numel(files)
        numsort(i)=str2num(files(i).name(13:eval('length(files(i).name)-9')));
    end
    [~,index] = sort(numsort);
    files = files(index);
    %对各类型网络进行模糊数学筛选并转换成候选网络类型的对象
    files(fileIndex).folder=filesFolder;
    filename = fullfile(files(fileIndex).folder,files(fileIndex).name);
    disp(['[+]正在计算：',filename]);
    load(filename);
    dataFolder=strcat('./data/v60_down/',num2str(v2xRTDensity),'/');
    %把基站的速度设为0
    for i = 1:length(BSs)
        BSs(i).ms = 0;
    end

    Candidates = [];
    for i =1:length(V2XTransmitters)
        tmp_Candidates = Candidate(V2XTransmitters(i));
        Candidates = [Candidates;tmp_Candidates];
    end
    for i =1:length(V2XReceivers)
        tmp_Candidates = Candidate(V2XReceivers(i));
        Candidates = [Candidates;tmp_Candidates];
    end
    for i =1:length(BSs)
        tmp_Candidates = Candidate(BSs(i));
        Candidates = [Candidates;tmp_Candidates];
    end

    Candidates = fuzzy_logic(Candidates);
    % Candidates = [Candidates;Candidate(fuzzy_logic(V2XTransmitters))];
    % Candidates = [Candidates;Candidate(fuzzy_logic(V2XReceivers))];
    % Candidates = [Candidates;Candidate(fuzzy_logic(BSs))];

    security_judgmentMatrix = [1,1/7,1/7,1/5,1/3;
        7, 1, 1/2,1/3, 2 ;
        7, 2,  1,  3,  2 ;
        5, 3, 1/3, 1, 1/2;
        3,1/2,1/2, 2,  1];

    efficiency_judgmentMatrix = [ 1, 1/7, 3, 1/5, 3;
        7,  1,  5,  3,  7;
        1/3,1/5, 1, 1/3, 2;
        5, 1/3, 3,  1,  3;
        1/3,1/7,1/2,1/3, 1];

    services_judgmentMatrix = [ 1,  5,  3,  5, 7;
        1/5, 1, 1/5,1/3,3;
        1/3, 5,  1,  3, 3;
        1/5, 3, 1/3, 1,1/2;
        1/7,1/3,1/3, 2, 1];

    %对候选网络进行评分
    Candidates_sec = TOPSIS(security_judgmentMatrix, Candidates);
    Candidates_eff = TOPSIS(efficiency_judgmentMatrix, Candidates);
    Candidates_ser = TOPSIS(services_judgmentMatrix, Candidates);

    %找到安全类服务得分最高的网络
    Network_sec = Candidates_sec(1);
    for i = 1:length(Candidates_sec)
        if Candidates_sec(i).combinedScore > Network_sec.combinedScore
            Network_sec = Candidates_sec(i);
        end
    end

    %找到效率类服务得分最高的网络
    Network_eff = Candidates_eff(1);
    for i = 1:length(Candidates_eff)
        if Candidates_eff(i).combinedScore > Network_eff.combinedScore
            Network_eff = Candidates_eff(i);
        end
    end

    %找到信息类服务得分最高的网络
    Network_ser = Candidates_ser(1);
    for i = 1:length(Candidates_ser)
        if Candidates_ser(i).combinedScore > Network_ser.combinedScore
            Network_ser = Candidates_ser(i);
        end
    end

    %展示选择的网络信息
    disp(Network_sec);
    disp(Network_eff);
    disp(Network_ser);
    disp(['安全类服务选择的节点坐标是：(',num2str(Network_sec.x),',',num2str(Network_sec.y),')。ro：',num2str(Network_sec.ro),' sop：',num2str(Network_sec.sop),' cop：',num2str(Network_sec.cop),' delay：',num2str(Network_sec.delay),' bandwith：',num2str(Network_sec.bandwidth),' plr：',num2str(Network_sec.plr),'得分是：',num2str(Network_sec.combinedScore)]);
    disp(['效率类服务选择的节点坐标是：(',num2str(Network_eff.x),',',num2str(Network_eff.y),')。ro：',num2str(Network_eff.ro),' sop：',num2str(Network_eff.sop),' cop：',num2str(Network_eff.cop),' delay：',num2str(Network_eff.delay),' bandwith：',num2str(Network_eff.bandwidth),' plr：',num2str(Network_eff.plr),'得分是：',num2str(Network_eff.combinedScore)]);
    disp(['信息类服务选择的节点坐标是：(',num2str(Network_ser.x),',',num2str(Network_ser.y),')。ro：',num2str(Network_ser.ro),' sop：',num2str(Network_ser.sop),' cop：',num2str(Network_ser.cop),' delay：',num2str(Network_ser.delay),' bandwith：',num2str(Network_ser.bandwidth),' plr：',num2str(Network_ser.plr),'得分是：',num2str(Network_ser.combinedScore)]);
    
    savefilename=fullfile(dataFolder,files(fileIndex).name);
    save(savefilename);
end
% %设定评价指标数
% n = 5;
% 
% %构建评价矩阵
% decisionMatrix = zeros(length(Trans_Can)+length(Rece_Can)+length(BS_Can), n);
% 
% %将候选网络的指标参数输入评价矩阵
% index = {'sop', 'cop', 'delay', 'bandwidth', 'plr'};
% for i = 1:length(Trans_Can)
%     for j = 1:n
%         decisionMatrix(i, j) = Trans_Can(i).(index{j});
%     end
% end
% 
% for i = 1:length(Rece_Can)
%     for j = 1:n
%         decisionMatrix(length(Trans_Can)+i, j) = Rece_Can(i).(index{j});
%     end
% end
% 
% for i = 1:length(BS_Can)
%     for j = 1:n
%         decisionMatrix(length(Trans_Can)+length(Rece_Can)+i, j) = BS_Can(i).(index{j});
%     end
% end
