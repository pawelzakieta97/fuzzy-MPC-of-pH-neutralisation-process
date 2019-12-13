classdef FuzzyController < handle
    % klasa implementuj�ca regulator rozmyty.
    properties
        controllers = [];
        membership_fun;
        weights = [];
        main_controller;
        numeric;
        step_responses;
        free_responses;
        sim_model;
        planned_steering;
        iterations;
        use_full_steering;
        multi_lin;
    end
    methods
        function obj = FuzzyController(controllers, membership_fun, numeric, fm)
            % konstruktor przyjmuje list� regulator�w oraz punkty pracy w
            % postaci stanu modelu. Funkcja membership_fun okre�la
            % podobie�stwo obecnej sytuacji i punktu pracy
            obj.controllers = controllers;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(1000,length(controllers));
            
            % regulator main_controller b�dzie u�ywany do przybli�ania
            % przyrostu warto�ci sterowania. powinien on byc mniej wi�cej
            % po �rodku zakresu pracy, wielko�� skoku powinna by� niewielka
            obj.main_controller = controllers(1);
            params = ModelParams();
            obj.iterations = 0;
            obj.use_full_steering = 0;
            obj.multi_lin = 0;
            if nargin<3
                numeric = true;
            end
            if nargin >3
                obj.sim_model = fm;
            end
            obj.numeric = numeric;
            D = 80;
            obj.step_responses = zeros(500,D);
            obj.free_responses = zeros(500,500);
            obj.planned_steering = repmat(params.u_nominal,[80,1]);
        end
        function x=reset(obj)
            D = 80;
            obj.free_responses = zeros(500,500);
            obj.step_responses = zeros(500,D);
            params = ModelParams();
            obj.planned_steering = repmat(params.u_nominal,[80,1]);
        end
        function exp_step = approximate_steering(obj, model)
            exp_step = obj.main_controller.get_steering(model) - model.get_up(1);
        end
        function u = get_steering(obj, current_model)
            if current_model.k == 20
                i=1
            end
            total_weight = 0;
            D = obj.controllers(1).D;
            N = obj.controllers(1).N;
            Nu = obj.controllers(1).Nu;
            
            local_lambda = 0;
            local_s = obj.controllers(1).linear_model.s1*0;
            steering = 0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                if obj.numeric
                    local_s = local_s + weight * obj.controllers(i).linear_model.s1;
                    local_lambda = local_lambda + weight * obj.controllers(i).lambda;
                else
                    steering = steering + obj.controllers(i).get_steering(current_model)*weight;
                    Nu = 1;
                end
            end
            steering = steering/total_weight;
            if obj.numeric
                
                local_s = local_s/total_weight;
                local_lambda = local_lambda/total_weight;
                local_step_model = StepRespModel(local_s+current_model.y(current_model.k), 1, ModelParams());
                local_DMC = DMC(local_step_model,N,Nu,D,local_lambda);
                if obj.use_full_steering
                    if obj.iterations == 0
                        obj.sim_model.copy_state(current_model);
                        for t=1:N
                            obj.sim_model.update(obj.planned_steering(t,:));
                        end
                        free_response = obj.sim_model.y(current_model.k+1:current_model.k+80);
                        steering = local_DMC.get_full_steering(current_model, free_response);
                        obj.planned_steering(:,1) = steering(1)*ones(N,1);
                    else
                        for iteration = 1:obj.iterations
                            obj.sim_model.copy_state(current_model);
                            for t=1:N
                                obj.sim_model.update(obj.planned_steering(t,:));
                            end
                            free_response = obj.sim_model.y(current_model.k+1:current_model.k+80);
                            planned_u1 = obj.planned_steering(1:Nu, 1);
                            last_u = current_model.get_up(1);
                            planned_u1 = [last_u(1); planned_u1];
                            planned_steps = planned_u1(2:Nu+1) - planned_u1(1:Nu);
                            steering = local_DMC.get_full_steering(current_model, free_response, planned_steps);
                            obj.planned_steering(1:Nu, 1)= steering(1:Nu);
                            obj.planned_steering(Nu+1:N,1) = steering(Nu)*ones(N-Nu,1);
                        end
                    end
                    if obj.iterations > 0
                        obj.planned_steering(1:Nu-1, 1)= steering(2:end);
                        obj.planned_steering(Nu:N,1) = steering(Nu)*ones(N-Nu+1,1);
                    end
                else
                    steering = local_DMC.get_steering(current_model);
                end
            end
            u = steering(1);
        end
        function s = get_local_s(obj, current_model)
            total_weight = 0;
            local_s = obj.controllers(1).linear_model.s1*0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                if obj.numeric
                    local_s = local_s + weight * obj.controllers(i).linear_model.s1;
                end
            end
        end
        function Mml = get_Mml(obj, ss)
            D = size(ss,2);
            N = size(ss,1);
            Nu = obj.controllers(1).Nu;
            K = ss(:,D-1);
            ss = [ss, repmat(K, [1, N-D])];
            Mml = zeros(N, Nu);
            for row = 1:N
                Mml(row, 1:min(row,Nu)) = ss(row, row:-1:max(1,row-Nu+1));
            end
        end
        function obj = update_lambdas(obj, lambdas)
            for i =1:length(lambdas)
                obj.controllers(i).set_lambda(lambdas(i));
            end
        end
    end
end