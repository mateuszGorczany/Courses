function [outputArg1,outputArg2] = generate_net(inputArg1,inputArg2)
[X, y]=generate_data(class_size);
[X, y] = shuffle_data(X,y);
[X_train, y_train, X_test, y_test] = partition_data(X, y, 0.9);
net = perceptron();
net = configure(net, X_train', y_train');
end

