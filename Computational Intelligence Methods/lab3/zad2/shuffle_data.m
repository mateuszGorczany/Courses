function [X, y] = shuffle_data(X, y)
    % shuffle
    indices = randperm(size(X, 1));
    X = X(indices, :);
    y = y(indices, :);
end

