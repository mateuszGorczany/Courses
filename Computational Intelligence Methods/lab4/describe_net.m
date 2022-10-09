function [] = describe_net(net, X_test, y_test, my_mse, activations, n_el)
%DESCRIBE_NET Summary of this function goes here
%   Detailed explanation goes here
tl0 = tiledlayout(3,2); % Requires R2019b or later
n_perceptrons = net{1}.layerWeights{2,1}.size(2);
n_els = [10, 20, 50, 100, 200];
for i = 1:5
ax = nexttile(tl0);
y_pred = net{i}(X_test);
%clf;
plot(ax, X_test, y_pred)
hold on;
plot(ax, X_test, y_test)

title( "Train size: " + num2str(n_els(i)) + ...
    ", MSE: " + num2str(my_mse(y_test, y_pred))...
    );
end
tl0.Title.String = "Hidden perceptrons: " + num2str(n_perceptrons)...
    + ", activation: " + activations;
end

