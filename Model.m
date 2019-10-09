classdef Model < handle
    properties
        x = zeros(200,2);
        y = zeros(200,1);
        u = zeros(200,3);
        k=1;
        Ysp = [];
        params;
    end
    methods
        function obj=Model(Ysp, params)
            if nargin<2
                obj.params = ModelParams();
            else
                obj.params = params;
            end
            obj.x = repmat(obj.params.x_nominal, [200,1]);
            obj.y = ones(200,1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [200,1]);
            obj.k=1;
            if nargin>0
                obj.Ysp = Ysp;
            end
        end
        function y=update(obj, u)
            obj.u(obj.k, :) = u;
            
            % obliczenie nowej wartoœci zmiennych stanu za pomoc¹ metody
            % Eulera. Zmienna subdiv zwiêksza rozdzielczoœæ symulacji
            % wzglêdem okresu próbkowania
            obj.x(obj.k+1, :) = obj.x(obj.k, :);
            for i=1:obj.params.subdiv
                obj.x(obj.k+1,:) = obj.x(obj.k+1,:)+...
                    dx(obj.x(obj.k+1,:), u, obj.params)' * obj.params.Ts/obj.params.subdiv;
            end
            obj.y(obj.k+1) = root_h(obj.x(obj.k+1,:),obj.y(obj.k), obj.params);
            y = obj.y(obj.k+1);
            obj.k = obj.k+1;
        end
    end
end
            
            
            