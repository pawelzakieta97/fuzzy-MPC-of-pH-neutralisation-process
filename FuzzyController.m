classdef FuzzyController < handle
    % klasa implementuj¹ca regulator rozmyty.
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
    end
    methods
        function obj = FuzzyController(controllers, membership_fun, numeric, fm)
            % konstruktor przyjmuje listê regulatorów oraz punkty pracy w
            % postaci stanu modelu. Funkcja membership_fun okreœla
            % podobieñstwo obecnej sytuacji i punktu pracy
            obj.controllers = controllers;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(1000,length(controllers));
            
            % regulator main_controller bêdzie u¿ywany do przybli¿ania
            % przyrostu wartoœci sterowania. powinien on byc mniej wiêcej
            % po œrodku zakresu pracy, wielkoœæ skoku powinna byæ niewielka
            obj.main_controller = controllers(1);
            params = ModelParams();
            obj.iterations = 0;
            obj.use_full_steering = 0;
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
            if current_model.k == 10
                i=1
            end
            total_weight = 0;
            D = obj.controllers(1).D;
            N = obj.controllers(1).N;
            Nu = obj.controllers(1).Nu;
%             D = 80;
%             N = D;
%             Nu = 5;
%             if strcmp(functions(obj.membership_fun).function, 'output_and_step_size')
%                 exp_step = obj.approximate_steering(current_model);
%             end
            
%             if obj.numeric
% %                 free_response = obj.get_free_response(current_model.k-1, 80) + current_model.y(current_model.k);
% %                 free_response = free_response';
%                 obj.sim_model.copy_state(current_model);
%                 
%                 for t=1:N
%                     obj.sim_model.update(obj.planned_steering(t,:));
%                 end
%                 free_response = obj.sim_model.y(current_model.k+1:current_model.k+80);
%             end
            % dz³ugoœæ wartoœci sterowania zwracana przez regulatory
            % Nu = 1;
            
            local_lambda = 0;
            local_s = obj.controllers(1).linear_model.s1*0;
            steering = 0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
%                 if strcmp(functions(obj.membership_fun).function, 'output_and_step_size')
%                     weight = obj.membership_fun(obj.controllers(i), current_model, exp_step);
%                 end
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                if obj.numeric
                    local_s = local_s + weight * obj.controllers(i).linear_model.s1;
                    local_lambda = local_lambda + weight * obj.controllers(i).lambda;
                    % steering = steering + obj.controllers(i).get_full_steering(current_model, free_response)*weight;
                    % Nu = length(steering);
%                     steering = steering + obj.controllers(i).get_steering(current_model)*weight;
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
%                     planned_u1 = obj.planned_steering(1:Nu, 1);
%                     last_u = current_model.get_up(1);
%                     planned_u1 = [last_u(1); planned_u1];
%                     planned_steps = planned_u1(2:Nu+1) - planned_u1(1:Nu);
                    % steering = local_DMC.get_full_steering(current_model, free_response, planned_steps);
                    if obj.iterations == 0
                        
                        % Wyznaczenie odpowiedzi swobodnej na podstawie
                        % modelu rozmytego
                        obj.sim_model.copy_state(current_model);
                        for t=1:N
                            obj.sim_model.update(obj.planned_steering(t,:));
                        end
                        free_response = obj.sim_model.y(current_model.k+1:current_model.k+80);
                        steering = local_DMC.get_full_steering(current_model, free_response);
                        obj.planned_steering(:,1) = steering(1)*ones(N,1);
                    else
%                     if obj.iterations == 1
%                         obj.planned_steering(1:Nu-1, 1)= steering(2:end);
%                         obj.planned_steering(Nu:N,1) = steering(Nu)*ones(N-Nu+1,1);
%                     end
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
            
%             obj.weights(current_model.k, :) = obj.weights(current_model.k, :)/total_weight;
            u = steering(1);
%             obj.planned_steering(1:Nu-1, 1)= steering(2:end);
%             if obj.iterations == 0
%             	obj.planned_steering(:,1) = u*ones(N,1);
%             end
%             obj.planned_steering(Nu:N,1) = steering(Nu)*ones(N-Nu+1,1);
%             if obj.numeric
%                 k = current_model.k;
%                 sim_len = size(obj.free_responses, 2);
%                 
%                 up = current_model.get_up(1);
%                 this_step = local_s' * (u-up(1));
%                 this_step = [this_step, this_step(length(this_step))*ones(1,sim_len)];
%                 obj.step_responses(k, :) = this_step(1:D);
%                 
%                 if k == 1
%                     obj.free_responses(1, 1:sim_len) = this_step(1:sim_len);
%                 else
%                     obj.free_responses(k, :) = ...
%                     obj.free_responses(k-1, :);
%                     obj.free_responses(k, k:sim_len) = obj.free_responses(k, k:sim_len) + this_step(1:sim_len-k+1);
%                 end
%             end
        end
        function y0 = get_free_response(obj, k, samples)
            D = 80;
            if nargin<3
                samples = D;
            end
            if k < 1
                y0 = zeros(1,samples);
            else
                y0 = obj.free_responses(k, k+1:end) - obj.free_responses(k,k);
                y0 = [y0, y0(length(y0)) * ones(1, max(1, 1+samples-length(y0)))];
                y0 = y0(2:samples+1);
            end
        end
        function obj = update_lambdas(obj, lambdas)
            for i =1:length(lambdas)
                obj.controllers(i).set_lambda(lambdas(i));
            end
        end
    end
end