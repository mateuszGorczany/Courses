function [replacement] = convert_to_1d(y)
%CONVERT_TO_1D Summary of this function goes here
%   Detailed explanation goes here
replacement = zeros(length(y),4);
for i = 1:length(y)
    if y(i,1) == -1 && y(i,2) == 1
        replacement(i,1) = 1;
    end
    if y(i,1) == 1 && y(i,2) == 1
        replacement(i,2) = 1;
    end
    if y(i,1) == 1 && y(i,2) == -1
        replacement(i,3) = 1;
    end
    if y(i,1) == -1 && y(i,2) == -1
        replacement(i,4) = 1;
    end
end

end

