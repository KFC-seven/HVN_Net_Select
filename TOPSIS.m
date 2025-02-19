function TOPSISCandidates = TOPSIS(AHPMatrix,TOPSISCandidates)
    %设定评价指标数
    n = 5; 

    %构建评价矩阵
    decisionMatrix = zeros(length(TOPSISCandidates), n);

    %将候选网络的指标参数输入评价矩阵
    index = {'sop', 'cop', 'delay', 'bandwidth', 'plr'};
    for i = 1:length(TOPSISCandidates)
        for j = 1:n
            decisionMatrix(i, j) = TOPSISCandidates(i).(index{j});
        end
    end

    %打印待评估表格
    cop = decisionMatrix(:,1);
    sop = decisionMatrix(:,2);
    delay = decisionMatrix(:,3);
    bandwidth = decisionMatrix(:,4);
    plr = decisionMatrix(:,5);
    disp('待评估网络：');
    table(sop,cop,delay,bandwidth,plr)
    
    %定义哪些列是极小值类型的列
    smallerIsBetterCols = [1, 2, 3, 5];
    %评价矩阵中若元素为0，则加1/loop，以保证正向化后不会出现无穷大的情况
    for i = 1:length(TOPSISCandidates)
        if decisionMatrix(i,1) == 0.0
            decisionMatrix(i,1) = 1/1000;
        end
        if decisionMatrix(i,2) == 0.0
            decisionMatrix(i,2) = 1/1000;
        end
    end
    
    %对评价矩阵进行正向化
    normalizedMatrix = decisionMatrix;
    decisionMatrix(:, smallerIsBetterCols) = 1 ./ normalizedMatrix(:, smallerIsBetterCols);

    %打印正向化后的待评估矩阵
    cop = decisionMatrix(:,1);
    sop = decisionMatrix(:,2);
    delay = decisionMatrix(:,3);
    bandwidth = decisionMatrix(:,4);
    plr = decisionMatrix(:,5);
    disp('正向化后的待评估网络矩阵：');
    table(sop,cop,delay,bandwidth,plr)

    % AHP权重计算
    [ahpWeights, ~] = AHP(AHPMatrix);

    % EWM权重计算
    ewmWeights = EWM(decisionMatrix);

    % 综合权重（这里简单地取平均，你可以根据需要调整权重）
    combinedWeights = 0.7*ahpWeights + 0.3*ewmWeights;
    disp('计算得到的混合权重：');
    disp(combinedWeights);
    
    % 使用综合权重进行TOPSIS评估
    normalizedDecisionMatrix = NormalizeDecisionMatrix(decisionMatrix);
    cop = normalizedDecisionMatrix(:,1);
    sop = normalizedDecisionMatrix(:,2);
    delay = normalizedDecisionMatrix(:,3);
    bandwidth = normalizedDecisionMatrix(:,4);
    plr = normalizedDecisionMatrix(:,5);
    disp('归一化后的待评估网络矩阵：');
    table(sop,cop,delay,bandwidth,plr) 
    weightedNormalizedMatrix = combinedWeights .* normalizedDecisionMatrix;

    % 计算理想解和负理想解
    idealSolution = max(weightedNormalizedMatrix);
    negativeIdealSolution = min(weightedNormalizedMatrix);

    % 计算距离度量（距离越小越好）
    distanceToIdeal = sqrt(sum((weightedNormalizedMatrix - idealSolution).^2, 2));
    distanceToNegativeIdeal = sqrt(sum((weightedNormalizedMatrix - negativeIdealSolution).^2, 2));

    % 计算综合得分（距离越小越好）
    combinedScores = distanceToNegativeIdeal ./ (distanceToIdeal + distanceToNegativeIdeal);
    
    % 记录各网络综合得分
    for i=1:length(combinedScores)
        TOPSISCandidates(i).combinedScore = combinedScores(i);
    end

    % 显示综合得分
    disp('综合得分：');
    disp(combinedScores);
end

function normalizedMatrix = NormalizeDecisionMatrix(matrix)
    % 计算每列的极差
    columnRanges = max(matrix) - min(matrix);

    % 找出极差为零的列的索引
    zeroRangeColumns = (columnRanges == 0);

    % 归一化决策矩阵（每列归一化到 [0, 1] 范围）
    normalizedMatrix = matrix - min(matrix);
    normalizedMatrix = normalizedMatrix ./ (max(matrix)-min(matrix));

    % 将极差为零的列的值设置为1
    normalizedMatrix(:, zeroRangeColumns) = 1; % 设置为1
end