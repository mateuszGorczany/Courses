function [acc] = output_accuracy(y_test, y_pred)
%OUTPUT_ACCURACY Summary of this function goes here
%   Detailed explanation goes here
acc = sum(compare_outputs(y_test, convert_to_max(y_pred)))/size(y_pred,1);
end

