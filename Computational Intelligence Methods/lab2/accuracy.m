function [acc] = accuracy(net, X_test, y_test)
%ACCURACY Summary of this function goes here
%   Detailed explanation goes here
y_predict = net(X_test');
good_predictions = y_predict == y_test';
acc = sum(good_predictions)/length(good_predictions)
end

