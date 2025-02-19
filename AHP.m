% function [weights, consistencyRatio] = AHP(judgmentMatrix)
%     % 计算权重和一致性比率
%     [~, eigenvectors] = eig(judgmentMatrix);
% 
%     % 获取最大特征值和对应的特征向量
%     [maxEigenvalue, maxEigenvalueIndex] = max(diag(eigenvectors));
% 
%     % 获取对应的特征向量
%     principalEigenvector = eigenvectors(:, maxEigenvalueIndex);
% 
%     % 归一化特征向量
%     weights = principalEigenvector / maxEigenvalue;
%     weights = weights';
%     % 计算一致性指标（CI）
%     n = length(weights);
%     consistencyIndex = (max(diag(eigenvectors)) - n) / (n - 1);
% 
%     % 从文献中获取的随机一致性指标（RI）的值
%     randomIndex = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45];
% 
%     % 计算一致性比率（CR）
%     consistencyRatio = consistencyIndex / randomIndex(n);
% 
%     % 显示权重和一致性比率
%     disp('计算得到的权重：');
%     disp(weights);
%     disp(['一致性比率 (CR): ', num2str(consistencyRatio)]);
% 
%     % 如果一致性比率超过某个阈值，可以考虑进行调整或重新评估
%     threshold = 0.1;
%     if consistencyRatio > threshold
%         warning('一致性比率超过阈值，可能需要重新评估判断矩阵的一致性。');
%     end
% end

function [weights, consistency_ratio] = AHP(decision_matrix)
    % AHP算法函数，输入决策矩阵，输出权重和一致性比率

    % 计算权重
    [n, ~] = size(decision_matrix);
    eigenvalues = eig(decision_matrix);
    max_eigenvalue = max(eigenvalues);
    index_max_eigenvalue = find(eigenvalues == max_eigenvalue);
    principal_eigenvector = null(decision_matrix - max_eigenvalue * eye(n));
    weights = principal_eigenvector / sum(principal_eigenvector);
    weights = weights';

    % 一致性检查
    consistency_index = (max_eigenvalue - n) / (n - 1);
    random_index = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45, 1.49];
    consistency_ratio = consistency_index / random_index(n);

    % 如果一致性比率超过某个阈值，可以考虑进行调整或重新评估
    threshold = 0.2;
    if consistency_ratio > threshold
       warning('一致性比率超过阈值，可能需要重新评估判断矩阵的一致性。');
    end

    % 显示结果
    disp('AHP计算得到的权重：');
    disp(weights);
    disp(['一致性比率：', num2str(consistency_ratio)]);

end
