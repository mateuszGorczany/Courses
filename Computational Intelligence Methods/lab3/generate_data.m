function [X, y] = generate_data(len)
%GENERATE_DATA Summary of this function goes here
    X1 = generate_randn([2,0], 1, len);
    X2 = generate_randn([-2,0], 1, len);
    X3 = generate_randn([0,2], 1, len);
    X4 = generate_randn([0,-2], 1, len);

    X = [X1;X2;X3;X4];
    
    % Y
    class_a = [0 1]';
    class_b = [1 1]';
    class_c = [1 0]';
    class_d = [0 0]';
    
    y = [
    repmat(class_a,1,length(X1))'; 
    repmat(class_b,1,length(X2))';
    repmat(class_c,1,length(X3))';
    repmat(class_d,1,length(X4))'
];
   
end

