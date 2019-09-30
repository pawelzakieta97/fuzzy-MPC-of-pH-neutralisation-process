addpath('./membership_functions/');
sim_len =2000;
Yzad = [ones(500,1)*7; ones(500,1)*3; ones(500,1)*9; ones(500,1)*7];
op_points = [3, 5, 7, 8.5,10];

D = 500;
N = D;
Nu = 3;
lambda = [0.01, 0.1, 0.1, 1, 0.1];
step_size = 0.1;
clear controllers;
clear models;
for i=1:length(op_points)
    % wyznaczenie wartoœci sygna³ów steruj¹cych, dla których uzyskane jest
    % zadane wzmocnienie op_points(i)
    u0 = static_inv(op_points(i),1);
    
    % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna³u
    % steruj¹cego u1 i zak³ócenia u2
    [~, s1] = step(u0, [step_size,0,0], D+1);
    s1 = (s1(2:D+1)-s1(1))/step_size;
    [~, s2] = step(u0, [0,step_size,0], D+1);
    s2 = (s2(2:D+1)-s2(1))/step_size;
    s = zeros(D, 2);
    s(:,1)=s1;
    s(:,2)=s2;
    
    % utworzenie listy regulatorów dmc na podstawie wygenerowanych
    % odpowiedzi skokowych
    controllers(i)=DMC(s,N,Nu,D,lambda(i));
    
    % utworzenie modeli odpowiadaj¹cych regulatorom (ustawienie aktualnej
    % wartoœci sygna³u wyjœciowego na punkt pracy)
    models(i) = Model(Yzad);
    models(i).y(1)=op_points(i);
end
params = ModelParams();
u_nominal = params.u_nominal;
u = repmat(u_nominal, [sim_len, 1]);

model = Model(Yzad);
fc = FuzzyController(controllers, models, @normal);
for k=1:sim_len-1
    % regualtor zwraca wartoœæ sygna³u steruj¹cego na podstawie obiektu
    % modelu zawieraj¹cego historiê stanu modelu (zmienne stanu, wyjœcia i
    % sterowania) oraz trajektoriê zadan¹
    u(k,1) = fc.get_steering(model);
    u(k,1) = min(max(u(k,1),params.u1_min),params.u1_max);
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


