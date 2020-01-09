classdef Model < handle
    properties
        x = zeros(500,2);
        y = zeros(500,1);
        u = zeros(500,3);
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
                u_time = obj.k-obj.params.output_delay;
                if u_time <1
                    u_update = obj.params.u_nominal;
                else
                    u_update = obj.u(u_time, :);
                end
                for i=1:obj.params.subdiv
                    obj.x(obj.k+1,:) = obj.x(obj.k+1,:)+...
                        dx(obj.x(obj.k+1,:), u_update, obj.params)' * obj.params.Ts/obj.params.subdiv;
                end
                obj.y(obj.k+1) = root_h(obj.x(obj.k+1,:),obj.y(obj.k), obj.params);
                y = obj.y(obj.k+1);
                obj.k = obj.k+1;
            end
        end
        function up = get_up(obj, length)
            % zwraca wartoœci przesz³ych sterowañ
            % (w kolejnoœci od najpoŸniejszego do najwczeœniejszego)
            % zwraca D wartoœci, uzupe³nia wartoœciami
            % nominalnymi
            if obj.k == 1
                up = repmat(obj.params.u_nominal, [length,1]);
            else
                up = obj.u(obj.k-1:-1:1, :);
                up = [up;repmat(obj.params.u_nominal, [length,1])];
                up = up(1:length,:);
            end
        end
        function obj=plot(obj)
            figure
            subplot(2,1,1);
            stairs(obj.Ysp, '--');
            hold on;
            plot(obj.y(1:length(obj.Ysp)));
            ylim([2,10]);
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
            stairs(obj.u(:,1));
            legend('u1');
        end
        function obj = copy_state(obj, reference_model)
            obj.x = reference_model.x;
            obj.y = reference_model.y;
            obj.u = reference_model.u;
            obj.k = reference_model.k;
            
        end
    end
end
            
            
            