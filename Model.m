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
            obj.x = repmat(obj.params.x_nominal, [length(Ysp),1]);
            obj.y = ones(length(Ysp),1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [length(Ysp),1]);
            obj.k=1;
            if nargin>0
                obj.Ysp = Ysp;
            end
        end
        function y=update(obj, u)
            for j=1:size(u,1)
                obj.u(obj.k, :) = u(j,:);

                % obliczenie nowej wartoœci zmiennych stanu za pomoc¹ metody
                % Eulera. Zmienna subdiv zwiêksza rozdzielczoœæ symulacji
                % wzglêdem okresu próbkowania
                obj.x(obj.k+1, :) = obj.x(obj.k, :);
                for i=1:obj.params.subdiv
                    obj.x(obj.k+1,:) = obj.x(obj.k+1,:)+...
                        dx(obj.x(obj.k+1,:), u(j,:), obj.params)' * obj.params.Ts/obj.params.subdiv;
                end
                obj.y(obj.k+1) = root_h(obj.x(obj.k+1,:),obj.y(obj.k), obj.params);
                y = obj.y(obj.k+1);
                obj.k = obj.k+1;
            end
        end
        function obj=plot(obj)
            figure
            subplot(2,1,1);
            stairs(obj.Ysp, '--');
            hold on;
            plot(obj.y(1:length(obj.Ysp)));
            legend('setpoint', 'output', 'Location','southeast');
            xlabel('t');
            hold off;

            subplot(2,1,2); 
            stairs(obj.u(:,1));
            legend('u1');
            xlabel('t');
        end
        function obj=plot_horizontal(obj)
            figure
            subplot(1,2,1);
            stairs(obj.Ysp, '--');
            hold on;
            plot(obj.y(1:length(obj.Ysp)));
            legend('setpoint', 'output', 'Location','southeast');
            hold off;

            subplot(1,2,2); 
            plot(obj.u(:,1));
            legend('u1');
        end
    end
end
            
            
            