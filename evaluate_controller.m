function cost = evaluate_controller(lambdas, fuzzy_controller, normalize_cost, steering_cost, overshoot_cost)
sim_len = 300;
params = ModelParams();
Ysp = random_signal(sim_len,40,[params.y_min, params.y_max], 1);
step_size = 1;
error_multiplier = ones(sim_len, 1);
% modyfikacja warto�ci funkcji kosztu zale�nie od wielko�ci poprzedniego
% skoku (im wi�kszy skok tym mniej istotny przy obliczaniu b��du)
if normalize_cost
    for k=2:sim_len
        error_multiplier(k) = 1/step_size;
        if abs(Ysp(k) - Ysp(k-1))>0.1
            step_size = abs(Ysp(k) - Ysp(k-1));
        end
    end
end
for i=1:length(fuzzy_controller.controllers)
    fuzzy_controller.controllers(i).set_lambda(lambdas(i));
end
model = simulation(fuzzy_controller, Ysp);
overshoot = get_overshoot(Ysp, model.y);

cost = 0;
u_prev = model.params.u1_nominal;
for k=2:length(model.y)
    error = abs(model.y(k)-model.Ysp(k));
    steering_change = abs(model.u(k,1)-u_prev);
    u_prev = model.u(k,1);
    cost = cost + ...
        (error^2 + ...
        steering_change^2*steering_cost + ...
        overshoot_cost*overshoot(k)^2) * error_multiplier(k)^2;
end
end




