classdef FuzzyController < handle
    % klasa implementuj¹ca regulator rozmyty.
    properties
        controllers = [];
        membership_fun;
        weights = [];
        main_controller;
        numeric = 0;
        step_responses;
        free_responses;
        sim_model;
        planned_steering;
        iterations;
        use_full_steering;
        multi_lin;
        output_limit = [0,0];
        upper_bandwidth = 0.5;
        lower_bandwidth = 0.5;
        predict_current_state = 0;
        limit_output = 0;
        predict_lambdas = 0;
        params;
    end
    methods
        function obj = FuzzyController(controllers, membership_fun, fm, model_idx)
            % konstruktor przyjmuje listê regulatorów oraz punkty pracy w
            % postaci stanu modelu. Funkcja membership_fun okreœla
            % podobieñstwo obecnej sytuacji i punktu pracy
            if nargin<4
                model_idx = 1;
            end
            if model_idx == 1
                obj.params = ModelParams();
            else
                obj.params = Model2Params();
            end
            obj.controllers = controllers;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(1000,length(controllers));
            
            % regulator main_controller bêdzie u¿ywany do przybli¿ania
            % przyrostu wartoœci sterowania. powinien on byc mniej wiêcej
            % po œrodku zakresu pracy, wielkoœæ skoku powinna byæ niewielka
            obj.main_controller = controllers(1);
            obj.iterations = 0;
            obj.use_full_steering = 0;
            obj.multi_lin = 0;
            if nargin<3
                numeric = true;
            end
            if nargin >3
                obj.sim_model = fm;
            end
            D = 80;
            obj.step_responses = zeros(500,D);
            obj.free_responses = zeros(500,500);
            obj.planned_steering = repmat(obj.params.u_nominal,[80,1]);
        end
        function x=reset(obj)
            D = 80;
            obj.free_responses = zeros(500,500);
            obj.step_responses = zeros(500,D);
            obj.planned_steering = repmat(obj.params.u_nominal,[80,1]);
        end
        function exp_step = approximate_steering(obj, model)
            exp_step = obj.main_controller.get_steering(model) - model.get_up(1);
        end
        function u = get_steering_sl(obj, current_model)
            total_weight = 0;
            D = obj.controllers(1).D;
            N = obj.controllers(1).N;
            Nu = obj.controllers(1).Nu;
            
            local_lambda = 0;
            local_s = obj.controllers(1).linear_model.s1*0;
            steering = 0;
            
            predicted_model = obj.sim_model;
            predicted_model.copy_state(current_model);
            if obj.predict_current_state
                for t=1:current_model.params.output_delay
                    predicted_model.update(obj.planned_steering(t,:));
                end
            end
            if obj.numeric
                local_s = obj.get_local_s(predicted_model);
            end
            % obliczanie lokalnej wartosci lambda
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), predicted_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                local_lambda = local_lambda + weight * obj.controllers(i).lambda;
            end
            local_lambda = local_lambda/total_weight;
            local_step_model = StepRespModel([0; local_s]+current_model.y(current_model.k), 1, ModelParams());
            local_DMC = DMC(local_step_model,N,Nu,D,local_lambda);
            if obj.use_full_steering
                if obj.iterations == 0
                    obj.sim_model.copy_state(current_model);
                    for t=1:N
                        obj.sim_model.update(obj.planned_steering(t,:));
                    end
                    free_response = obj.sim_model.y(current_model.k+1:current_model.k+80);
                    steering = local_DMC.get_steering(current_model, free_response);
                    obj.planned_steering(:,1) = steering(1)*ones(N,1);
                else
                    for iteration = 1:obj.iterations
                        if current_model.k == 170
                            a=1;
                        end
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
                        obj.planned_steering = min(max(obj.planned_steering, obj.params.u_min(1)),obj.params.u_max(1));
                        
                        if isnan(obj.planned_steering(1))
                            a=1;
                        end
