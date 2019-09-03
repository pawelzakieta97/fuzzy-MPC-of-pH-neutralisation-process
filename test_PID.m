addpath('./membership_functions/');
sim_len =2000;
Yzad = [ones(500,1)*7; ones(500,1)*3; ones(500,1)*9; ones(500,1)*7];
op_points = [5, 6.5, 8.5, 10];
K=[20, 20, 5, 50];
Ti=[5, 5, 7, 1];
Td=[7, 7, 1, 1];
% lambda = [100];
step_size = 0.1;
clear controllers;
clear models;
for i=1:length(op_points)
    controllers(i)=PID(K(i), Ti(i), Td(i));
    u0 = static_inv(op_points(i),1);
    controllers(i).u1_nominal = u0(1);
    % utworzenie modeli odpowiadaj¹cych regulatorom (ustawienie aktualnej
    % wartoœci sygna³u wyjœciowego na punkt pracy)
    models(i) = Model(Yzad);
    models(i).y(1)=op_points(i);
end
u = repmat(u_nominal, [sim_len, 1]);

model = Model(Yzad);
fc = FuzzyController(controllers, models, @normal);
for k=1:sim_len-1
    % regualtor zwraca wartoœæ sygna³u steruj¹cego na podstawie obiektu
    % modelu zawieraj¹cego historiê stanu modelu (zmienne stanu, wyjœcia i
    % sterowania) oraz trajektoriê zadan¹
    u(k,1) = fc.get_steering(model);
    u(k,1) = min(max(u(k,1),u1_min),u1_max);
    model.update(u(k,:));
end
figure
subplot(3,1,1);
stairs(Yzad, '--');
hold on;
plot(model.y(1:sim_len));
legend('setpoint', 'output', 'Location','southeast');
hold off;

subplot(3,1,2); 
plot(model.u(:,1));
legend('u1');

subplot(3,1,3); 
hold on;
legends = zeros(length(fc.weights(1,:)), 30);
for i=1:length(fc.weights(1,:))
    legend_text = ['member y_0 = ', num2str(fc.op_models(i).y(1))];
    plot(fc.weights(:,i), 'DisplayName', legend_text);
end
legend('Location','southeastoutside');
legend show;


