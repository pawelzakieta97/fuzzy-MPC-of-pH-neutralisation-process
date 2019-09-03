function  [MSE, y]=eval_pid(K,Ti,Td,y0,amplitude, step_len)
% funckja testuj¹ca parametry PID w okolicy punktu pracy
params = ModelParams();
if nargin<6
    step_len=200;
end
if nargin<5
    amplitude = 0.1;
end
Yzad=[ones(step_len,1)*amplitude; -ones(step_len,1)*amplitude; zeros(step_len,1)]+y0;
model = Model(Yzad);

% wyznaczenie wartoœci sygna³u steruj¹cego dla którego osi¹gane jest
% wzmocnienie statyczne y0 oraz odpowiednich wartoœci zmiennych stanu
u0 = static_inv(y0);
[x0,~] = static_output(u0);
model.x(1,:)=x0;
model.y(1)=y0;
pid = PID(K,Ti,Td);
pid.u1_nominal = u0(1);
u=u0;
for k=1:length(Yzad)-1
    u(1) = pid.get_steering(model);
    model.update(u);
end
y=model.y(1:length(Yzad));
MSE = mean(norm(Yzad-model.y(1:length(Yzad))));