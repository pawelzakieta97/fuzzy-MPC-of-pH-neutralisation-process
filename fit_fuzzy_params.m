function [op_points, sigmas] = fit_fuzzy_params(static_char, u1, n_functions)
% funkcja dopasowuj¹ca parametry funkcji przynale¿noœci do charakterystyki
% statycznej

% zamiana funckji y(u) na y'(y)
gain = (static_char(2:end)-static_char(1:end-1))./(u1(2:end)-u1(1:end-1));
samples = length(gain);
y_min = static_char(1);
y_max = static_char(samples);
y = zeros(samples,1);
gain_remapped = zeros(samples,1);
for i=1:samples
    y(i) = y_min + (y_max-y_min)*i/samples;
    [~, idx] = min(abs(static_char-y(i)));
    gain_remapped(i) = gain(idx);
end

model_params = ModelParams();
y_min = model_params.y_min;
y_max = model_params.y_max;
op_points = sort(rand(n_functions, 1));
op_points = op_points*(y_max-y_min)+y_min;
sigmas = ones(n_functions, 1);

[params_optimized, error] = fmincon(...
@(params)fuzzy_acc([y, gain_remapped], params), [op_points; sigmas],...
-eye(2*n_functions), zeros(2*n_functions,1));

op_points = params_optimized(1:n_functions);
sigmas = params_optimized(n_functions+1:end);