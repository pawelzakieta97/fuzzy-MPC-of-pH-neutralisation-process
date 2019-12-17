classdef DMC_WM < handle
    % klasa reprezentuj¹ca regulator DMC dzia³aj¹cy na modelu Wienera
    properties
        s;
        lambda = 100;
        D = 500;
        N = 500;
        Nu = 5;
        K = [];
        Ki;
        M;
        Mp1 = [];
        Mp2 = [];
        KMp1;
        KMp2;
        K1sum;
        op_point;
        step_size;
        params;
        output_limit = [0,0];
        limit_output = 0;
        linear_model;
        lower_bandwidth = 0.0;
        upper_bandwidth = 0.0;
    end
    methods
        function obj=DMC_WM(N, Nu, D, lambda)
            obj.params = ModelParams();
            [~,s,~] = step(obj.params.u_nominal, 0.1, 80);
            amp = s(length(s))-s(1);
            linear_model = StepRespModel(s, amp, obj.params);
            obj.linear_model = linear_model;
            obj.N = N;
            obj.Nu = Nu; 
            obj.D = D;
            obj.lambda = lambda;
            obj.M = generateM(N, Nu, D, linear_model.s(:,1));
            obj.Mp1 = generateMp(N, D, linear_model.s(:,1));
            obj.Mp2 = generateMp(N, D, linear_model.s(:,2));
            obj.K = (obj.M' * obj.M + lambda * eye(Nu,Nu)) \ obj.M';
            obj.Ki = (obj.M' * obj.M + lambda * eye(Nu,Nu))^(-1);
            obj.KMp1 = obj.K(1,:)*obj.Mp1;
            obj.KMp2 = obj.K(1,:)*obj.Mp2;
            obj.K1sum = sum(obj.K(1,:));
            if nargin>7
                obj.output_limit = output_limit;
            else
                obj.output_limit = [0,0];
            end
        end
        function obj = set_lambda(obj, new_lambda)
            obj.lambda = new_lambda;
            obj.K = (obj.M' * obj.M + new_lambda * eye(obj.Nu,obj.Nu)) \ obj.M';
            obj.KMp1 = obj.K(1,:)*obj.Mp1;
            obj.KMp2 = obj.K(1,:)*obj.Mp2;
            obj.K1sum = sum(obj.K(1,:));
        end
        function u_new = get_steering(obj, current_model, free_resp_override)
            D = obj.D;
            up = current_model.get_up(obj.D);
            ysp = current_model.Ysp(current_model.k);
            
            y_out=current_model.y(current_model.k);
            y_in = static_inv(y_out);
            y_in = y_in(1);
            y_in_sp = static_inv(ysp);
            y_in_sp = y_in_sp(1);
            dU1 = up(1:D-1,1)-up(2:D,1);
            if size(up, 2) == 1
                dU2 = 0*dU1;
            else
                dU2 = up(1:D-1, 2) - up(2:D,2);
            end
            if nargin<3
                du = obj.K1sum*(y_in_sp - y_in) - obj.KMp1*dU1 - obj.KMp2*dU2;
            else
                du = obj.K(1,:)*(y_in_sp*ones(obj.N,1) - free_resp_override(1:obj.N));
            end
            % du = obj.K1sum*(Ysp(model.k) - y) - obj.KMp1*dU1 - obj.KMp2*dU2;
            u_new = up(1,1) + du;
            if obj.limit_output
                u_new = obj.limit_steering(u_new, current_model);
            end
        end
        function u_limited = limit_steering(obj, u, current_model)
            lower_limit = obj.output_limit(1);
            upper_limit = obj.output_limit(2);
            y_out = current_model.y(current_model.k);
            y_in = static_inv(y_out);
            y_in = y_in(1);
            up = current_model.get_up(obj.D);
            dup = up(1:obj.D-1,1)-up(2:obj.D,1);
            free_response = y_in + obj.Mp1*dup;
            future_output = free_response(1+obj.params.output_delay);
            lower_limit_dist = future_output-lower_limit;
            upper_limit_dist = upper_limit - future_output;
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
    end
end
        