function [x,y] = SLinear_step(y0, amplitude, samples, params)
if nargin<4
    params = ModelParams();
end
if nargin<3
    samples = 50;
end
if nargin<2
    amplitude = 1;
end
if nargin<1
    y0 = params.y_nominal;
end
model = SLinearModel([], params);
u0_nlin = static_inv(y0);
[x0,y0] = static_output(u0_nlin);
model.x(1,:)=x0;
model.y(1)=y0;


% pierwsza wartoœæ sygna³u wyjœæiowego i zmiennych stanu s¹ ustawione,
% symulacja zaczyna siê od k=2
for k=2:samples
    model.update(y0+amplitude);
end
x = model.x(1:samples, :);
y = model.y(1:samples);
end