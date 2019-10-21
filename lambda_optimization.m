addpath('./membership_functions/');
op_points = [3, 5, 7, 8.5,10];

D = 50;
N = D;
Nu = 2;
lambda_init = [0.01, 0.1, 0.1, 1, 0.1];
step_size = 0.1;
clear controllers;
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
    controllers(i)=DMC(s,N,Nu,D,lambda_init(i), op_points(i), step_size);
end
params = ModelParams();

fc = FuzzyController(controllers, @normal);

% [lambdas_optimized, error] = fmincon(...
% @(lambdas)evaluate_controller(lambdas, fc, false), lambda_init,...
% -eye(length(lambda_init)), zeros(length(lambda_init),1));

[lambdas_optimized, error] = ga(...
@(lambdas)evaluate_controller(lambdas, fc, false, 1, 0), 5,...
-eye(length(lambda_init)), zeros(length(lambda_init),1));
