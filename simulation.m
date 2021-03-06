function model = simulation(controller, Ysp, model_idx, dist, params)
if nargin<5
    if model_idx == 1
        params = ModelParams();
    else
        params = Model2Params();
    end
end

if model_idx == 1
    model = Model(Ysp, params);
else
    model = Model2(Ysp, params);
end
sim_len = length(model.Ysp);
if nargin<4
    u_nominal = model.params.u_nominal;
    u = repmat(u_nominal, [sim_len, 1]);
else
    u = dist;
end
model.u(1:length(u), :) = u;

% u_nominal = model.params.u_nominal;
% u = repmat(u_nominal, [sim_len, 1]);
for k=1:sim_len-1
    % regualtor zwraca warto�� sygna�u steruj�cego na podstawie obiektu
    % modelu zawieraj�cego histori� stanu obiektu (zmienne stanu, wyj�cia i
    % sterowania) oraz trajektori� zadan�
    if k==300
        a=1;
    end
    u(k,1) = controller.get_steering(model);
    u(k,1) = min(max(u(k,1),model.params.u_min(1)),model.params.u_max(1));
    model.update(u(k,:));
end