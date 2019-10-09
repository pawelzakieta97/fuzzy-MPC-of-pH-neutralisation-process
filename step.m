function [x,y] = step(u0, amplitude, samples, params)
if nargin<4
    params = ModelParams();
end
model = Model([], params);
[x0,y0] = static_output(u0);
model.x(1,:)=x0;
model.y(1)=y0;


% pierwsza warto�� sygna�u wyj��iowego i zmiennych stanu s� ustawione,
% symulacja zaczyna si� od k=2
for k=2:samples
    model.update(u0+amplitude);
end
x = model.x(1:samples, :);
y = model.y(1:samples);
end