function [x,y] = step(u0, amplitude, len)
model = Model();
[x0,y0] = static_output(u0);
model.x(1,:)=x0;
model.y(1)=y0;

% pierwsza warto�� sygna�u wyj��iowego i zmiennych stanu s� ustawione,
% symulacja zaczyna si� od k=2
for k=2:len
    model.update(u0+amplitude);
end
x = model.x;
y = model.y;
end