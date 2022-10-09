function [X_train, y_train, X_test, y_test] = partition_data(X, y, train_size)
    total_size = size(X,1);
    train_size = int32(total_size*train_size);
    test_size = total_size - train_size;
    
    X_train = X(test_size+1:end, :);
    X_test = X(1:test_size, :);

    y_train = y(test_size+1:end, :);
    y_test = y(1:test_size, :);
end

