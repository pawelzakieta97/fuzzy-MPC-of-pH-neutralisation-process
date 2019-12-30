function [error, fuzzy_function] = fuzzy_acc(reference_function, params)
op_points = params(1:length(params)/2);
sigmas = params(length(params)/2+1:end);
n_functions = length(op_points);
op_values = zeros(n_functions, 1);

x = reference_function(:,1);
y = reference_function(:,2);
samples = length(x);

fuzzy_function = zeros(samples,1);
x_min = x(1);
x_max = x(samples);
x_range = x_max-x_min;

for i=1:n_functions
    idx = int16((op_points(i)-x_min)/x_range*samples);
    idx = min(max(idx, 1), samples);
    op_values(i) = y(idx);
end

for k=1:samples
    total_weight = 0;
    current_point = x(k);
    for n=1:n_functions
        weight = gaussmf(current_point, [sigmas(n), op_points(n)]);
        total_weight = total_weight + weight;
        fuzzy_function(k) = fuzzy_function(k) + op_values(n) * weight;
    end
    fuzzy_function(k) = fuzzy_function(k)/total_weight;
end

error = norm(fuzzy_function-y);