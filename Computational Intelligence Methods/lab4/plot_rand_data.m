function [] = plot_rand_data(net, X, y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
clf;
y_pred = net(X);
scatter(X, y)
hold on;
plot(X, y_pred)
end

