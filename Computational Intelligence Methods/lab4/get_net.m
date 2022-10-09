function [nets] = get_net(hidden_activation, train_fcn, n_perceptrons, X_trains, y_trains)
%GET_NET Summary of this function goes here
%   Detailed explanation goes here
nets = cell(5,5);
for i = 1:5
for j = 1:5
    net = feedforwardnet(n_perceptrons(i), train_fcn);
    net.layers{1}.transferFcn = hidden_activation;
    nets{i,j} = train(net, X_trains{j}, y_trains{j});
end
end
end

