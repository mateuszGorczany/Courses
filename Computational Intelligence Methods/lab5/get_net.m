function [net] = get_net(X_train, y_train, neurons, hidden_activation, out_activation, epochs, trainfc)
%GET_NET Summary of this function goes here
%   Detailed explanation goes here
net = feedforwardnet(neurons, trainfc);
net = configure(net, X_train', y_train');
net.layers{1}.transferFcn = hidden_activation;
net.layers{2}.transferFcn = out_activation;
net.divideFcn = 'dividetrain';
net.trainParam.epochs = epochs;

net = train(net, X_train', y_train');
end

