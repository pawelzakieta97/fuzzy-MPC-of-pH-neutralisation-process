% funkcja zwracaj�ca charakterystyk� czasu odpowiedzi obiektu na skokow�
% zmian� sygnau steruj�cego (czas, po kt�rym odleg�o�� od wzmocnienia
% statycznego maleje e-krotnie)

function [u, time] = resp_time_char(samples, step_size, params)
if nargin<1
    samples = 100;
end
if nargin<2
    step_size = 0.1;
end
if nargin<3
    params = ModelParams();
end
u = repmat(params.u_nominal, [samples, 1]);
u(:,1) = [1:samples]/samples*(params.u1_max-params.u1_min)+params.u1_min;
time = zeros(samples,1);
for i=1:samples
    time(i)=response_time(u(i,:), 0.1, 0.95, params);
end
