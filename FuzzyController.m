classdef FuzzyController < handle
    % klasa implementuj�ca regulator rozmyty.
    properties
        controllers = [];
        membership_fun;
        weights = [];
        main_controller;
        numeric;
        step_responses;
    end
    methods
        function obj = FuzzyController(controllers, membership_fun, numeric)
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
            if nargin<3
                numeric = false;
            end
            obj.numeric = numeric;
            D = 80;
            obj.step_responses = zeros(500,D);
        end
        function exp_step = approximate_steering(obj, model)
            exp_step = obj.main_controller.get_steering(model) - model.get_up(1);
        end
        function u = get_steering(obj, current_model)
            total_weight = 0;
            steering = 0;
            if strcmp(functions(obj.membership_fun).function, 'output_and_step_size')
                exp_step = obj.approximate_steering(current_model);
            end
            local_s = obj.controllers(1).linear_model.s1*0;
            for i=1:length(obj.controllers)
                if strcmp(functions(obj.membership_fun).function, 'output_and_step_size')
                    weight = obj.membership_fun(obj.controllers(i), current_model, exp_step);
                else
                    weight = obj.membership_fun(obj.controllers(i), current_model);
                end
                if obj.numeric
                    local_s = local_s + weight * obj.controllers(i).linear_model.s1;
                end
%                 reference_op_point = obj.controllers(i).linear_model.op_point;
%                 current_op_point = current_model.y(current_model.k);
                % weight = obj.membership_fun(ref1, x1);

                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                steering = steering + obj.controllers(i).get_steering(current_model)*weight;
            end
            
            obj.weights(current_model.k, :) = obj.weights(current_model.k, :)/total_weight;
            u = steering/total_weight;
            if obj.numeric
                local_s = local_s/total_weight;
                up = current_model.get_up(1);
                obj.step_responses(current_model.k, :) = local_s' * (u-up(1));
            end
        end
        function y0 = get_free_response(obj, k, length)
            D = 80;
            if nargin<3
                length = D;
            end
            y0 = zeros(length, 1);
            detected_impact = 0;
            for i=1:min(k,D)
                detected_impact = detected_impact + obj.step_responses(k-i, i);
            end
            
        end
    end
end