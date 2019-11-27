function model = SLinear_simulation(controller, Ysp, params)
if nargin<3
    params = ModelParams();
end
model = SLinearModel(Ysp, params);
sim_len = length(model.Ysp);
u_nominal = model.params.u_nominal;
u = params.y_nominal*ones(length(Ysp),1);
for k=1:sim_len-1
    % regualtor zwraca warto�� sygna�u steruj�cego na podstawie obiektu
    % modelu zawieraj�cego histori� stanu obiektu (zmienne stanu, wyj�cia i
    % sterowania) oraz trajektori� zadan�
    u(k) = controller.get_steering(model);
    % u(k) = min(max(u(k,1),model.params.u1_min),model.params.u1_max);
    model.update(u(k,:));
end