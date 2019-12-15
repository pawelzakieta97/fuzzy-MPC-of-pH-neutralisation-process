function [fc, fm] = get_fuzzy_controller(op_points, lambdas, step_sizes, membership_fun, numeric)
clear controllers;
clear diffeq_models;

D = 80;
N = D;
Nu = 5;

if nargin < 5
    numeric = true;
end
if length(step_sizes) == 1
    step_size = step_sizes(1);
    for op_point_idx=1:length(op_points)
        % wyznaczenie warto�ci sygna��w steruj�cych, dla kt�rych uzyskane jest
        % zadane wzmocnienie op_points(i)
        u0 = static_inv(op_points(op_point_idx),1);

        % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna�u
        % steruj�cego u1 i zak��cenia u2
        [~, step1, u1] = step(u0, [step_size,0,0], D+1);
        [~, step2, ~] = step(u0, [0,step_size,0], D+1);
        s = zeros(D+1, 2);
        s(:,1)=step1;
        s(:,2)=step2;

        % utworzenie listy regulator�w dmc na podstawie wygenerowanych
        % odpowiedzi skokowych
        diff_eq_model = get_local_DEM(op_points(op_point_idx), 1);
        step_model = StepRespModel(s, step_size, ModelParams());
        controllers(op_point_idx)=DMC(step_model,N,Nu,D,lambdas(op_point_idx));
        diffeq_models(op_point_idx) = diff_eq_model;
    end
    fm = FuzzyModel(diffeq_models, membership_fun);
    fc = FuzzyController(controllers, membership_fun, numeric, fm);
    
else
    for step_idx=1:len(step_sizes)
        step_size = step_sizes(step_idx);
        for op_point_idx=1:length(op_points)
            % wyznaczenie warto�ci sygna��w steruj�cych, dla kt�rych uzyskane jest
            % zadane wzmocnienie op_points(i)
            u0 = static_inv(op_points(op_point_idx),1);

            % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna�u
            % steruj�cego u1 i zak��cenia u2
            [~, step1] = step(u0, [step_size,0,0], D+1);
            step1 = (step1(2:D+1)-step1(1))/step_size;
            [~, step2] = step(u0, [0,0.1,0], D+1);
            step2 = (step2(2:D+1)-step2(1))/step_size;
            s = zeros(D, 2);
            s(:,1)=step1;
            s(:,2)=step2;

            % utworzenie listy regulator�w dmc na podstawie wygenerowanych
            % odpowiedzi skokowych
            controllers(op_point_idx)=DMC(s,N,Nu,D,lambdas(op_point_idx, step_idx), op_points(op_point_idx), step_size);
        end
        fc = FuzzyController(controllers, membership_fun);
    end
end
if length(lambdas)==1
    fc = controllers(1);
end