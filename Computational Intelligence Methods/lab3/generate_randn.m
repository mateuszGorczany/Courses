function [X] = generate_randn(mean, std, data_length)
    X = [std.*randn(data_length,1)+mean(1), std.*randn(data_length,1)+mean(2)]
end