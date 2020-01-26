sigmas = [1,1,1];
op_points = [0,3,6];
samples = 100;
range = [0,6];
x = [1:samples]*(range(2)-range(1))/samples + range(1);
w1 = zeros(samples,1);
w2 = zeros(samples,1);
w3 = zeros(samples,1);

w1_norm = zeros(samples,1);
w2_norm = zeros(samples,1);
w3_norm = zeros(samples,1);

y = zeros(samples,1);
y1 = zeros(samples,1);
y2 = zeros(samples,1);
y3 = zeros(samples,1);

a = [1, -1, 2];
b = [0,3,-10.5];
for i=1:samples
    w1(i) = gaussmf(x(i), [sigmas(1), op_points(1)]);
    w2(i) = gaussmf(x(i), [sigmas(2), op_points(2)]);
    w3(i) = gaussmf(x(i), [sigmas(3), op_points(3)]);
    s = w1(i) + w2(i) + w3(i);
    w1_norm(i) = w1(i)/s;
    w2_norm(i) = w2(i)/s;
    w3_norm(i) = w3(i)/s;
    y1(i) = (a(1) * x(i) + b(1));%*w1_norm(i);
    y2(i) = (a(2) * x(i) + b(2));%*w2_norm(i);
    y3(i) = (a(3) * x(i) + b(3));%*w3_norm(i);
    
    y(i) = y1(i)*w1_norm(i) + y2(i)*w2_norm(i) + y3(i)*w3_norm(i);
end
plot(y);
hold on;
plot(y1);
plot(y2);
plot(y3);
col_names = {'x', 'w1', 'w2', 'w3'};
plot(w1);
hold on
plot(w1_norm);
csvwrite_with_headers('../wykresy/fuzzy/mf.csv', [x', w1, w2, w3], col_names);
csvwrite_with_headers('../wykresy/fuzzy/mf_norm.csv', [x', w1_norm, w2_norm, w3_norm], col_names);
csvwrite_with_headers('../wykresy/fuzzy/mf_out.csv', [x', y, y1, y2, y3], {'x','y','y1','y2','y3'});