%                         obj.planned_steering(1:Nu, 1)= max(min(steering(1:Nu), obj.params.u_max(1)), obj.params.u_min(1));
%                         obj.planned_steering(Nu+1:N,1) = max(min(steering(Nu)*ones(N-Nu,1), obj.params.u_max(1)), obj.params.u_min(1));
                    end
                end
                if obj.iterations > 0
                    obj.planned_steering(1:Nu-1, 1)= steering(2:end);
                    obj.planned_steering(Nu:N,1) = steering(Nu)*ones(N-Nu+1,1);
                    obj.planned_steering = min(max(obj.planned_steering, obj.params.u_min(1)),obj.params.u_max(1));
                end
            else
                steering = local_DMC.get_steering(current_model);
            end
            u = steering(1);
        end
        
        function u = get_steering_ml(obj, current_model)
            total_weight = 0;
            D = obj.controllers(1).D;
            N = obj.controllers(1).N;
            Nu = obj.controllers(1).Nu;
            
            local_lambda = 0;
            steering = 0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                local_lambda = local_lambda + weight * obj.controllers(i).lambda;
            end
            local_lambda = local_lambda/total_weight;
            
            if obj.use_full_steering
                if obj.iterations == 0
                    obj.sim_model.copy_state(current_model);
                    for t=1:N
                        obj.sim_model.update(obj.planned_steering(t,:));
                        local_s = obj.get_local_s(obj.sim_model);
                        local_step_models(t) = StepRespModel([0;local_s]+current_model.y(current_model.k), 1, ModelParams());
                    end
                    dmc_ml = DMC_ML(local_step_models,N,Nu,D,local_lambda);
                    free_response = obj.sim_model.y(current_model.k+1:current_model.k+80);
                    steering = dmc_ml.get_full_steering(current_model, free_response);
                    obj.planned_steering(:,1) = steering(1)*ones(N,1);
                else
                    for iteration = 1:obj.iterations
                        obj.sim_model.copy_state(current_model);
                        % local_step_models = [];
                        for t=1:N
                            obj.sim_model.update(obj.planned_steering(t,:));
                            local_s = obj.get_local_s(obj.sim_model);
                            local_step_models(t) = StepRespModel(local_s+current_model.y(current_model.k), 1, ModelParams());
                            if obj.predict_lambdas && t<=Nu
                                local_lambda(t,t)=obj.get_local_lambda(obj.sim_model);
                            end
                        end
                        dmc_ml = DMC_ML(local_step_models,N,Nu,D,local_lambda);
                        free_response = obj.sim_model.y(current_model.k+1:current_model.k+80);
                        planned_u1 = obj.planned_steering(1:Nu, 1);
                        last_u = current_model.get_up(1);
                        planned_u1 = [last_u(1); planned_u1];
                        planned_steps = planned_u1(2:Nu+1) - planned_u1(1:Nu);
                        steering = dmc_ml.get_full_steering(current_model, free_response, planned_steps);
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
            u = steering(1);
            
        end
        
        function u = get_steering(obj, current_model)
            if obj.numeric 
                if obj.multi_lin
                    u = obj.get_steering_ml(current_model);
                else
                    u = obj.get_steering_sl(current_model);
                end
            else
                u = obj.get_steering_a(current_model);
            end
            if obj.limit_output
                obj.sim_model.copy_state(current_model);
                for t=1:current_model.params.output_delay+1
                    obj.sim_model.update(current_model.get_up(1));
                end
                u = obj.limit_steering(u, obj.sim_model);
            end
        end
        
        function u = get_steering_a(obj, current_model)
            total_weight = 0;
            steering = 0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                steering = steering + obj.controllers(i).get_steering(current_model)*weight;
            end
            steering = steering/total_weight;
            u = steering(1);
        end
        function local_s = get_local_s(obj, current_model)
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
            local_s = local_s/total_weight;
        end
        function local_lambda = get_local_lambda(obj, current_model)
            total_weight = 0;
            local_lambda = 0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                if obj.numeric
                    local_lambda = local_lambda + weight * obj.controllers(i).lambda;
                end
            end
            local_lambda = local_lambda/total_weight;
        end
        function u_limited = limit_steering(obj, u, predicted_model)
            lower_limit = obj.output_limit(1);
            upper_limit = obj.output_limit(2);
            lower_limit_dist = predicted_model.y(predicted_model.k)-lower_limit;
            upper_limit_dist = upper_limit - predicted_model.y(predicted_model.k);
            if lower_limit_dist<obj.lower_bandwidth || upper_limit_dist>obj.upper_bandwidth
                max_steering = static_inv(upper_limit);
                max_steering = max_steering(1);
                min_steering = static_inv(lower_limit);
                min_steering = min_steering(1);
                u_limited = min(max(u, min_steering), max_steering);
            else
                u_limited = u;
            end
        end
        function obj = update_lambdas(obj, lambdas)
            for i =1:length(lambdas)
                obj.controllers(i).set_lambda(lambdas(i));
            end
        end
        function obj = set_sigmas(obj, sigmas)
            for i=1:length(obj.controllers)
                obj.controllers(i).linear_model.sigma = sigmas(i);
            end
        end
    end
end