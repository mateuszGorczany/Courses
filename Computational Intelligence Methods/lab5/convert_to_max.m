function [y_pred2] = convert_to_max(y_pred)
%CONVERT_TO_MAX Summary of this function goes here
%   Detailed explanation goes here
y_pred2 = zeros(size(y_pred,1), size(y_pred,2));
for i = 1:size(y_pred,1)
    max_idxs = find(y_pred(i,:)==max(y_pred(i,:)));
    if length(max_idxs) > 1
        for j = 1:length(max_idxs)
            y_pred2(i, max_idxs(j)) = 1;
        end
    else
        y_pred2(i, max_idxs) = 1;
    end
    
end
end

