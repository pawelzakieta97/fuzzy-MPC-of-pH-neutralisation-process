function [x,y,u] = step(u0, amplitude, samples, params)
if nargin<3
    samples = 100;
end
if nargin<4
    params = ModelParams();
end
model = Model(zeros(samples,1), params);
[x0,y0] = static_output(u0);
model.x(1,:)=x0;
model.y(1)=y0;


% pierwsza wartoœæ sygna³u wyjœæiowego i zmiennych stanu s¹ ustawione,
% symulacja zaczyna siê od k=2
for k=1:samples
    model.update(u0+amplitude);
end
x = model.x(1:samples, :);
y = model.y(1:samples);
u = model.u(1:samples, :);
end