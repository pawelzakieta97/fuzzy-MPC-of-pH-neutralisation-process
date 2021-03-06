classdef FuzzyController < handle
    % klasa implementuj�ca regulator rozmyty.
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
        limit_type = 1;
        lim_samples = 1;
        static_inv;
        lim_use_sim_model = 0;
        linearize_sim_model = 0;
        prev_prediction=0;
        d = 0;
        main_model;
        include_disturbance = 1;
        disturbance_model;
        dmc_disturbance = 0;
    end
    methods
        function obj = FuzzyController(controllers, membership_fun, fm, model_idx)
            % konstruktor przyjmuje list� regulator�w oraz punkty pracy w
            % postaci stanu modelu. Funkcja membership_fun okre�la
            % podobie�stwo obecnej sytuacji i punktu pracy
            if nargin<4
                model_idx = 1;
            end
            if model_idx == 1
                obj.params = ModelParams();
                obj.static_inv = @static_inv;
            else
                obj.params = Model2Params();
                obj.static_inv = @static_inv2;
            end
            obj.controllers = controllers;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(1000,length(controllers));
            
            % regulator main_controller b�dzie u�ywany do przybli�ania
            % przyrostu warto�ci sterowania. powinien on byc mniej wi�cej
            % po �rodku zakresu pracy, wielko�� skoku powinna by� niewielka
            obj.main_controller = controllers(1);
            obj.iterations = 0;
            obj.use_full_steering = 0;
            obj.multi_lin = 0;
            if nargin<3
                numeric = true;
            end
            if nargin >3
                obj.sim_model = fm;
                obj.main_model = fm.clone();
            end
            D = 80;
            obj.step_responses = zeros(500,D);
            obj.free_responses = zeros(500,500);
            obj.planned_steering = repmat(obj.params.u_nominal,[100,1]);
        end
        function x=reset(obj)
            obj.prev_prediction = 0;
            obj.sim_model.reset();
            obj.main_model.reset();
            D = 80;
            obj.free_responses = zeros(500,500);
            obj.step_responses = zeros(500,D);
            obj.planned_steering = repmat(obj.params.u_nominal,[100,1]);
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
            local_step_model = StepRespModel([0; local_s]+current_model.y(current_model.k), 1, obj.params.u_nominal, ModelParams());
            local_DMC = DMC(local_step_model,N,Nu,D,local_lambda);
            % oszacowanie bledu modelowania
            if obj.prev_prediction ~= 0
                obj.d = current_model.y(current_model.k)-obj.prev_prediction;
            end
            d = current_model.y(current_model.k)-obj.main_model.y(current_model.k);
            if obj.use_full_steering
                if obj.iterations == 0
                    obj.sim_model.copy_state(current_model);
                    if current_model.k == 60
                        a=1;
                    end
                    for t=1:N
                        obj.sim_model.update(obj.planned_steering(t,:));
                    end
                    %free_response = obj.sim_model.y(current_model.k+1:current_model.k+D);
                    free_response = obj.get_free_response(N)+d;
                    % correction = [1:length(free_response)]*d;
                    steering = local_DMC.get_steering(current_model, free_response);
                    obj.planned_steering(1:N,1) = steering(1)*ones(N,1);
                    obj.planned_steering = min(max(obj.planned_steering, obj.params.u_min(1)),obj.params.u_max(1));
                else
                    for iteration = 1:obj.iterations
                        
                        obj.sim_model.copy_state(current_model);
                        obj.main_model.set_k(current_model.k);
                        for t=1:N
                            %obj.sim_model.update(obj.planned_steering(t,:));
                            obj.main_model.update(obj.planned_steering(t,:));
                        end
                        %free_response = obj.sim_model.y(current_model.k+1:current_model.k+D);
                        free_response = obj.main_model.y(current_model.k+1:current_model.k+D)+d;
                        planned_u1 = obj.planned_steering(1:Nu, 1);
                        last_u = current_model.get_up(1);
                        planned_u1 = [last_u(1); planned_u1];
                        planned_steps = planned_u1(2:Nu+1) - planned_u1(1:Nu);
                        steering = local_DMC.get_full_steering(current_model, free_response+obj.d, planned_steps);
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
                obj.prev_prediction = free_response(1);
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
            d = current_model.y(current_model.k)-obj.main_model.y(obj.main_model.k);
            if obj.use_full_steering
                if obj.iterations == 0
                    obj.sim_model.copy_state(current_model);
                    obj.main_model.set_k(current_model.k);
                    
                    for t=1:N
                        obj.sim_model.update(obj.planned_steering(t,:));
                        %obj.main_model.update(obj.planned_steering(t,:));
                        local_s = obj.get_local_s(obj.sim_model);
                        %local_s = obj.get_local_s(obj.main_model);
                        local_step_models(t) = StepRespModel([0;local_s]+current_model.y(current_model.k), 1, ModelParams());
                    end
                    dmc_ml = DMC_ML(local_step_models,N,Nu,D,local_lambda);
                    free_response = obj.sim_model.y(current_model.k+1:current_model.k+N);
                    steering = dmc_ml.get_full_steering(current_model, free_response);
                    obj.planned_steering(:,1) = steering(1)*ones(N,1);
                else
                    for iteration = 1:obj.iterations
                        obj.sim_model.copy_state(current_model);
                        % local_step_models = [];
                        obj.main_model.set_k(current_model.k);
                        for t=1:N
                            % obj.sim_model.update(obj.planned_steering(t,:));
                            obj.main_model.update(obj.planned_steering(t,:));
                            obj.main_model.y(obj.main_model.k) = obj.main_model.y(obj.main_model.k) + d;
                            %local_s = obj.get_local_s(obj.sim_model);
                            local_s = obj.get_local_s(obj.main_model);
                            obj.main_model.y(obj.main_model.k) = obj.main_model.y(obj.main_model.k) - d;
                            local_step_models(t) = StepRespModel(local_s+current_model.y(current_model.k), 1, obj.params.u_nominal, ModelParams());
                            if obj.predict_lambdas && t<=Nu
                                local_lambda(t,t)=obj.get_local_lambda(obj.sim_model);
                            end
                        end
                        dmc_ml = DMC_ML(local_step_models,N,Nu,D,local_lambda);
                        %free_response = obj.sim_model.y(current_model.k+1:current_model.k+N);
                        free_response = obj.main_model.y(current_model.k+1:current_model.k+N)+d;
                        planned_u1 = obj.planned_steering(1:Nu, 1);
                        last_u = current_model.get_up(1);
                        planned_u1 = [last_u(1); planned_u1];
                        planned_steps = planned_u1(2:Nu+1) - planned_u1(1:Nu);
                        steering = dmc_ml.get_full_steering(current_model, free_response, planned_steps);
                        obj.planned_steering(1:Nu, 1)= steering(1:Nu);
                        obj.planned_steering(Nu+1:N,1) = steering(Nu)*ones(N-Nu,1);
                        obj.planned_steering = min(max(obj.planned_steering, obj.params.u_min(1)),obj.params.u_max(1));
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
%                 for t=1:current_model.params.output_delay+1
%                     obj.sim_model.update(current_model.get_up(1));
%                 end
                u = obj.limit_steering(u, current_model);
            end
            obj.main_model.set_k(current_model.k);
            u0 = obj.main_model.params.u_nominal;
            u0(1) = min(max(u, obj.params.u_min(1)), obj.params.u_max(1));
            obj.main_model.update(u0);
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
            if obj.linearize_sim_model
                obj.sim_model.copy_state(current_model);
                %obj.main_model.set_k(current_model.k);
                local_s = obj.sim_model.get_local_s();
                %local_s = obj.main_model.get_local_s();
                %D = obj.controllers(1).D;
                %local_s(length(local_s):D) = local_s(length(local_s));
            else
                total_weight = 0;
                local_s = obj.controllers(1).linear_model.s1*0;
                for i=1:length(obj.controllers)
                    weight = obj.membership_fun(obj.controllers(i), current_model);
                    obj.weights(current_model.k, i) = weight;
                    total_weight = total_weight + weight;
                    local_s = local_s + weight * obj.controllers(i).linear_model.s1;
                end
                local_s = local_s/total_weight;
            end
        end
        
        function local_s2 = get_local_s2(obj, current_model)
            total_weight = 0;
            local_s2 = obj.controllers(1).linear_model.s1*0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i), current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                local_s2 = local_s2 + weight * obj.controllers(i).linear_model.s2;
            end
            local_s2 = local_s2/total_weight;
        end
        
        function y = get_free_response(obj, n)
            y = zeros(n, 1);
            u0 = obj.main_model.get_up(1);
            k_bckp = obj.main_model.k;
            for k=1:n
                obj.main_model.update(u0);
                y(k) = obj.main_model.y(obj.main_model.k);
            end
            obj.main_model.set_k(k_bckp);
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
        
        function u_limited = limit_steering(obj, u, current_model)
            lower_limit = obj.output_limit(1);
            upper_limit = obj.output_limit(2);
            if obj.limit_type ==1
                
                if obj.include_disturbance
                    z0 = obj.params.u_nominal(2);
                    z = current_model.u(current_model.k,2);
                    local_s2 = obj.get_local_s2(current_model);
                    dist_static_shift = (z-z0)*local_s2(length(local_s2));
                    if dist_static_shift < 0
                        a=1
                    end
                    lower_limit = lower_limit-dist_static_shift;
                    upper_limit = upper_limit - dist_static_shift;
                end
                lower_limit_dist = current_model.y(current_model.k)-lower_limit;
                upper_limit_dist = upper_limit - current_model.y(current_model.k);
                if lower_limit_dist<obj.lower_bandwidth || upper_limit_dist<obj.upper_bandwidth
                    max_steering = obj.static_inv(upper_limit);
                    max_steering = max_steering(1);
                    min_steering = obj.static_inv(lower_limit);
                    min_steering = min_steering(1);
                    u_limited = min(max(u, min_steering), max_steering);
                else
                    u_limited = u;
                end
            end
            if obj.limit_type == 2
                local_s = obj.get_local_s(current_model);
                D = obj.controllers(1).D;
                up = current_model.get_up(D);
                du = up(1:end-1, 1)-up(2:end, 1);
                Mp = generateMp(obj.lim_samples+obj.params.output_delay, D, local_s);
                Y0 = current_model.y(current_model.k)+Mp*du;
                if obj.lim_use_sim_model
                    if current_model.k == 50
                        a=1;
                    end
                    obj.sim_model.copy_state(current_model);
                    d = current_model.y(current_model.k) - obj.main_model.y(obj.main_model.k);
                    for t=1:obj.lim_samples+obj.params.output_delay
                        obj.sim_model.update(up(1,:));
                        obj.main_model.update(up(1,:));
                        obj.main_model.y(obj.main_model.k) = obj.main_model.y(obj.main_model.k) + d;
                        %future_local_s = obj.sim_model.get_local_s();
                        if obj.multi_lin
                            if obj.dmc_disturbance
                                future_local_s = obj.get_local_s(obj.main_model);
                            else
                                future_local_s = obj.get_local_s(obj.sim_model);
                            end
                            %
                            local_s(t) = future_local_s(t);
                        end
                        obj.main_model.y(obj.main_model.k) = obj.main_model.y(obj.main_model.k) - d;
                    end
                    if obj.dmc_disturbance
                        Y0real = obj.main_model.y(current_model.k+1:current_model.k+obj.lim_samples+obj.params.output_delay);
                    else
                        Y0real = obj.sim_model.y(current_model.k+1:current_model.k+obj.lim_samples+obj.params.output_delay);
                        d = 0;
                    end
                    Y0 = Y0real + d;
                    obj.main_model.set_k(current_model.k);
                end
                if obj.include_disturbance
                    local_s2 = obj.get_local_s2(current_model);
                    Mpz = generateMp(obj.lim_samples+obj.params.output_delay, D, local_s2);
                    up2 = [current_model.u(current_model.k,2); up(1:end-1,2)];
                    dU2 = up2(1:D-1) - up2(2:D);
                    du2 = up(1:end-1, 2)-up(2:end, 2);
                    Y0 = Y0 + Mpz*dU2;
                end
                max_du = 99999;
                min_du = -99999;
                if current_model.k == 52
                    a=1
                end
                for k=obj.params.output_delay+1:obj.lim_samples+obj.params.output_delay
                    if local_s(k)>0
                        max_du_temp = (upper_limit-Y0(k))/local_s(k);
                        max_du = min(max_du_temp, max_du);

                        min_du_temp = (lower_limit-Y0(k))/local_s(k);
                        min_du = max(min_du_temp, min_du);
                    else
                        max_du_temp = (lower_limit-Y0(k))/local_s(k);
                        max_du = min(max_du_temp, max_du);

                        min_du_temp = (upper_limit-Y0(k))/local_s(k);
                        min_du = max(min_du_temp, min_du);
                    end
                end
                if min(max(u, up(1)+min_du), up(1)+max_du) ~= u
                    a=1;
                    current_model.k
                end
                u_min = max(up(1)+min_du, obj.params.u_min(1));
                u_max = min(up(1)+max_du, obj.params.u_max(1));
                
                threshold = 0;
                if u_min+threshold<u_max
                    u_limited = min(max(u, u_min), u_max);
                else
                    max_static = obj.static_inv(upper_limit);
                    max_static = max_static(1);
                    min_static = obj.static_inv(lower_limit);
                    min_static = min_static(1);
                    u_limited = min(max(u, min_static), max_static);
                    u_limited = u;
                end
            end
        end
        
        function set_include_disturbance(obj, value)
            for c_idx=1:length(obj.controllers)
                obj.controllers(c_idx).include_disturbance = value;
            end
            obj.include_disturbance = value;
        end
        
        function set_s2(obj, s2)
            for c_idx=1:length(obj.controllers)
                obj.controllers(c_idx).set_s2(s2);
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
        
        function obj = plot_mf(obj, samples, normalize)
            m = Model([]);
            figure;
            hold on;
            if nargin<3
                normalize = 1;
            end
            w = zeros(samples, length(obj.controllers));
            y = zeros(samples,1);
            for i=1:samples
                for k=1:length(obj.controllers)
                    
                    y(i) = obj.params.y_min+(obj.params.y_max-obj.params.y_min)*i/samples;
                    m.y(m.k) = y(i);
                    w(i, k) = obj.membership_fun(obj.controllers(k), m);
                end
                if normalize
                    w(i,:) = w(i,:)/sum(w(i,:));
                end
            end
            for k=1:length(obj.controllers)
                plot(y, w(:,k));
            end
            hold off;
        end
        
        function obj = save_csv_mf(obj, filename, normalize)
            if nargin<3
                normalize = 1;
            end
            m = Model([]);
            column_names = {'y'};
            samples = 100;
            w = zeros(samples, length(obj.controllers));
            for k=1:length(obj.controllers)
                column_names{k+1} = ['w', num2str(k)];
                y = zeros(samples,1);
                for i=1:samples
                    y(i) = obj.params.y_min+(obj.params.y_max-obj.params.y_min)*i/samples;
                    m.y(m.k) = y(i);
                    w(i, k) = obj.membership_fun(obj.controllers(k), m);
                end
            end
            for i = 1:length(y)
                w(i,:) = w(i,:)/sum(w(i,:));
            end
            csvwrite_with_headers(filename, [y, w], column_names);
        end
        
        function obj = save_csv_s(obj, filename)
            m = Model([]);
            column_names = {'t'};
            D = length(obj.controllers(1).linear_model.s1);
            s = zeros(D, length(obj.controllers));
            t = [1:D]*obj.params.Ts;
            figure;
            hold on;
            for k=1:length(obj.controllers)
                column_names{k+1} = ['s', num2str(k)];
                s(:, k) = obj.controllers(k).linear_model.s1;
                plot(s(:,k));
            end
            csvwrite_with_headers(filename, [t', s/3600], column_names);
        end
    end
end