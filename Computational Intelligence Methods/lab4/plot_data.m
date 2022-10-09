function [] = plot_data(net, X, y)
%PLOT_DATA Summary of this function goes here
%   Detailed explanation goes here
clf;
y_pred = net(X);
plot(X, y)
hold on;
plot(X, y_pred)
end

