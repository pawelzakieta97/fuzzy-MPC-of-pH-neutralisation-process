function cost = evaluate_controller(lambdas, fuzzy_controller, randomization_amp, normalize_cost, show_plots)
sim_len = 200;
Ysp = [ones(50,1)*7; ones(50,1)*3; ones(50,1)*9; ones(50,1)*7];
step_size = 1;
error_multiplier = ones(sim_len, 1);
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

params = ModelParams();
u_nominal = params.u_nominal;
u = repmat(u_nominal, [sim_len, 1]);
model = Model(Ysp);
model.params.randomize(randomization_amp);
steering_cost = 0.0;
prev_u = params.u1_nominal;

cost = 0;
for k=1:sim_len-1
    % regualtor zwraca wartoœæ sygna³u steruj¹cego na podstawie obiektu
    % modelu zawieraj¹cego historiê stanu obiektu (zmienne stanu, wyjœcia i
    % sterowania) oraz trajektoriê zadan¹
    u(k,1) = fuzzy_controller.get_steering(model);
    u(k,1) = min(max(u(k,1),params.u1_min),params.u1_max);
    cost = cost + (error_multiplier(k)*(model.y(model.k)-Ysp(k)))^2 + steering_cost*(u(k,1)-prev_u)^2;
    prev_u = u(k,1);
    model.update(u(k,:));
end
if nargin>2 && show_plots
    figure
    subplot(2,1,1);
    stairs(Ysp, '--');
    hold on;
    plot(model.y(1:sim_len));
    legend('setpoint', 'output', 'Location','southeast');
    hold off;

    subplot(2,1,2); 
    plot(model.u(:,1));
    legend('u1');

%     subplot(3,1,3); 
%     hold on;
%     for i=1:length(fuzzy_controller.weights(1,:))
%         legend_text = ['member y_0 = ', num2str(fuzzy_controller.controllers(i).op_point)];
%         plot(fuzzy_controller.weights(:,i), 'DisplayName', legend_text);
%     end
%     legend('Location','west');
    legend show;
end
end




