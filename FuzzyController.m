classdef FuzzyController < handle
    % klasa implementująca regulator rozmyty.
    properties
        controllers = [];
        membership_fun;
        weights= [];
    end
    methods
        function obj = FuzzyController(controllers, membership_fun)
            % konstruktor przyjmuje listę regulatorów oraz punkty pracy w
            % postaci stanu modelu. Funkcja membership_fun określa
            % podobieństwo obecnej sytuacji i punktu pracy
            obj.controllers = controllers;
            obj.membership_fun = membership_fun;
            obj.weights = zeros(1000,length(controllers));
        end
        function u = get_steering(obj, current_model)
            total_weight = 0;
            steering = 0;
            for i=1:length(obj.controllers)
                weight = obj.membership_fun(obj.controllers(i).linear_model, current_model);
                obj.weights(current_model.k, i) = weight;
                total_weight = total_weight + weight;
                steering = steering + obj.controllers(i).get_steering(current_model)*weight;
            end
            obj.weights(current_model.k, :) = obj.weights(current_model.k, :)/total_weight;
            u = steering/total_weight;
        end
    end
end