function [X, Y] = generate_data(data_length)
    X1 = normrnd(0,1, [data_length,2]);
    X2 = normrnd(2,1, [data_length,2]);
    XY1 = [X1, ones(data_length,1)];
    XY2 = [X2, zeros(data_length,1)];
    
    % concatenate 2 classes
    XY = [XY1; XY2];
    
    % shuffle
    XY = XY(randperm(size(XY, 1)), :);
    
    X = XY(:, 1:2);
    Y = XY(:, 3);
end