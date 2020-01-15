function [fc, fm] = get_fuzzy_controller(op_points, lambdas, step_sizes, membership_fun, Nu, model_idx)
clear controllers;
clear diffeq_models;
if model_idx == 1
    D = 80;
else
    D = 100;
end
N = D;

if length(step_sizes) == 1
    step_size = step_sizes(1);
    for op_point_idx=1:length(op_points)
        % wyznaczenie wartoœci sygna³ów steruj¹cych, dla których uzyskane jest
        % zadane wzmocnienie op_points(i)
        if model_idx == 1
            u0 = static_inv(op_points(op_point_idx),1);
            [~, step1, u1] = step(u0, [step_size,0,0], D+1, model_idx);
            [~, step2, ~] = step(u0, [0,step_size,0], D+1, model_idx);
            s = zeros(D+1, 2);
            s(:,1)=step1;
            s(:,2)=step2;
            diff_eq_model = get_local_DEM(op_points(op_point_idx), 1, 1);
            step_model = StepRespModel(s, step_size, u0, ModelParams());
            diff_eq_model.s1 = step_model.s1;
            params = ModelParams();
        else
            u0 = static_inv2(op_points(op_point_idx));
            [~, step1, u1] = step(u0, step_size, D+1, model_idx);
            s = zeros(D+1, 1);
            s(:,1)=step1;
            diff_eq_model = get_local_DEM(op_points(op_point_idx), 1, 2);
            
            step_model = StepRespModel(s, step_size, u0, Model2Params());
            diff_eq_model.s1 = step_model.s1;
            params = Model2Params();
        end
        % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna³u
        % steruj¹cego u1 i zak³ócenia u2
        

        % utworzenie listy regulatorów dmc na podstawie wygenerowanych
        % odpowiedzi skokowych
        
        controllers(op_point_idx)=DMC(step_model,N,Nu,D,lambdas(op_point_idx));
        diffeq_models(op_point_idx) = diff_eq_model;
        %diffeq_models(op_point_idx) = step_model;
    end
    fm = FuzzyModel(diffeq_models, membership_fun, model_idx);
    fm.params = params;
    fc = FuzzyController(controllers, membership_fun, fm, model_idx);
    
else
    for step_idx=1:len(step_sizes)
        step_size = step_sizes(step_idx);
        for op_point_idx=1:length(op_points)
            % wyznaczenie wartoœci sygna³ów steruj¹cych, dla których uzyskane jest
            % zadane wzmocnienie op_points(i)
            u0 = static_inv(op_points(op_point_idx),1);

            % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna³u
            % steruj¹cego u1 i zak³ócenia u2
            [~, step1] = step(u0, [step_size,0,0], D+1);
            step1 = (step1(2:D+1)-step1(1))/step_size;
            [~, step2] = step(u0, [0,0.1,0], D+1);
            step2 = (step2(2:D+1)-step2(1))/step_size;
            s = zeros(D, 2);
            s(:,1)=step1;
            s(:,2)=step2;

            % utworzenie listy regulatorów dmc na podstawie wygenerowanych
            % odpowiedzi skokowych
            controllers(op_point_idx)=DMC(s,N,Nu,D,lambdas(op_point_idx, step_idx), op_points(op_point_idx), step_size);
        end
        fc = FuzzyController(controllers, membership_fun);
    end
end
if length(lambdas)==1
    fc = controllers(1);
end