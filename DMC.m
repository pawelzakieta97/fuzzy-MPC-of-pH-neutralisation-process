classdef DMC < handle
    % klasa reprezentująca regulator DMC
    properties
        s;
        lambda = 100;
        D = 500;
        N = 500;
        Nu = 5;
        K = [];
        M;
        Mp1 = [];
        Mp2 = [];
        KMp1;
        KMp2;
        K1sum;
        op_point;
        step_size;
        params;
        
    end
    methods
        function obj=DMC(s, N, Nu, D, lambda, op_point, step_size)
            obj.params = ModelParams();
            obj.s = s;
            obj.N = N;
            obj.Nu = Nu; 
            obj.D = D;
            obj.lambda = lambda;
            obj.op_point = op_point;
            obj.step_size = step_size;
            obj.M = generateM(N, Nu, D, s(:,1));
            obj.Mp1 = generateMp(N, D, s(:,1));
            obj.Mp2 = generateMp(N, D, s(:,2));
            obj.K = (obj.M' * obj.M + lambda * eye(Nu,Nu)) \ obj.M';
            obj.KMp1 = obj.K(1,:)*obj.Mp1;
            obj.KMp2 = obj.K(1,:)*obj.Mp2;
            obj.K1sum = sum(obj.K(1,:));
        end
        function obj = set_lambda(obj, new_lambda)
            obj.lambda = new_lambda;
            obj.K = (obj.M' * obj.M + new_lambda * eye(obj.Nu,obj.Nu)) \ obj.M';
            obj.KMp1 = obj.K(1,:)*obj.Mp1;
            obj.KMp2 = obj.K(1,:)*obj.Mp2;
            obj.K1sum = sum(obj.K(1,:));
        end
        function u_new = get_steering(obj, model)
            D = obj.D;
            
            % pobranie historii wartości sterowania z modelu na którym
            % działa regulator i uzupełnienie go w razie potrzeby
            % wartościami nominalnymi
            if model.k<=D
                u = [repmat(obj.params.u_nominal, [D,1]);model.u(1:model.k-1, :)];
                k = model.k+D;
            else
                u = model.u(1:model.k-1, :);
                k = model.k;
            end
            Ysp = model.Ysp;
            y=model.y(model.k);
            dU1 = u(k-1:-1:k-D+1,1)-u(k-2:-1:k-D,1);
            dU2 = u(k-1:-1:k-D+1,2)-u(k-2:-1:k-D,2);
            u_new = u(k-1,1) + obj.K1sum*(Ysp(model.k) - y) - obj.KMp1*dU1 - obj.KMp2*dU2;
        end
    end
end
        