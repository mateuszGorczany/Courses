function [good_predictions] = compare_outputs(y_test, y_pred)
%COMPARE_OUTPUTS Summary of this function goes here
%   Detailed explanation goes here
good_predictions = zeros(size(y_pred,1), 1);
for i = 1:size(y_test, 1)
        good_predictions(i) = isequal(y_test(i,:), y_pred(i,:));
end
end

