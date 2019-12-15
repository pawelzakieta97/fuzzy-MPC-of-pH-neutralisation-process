function [x,y,u] = step(u0, amplitude, samples, params)
if nargin<3
    samples = 100;
end
if nargin<4
    params = ModelParams();
end
model = Model(zeros(samples,1), params);
[x0,y0] = static_output(u0);
model.x(1:params.output_delay+1,:)=repmat(x0',[params.output_delay+1,1]);
model.y(1:params.output_delay+1)=repmat(y0,[params.output_delay+1,1]);
model.u(1:params.output_delay+1, :) = repmat(u0,[params.output_delay+1,1]);
model.k = model.k + params.output_delay;


% pierwsza wartoœæ sygna³u wyjœæiowego i zmiennych stanu s¹ ustawione,
% symulacja zaczyna siê od k=2
for k=1:samples
    model.update(u0+amplitude);
end
x = model.x(params.output_delay+1:params.output_delay+samples, :);
y = model.y(params.output_delay+1:params.output_delay+samples);
u = model.u(params.output_delay+1:params.output_delay+samples, :);
end