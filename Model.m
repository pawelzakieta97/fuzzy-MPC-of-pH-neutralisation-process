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
        function obj = set_k(obj, k)
            obj.k = k;
        end
        function obj = reset(obj)
            obj.x = repmat(obj.params.x_nominal, [length(obj.Ysp),1]);
            obj.y = ones(length(obj.Ysp),1)*obj.params.y_nominal;
            obj.u = repmat(obj.params.u_nominal, [length(obj.Ysp),1]);
            obj.k=1;
        end
        function y=update(obj, u)
            for j=1:size(u,1)
                obj.u(obj.k, :) = u(j,:);

                % obliczenie nowej warto�ci zmiennych stanu za pomoc� metody
                % Eulera. Zmienna subdiv zwi�ksza rozdzielczo�� symulacji
                % wzgl�dem okresu pr�bkowania
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
            % zwraca warto�ci przesz�ych sterowa�
            % (w kolejno�ci od najpo�niejszego do najwcze�niejszego)
            % zwraca D warto�ci, uzupe�nia warto�ciami
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
            ylim([2,10.5]);
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
        
        function obj = save_csv(obj, filename, range)
            if nargin<3
                range = [1, obj.k];
            end
            column_names = {'t'};
            t=[1:range(2)-range(1)+1]*obj.params.Ts;
            for u_idx = 1:size(obj.u,2)
                column_names{u_idx+1} = ['u', num2str(u_idx)];
            end
            
            column_names{length(column_names)+1} = 'y';
            column_names{length(column_names)+1} = 'ysp';
            
            csvwrite_with_headers(filename, [t',...
                obj.u(range(1):range(2),:),...
                obj.y(range(1):range(2)),...
                obj.Ysp(range(1):range(2))],...
            column_names);
        end
        
        function m = clone(obj)
            m = Model(obj.Ysp);
            m.x = obj.x;
            m.y = obj.y;
            m.u = obj.u;
            m.params = obj.params;
            m.k = obj.k;
        end
        
    end
end
            
            
            