classdef DMC < handle
    properties
        s;
        lambda = 100;
        D = 500;
        N = 500;
        Nu = 5;
        K = [];
        Mp1 = [];
        Mp2 = [];
        model;
        u_nominal;
    end
    methods
        function obj=DMC(s, N, Nu, D, lambda)
            params = ModelParams();
            obj.s = s;
            obj.N = N;
            obj.Nu = Nu; 
            obj.D = D;
            obj.lambda = lambda;
            M1 = generateM(N, Nu, D, s(:,1));
            obj.Mp1 = generateMp(N, D, s(:,1));
            obj.Mp2 = generateMp(N, D, s(:,2));
            obj.K = (M1' * M1 + lambda * eye(Nu,Nu)) \ M1';
            obj.u_nominal = params.u_nominal;
        end
        function u_new = get_steering(obj, model)
            
            D = obj.D;
            N = obj.N;
            Mp1 = obj.Mp1;
            Mp2 = obj.Mp2;
            
            % pobranie historii wartoœci sterowania z modelu na którym
            % dzia³a regulator i uzupe³nienie go w razie potrzeby
            % wartoœciami nominalnymi
            if model.k<=D
                u = [repmat(obj.u_nominal, [D,1]);model.u(1:model.k-1, :)];
                k = model.k+D;
            else
                u = model.u(1:model.k-1, :);
                k = model.k;
            end
            Yzad = model.Yzad;
            y=model.y(model.k);
            dU1 = u(k-1:-1:k-D+1,1)-u(k-2:-1:k-D,1);
            dU2 = u(k-1:-1:k-D+1,2)-u(k-2:-1:k-D,2);
            u_new = u(k-1,1) + obj.K(1, :)*...
                (Yzad(model.k)*ones(N,1)-y*ones(N,1)-Mp1*dU1-Mp2*dU2);
        end
    end
end
        