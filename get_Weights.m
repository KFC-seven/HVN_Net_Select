%AHP参数
% 指定评价指标个数
n = 5;

% 分别初始化安全、效率和信息服务类的AHP判断矩阵
security_judgmentMatrix = zeros(n);
efficiency_judgmentMatrix = zeros(n);
services_judgmentMatrix = zeros(n);

% 分别设定三类判定矩阵
security_judgmentMatrix = [ 1, 1/2,1/7,3,1/7;
                            2,  1, 1/5,5,1/5
                            7,  5,  1, 7, 2 
                           1/3,1/5,1/7,1,1/7
                            7,  5, 1/2,7, 1];

efficiency_judgmentMatrix = [ 1, 1/2,1/7,3,1/7;
                              2,  1, 1/5,5,1/5
                              7,  5,  1, 7, 2 
                             1/3,1/5,1/7,1,1/7
                              7,  5, 1/2,7, 1];

services_judgmentMatrix = [ 1,  9,  3,  5, 7;
                           1/9, 1, 1/5,1/3,1;
                           1/3, 5,  1,  3, 3;
                           1/5, 3, 1/3, 1,1/2;
                           1/7, 1, 1/3, 2, 1];


%%计算各类服务的混合权重
function mixedWeights = MixedWeightAlgorithm(AHPMatrix, EWMCandidates)
    % AHP权重计算
    [ahpWeights, ~] = AHP(AHPMatrix);

    % EWM权重计算
    ewmWeights = EWM(EWMCandidates);

    % 综合权重（这里简单地取平均，你可以根据需要调整权重）
    mixedWeights = (ahpWeights + ewmWeights) / 2;

    % 显示各个权重
    disp('AHP 计算得到的权重：');
    disp(ahpWeights);

    disp('EWM 计算得到的权重：');
    disp(ewmWeights);

    disp('混合权重：');
    disp(mixedWeights);
end
