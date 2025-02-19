function EWM_weights = EWM(decisionMatrix)
    %设定评价指标数
    % n = 5;

    % %构建评价矩阵
    % decisionMatrix = zeros(length(Candidates), n);
    % 
    % %将候选网络的指标参数输入评价矩阵
    % index = {'sop', 'cop', 'delay', 'bandwidth', 'plr'};
    % for i = 1:length(Candidates)
    %     for j = 1:n
    %         decisionMatrix(i, j) = Candidates(i).(index{j});
    %     end
    % end
    % 
    % %对评价矩阵进行正向化
    % %定义哪些列是极小值类型的列
    % smallerIsBetterCols = [1, 2, 3, 5];
    % normalizedMatrix = decisionMatrix;
    % decisionMatrix(:, smallerIsBetterCols) = 1 ./ normalizedMatrix(:, smallerIsBetterCols);
    % 
    % %打印正向化后的待评估矩阵
    % cop = decisionMatrix(:,1);
    % sop = decisionMatrix(:,2);
    % delay = decisionMatrix(:,3);
    % bandwidth = decisionMatrix(:,4);
    % plr = decisionMatrix(:,5);
    % disp('正向化后的待评估网络矩阵：');
    % table(sop,cop,delay,bandwidth,plr)

    % 归一化输入的矩阵
    normalizedMatrix = decisionMatrix ./ sum(decisionMatrix, 1);
    % 计算权重
    entropyValues = -sum(normalizedMatrix .* log2(normalizedMatrix), 1);
    EWM_weights = (1 - entropyValues) / sum(1 - entropyValues);

    % 显示权重
    disp('EWM计算得到的权重：');
    disp(EWM_weights);
end
