function [predictor] = train_net(X_train, y_train)
    %shuffle
    XY = [X_train, y_train]
    XY = XY(randperm(size(XY, 1)), :);
    X_train = XY(:, 1:end-1);
    y_train = XY(:, end);

    net = perceptron();
    net = configure(net, X_train', y_train');
    

    predictor = train(net, X_train', y_train');
end

