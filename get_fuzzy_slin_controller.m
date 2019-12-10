function fc = get_fuzzy_slin_controller(op_points, membership_fun)
clear controllers;
clear diffeq_models;

D = 80;
N = D;
Nu = 2;
for params_idx=1:length(op_points)
    y0 = op_points(params_idx, 1);
    step_size = op_points(params_idx, 2);
    lambda = op_points(params_idx, 3);
    % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna³u
    % steruj¹cego u1 i zak³ócenia u2
    [~, step1] = SLinear_step(y0, step_size, D+1);
    [~, step2] = SLinear_step(y0, 0.1, D+1);
    s = zeros(D+1, 2);
    s(:,1)=step1;
    s(:,2)=step2;
    step_model = StepRespModel(s, step_size, ModelParams());
    % utworzenie listy regulatorów dmc na podstawie wygenerowanych
    % odpowiedzi skokowych
    controllers(params_idx)=DMC(step_model,N,Nu,D,lambda);
    
end
fc = FuzzyController(controllers, @output_and_step_size);