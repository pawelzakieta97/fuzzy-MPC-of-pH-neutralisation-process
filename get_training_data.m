function data = get_training_data(static_char, u1)
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

data = [y, gain_remapped];