classdef DMC < handle
    % klasa reprezentuj¹ca regulator DMC
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
        output_limit;
        linear_model;
    end
    methods
        function obj=DMC(linear_model, N, Nu, D, lambda)
            obj.params = ModelParams();
            obj.linear_model = linear_model;
            % obj.s = s;
            obj.N = N;
            obj.Nu = Nu; 
            obj.D = D;
            obj.lambda = lambda;
            % obj.op_point = op_point;
            % obj.step_size = step_size;
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
        function u_new = get_steering(obj, model, free_resp_override)
            D = obj.D;
            up = model.get_up(obj.D);
            Ysp = model.Ysp;
            y=model.y(model.k);
            dU1 = up(1:D-1,1)-up(2:D,1);
            if size(up, 2) == 1
                dU2 = 0*dU1;
            else
                dU2 = up(1:D-1, 2) - up(2:D,2);
            end
            if nargin<3
                du = obj.K1sum*(Ysp(model.k) - y) - obj.KMp1*dU1 - obj.KMp2*dU2;
            else
                du = obj.K(1,:)*(Ysp(model.k)*ones(obj.N,1) - free_resp_override(1:obj.N));
                % du = obj.K(1,:)*((Ysp(model.k) - y)*ones(obj.N,1) - obj.Mp1*dU1);
            end
            % du = obj.K1sum*(Ysp(model.k) - y) - obj.KMp1*dU1 - obj.KMp2*dU2;
            u_new = up(1,1) + du;
%             if obj.output_limit(1) ~= 0 || obj.output_limit(2) ~= 0
%                 free_resp = model.y(model.k) + obj.Mp1(1,:)*dU1 + obj.Mp2(1,:)*dU2;
%                 du_min = (obj.output_limit(1)-free_resp)/obj.s(1,1);
%                 du_max = (obj.output_limit(2)-free_resp)/obj.s(1,1);
% %                 u_new = u(k-1,1)+min(max(du_min, du), du_max);
%                 u_new = up(1,1)+min(max(du_min, du), du_max);
%             end
        end
        function u_new = get_full_steering(obj, model, free_resp_override, suggested_steering)
            if nargin < 4
                suggested_steering = zeros(obj.Nu, 1);
            end
            D = obj.D;
            up = model.get_up(obj.D);
            Ysp = model.Ysp;
            y=model.y(model.k);
            dU1 = up(1:D-1,1)-up(2:D,1);
            if size(up, 2) == 1
                dU2 = 0*dU1;
            else
                dU2 = up(1:D-1, 2) - up(2:D,2);
            end
            if nargin == 4
                du = obj.Ki*(obj.M'*...
                    (Ysp(model.k)*ones(obj.N,1) - free_resp_override(1:obj.N)) - ...
                    obj.lambda*suggested_steering);
            end
            if nargin == 3
                du = obj.K*(Ysp(model.k)*ones(obj.N,1) - free_resp_override(1:obj.N));
            end
            if nargin<3
                du = obj.K*(Ysp(model.k)*ones(obj.N,1) - obj.Mp1*dU1 - obj.Mp2*dU2);
            end
            
            % du = obj.K1sum*(Ysp(model.k) - y) - obj.KMp1*dU1 - obj.KMp2*dU2;
            u_new = 0*du;
            u_new(1) = up(1,1)+du(1)+suggested_steering(1);
            for i = 2:length(du)
                u_new(i) = u_new(i-1)+du(i)+suggested_steering(i);
            end
            % u_new = u_new + suggested_steering;
            % u_new = up(1,1) + du;
        end
    end
end
        