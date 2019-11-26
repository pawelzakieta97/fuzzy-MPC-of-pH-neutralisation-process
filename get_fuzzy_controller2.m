function fc = get_fuzzy_controller(op_points, lambdas, step_sizes, membership_fun, output_limit)
clear controllers;

D = 50;
N = D;
Nu = 2;
if nargin<5
    output_limit = [0,0];
end
if length(step_sizes) == 1
    step_size = step_sizes(1);
    
    for op_point_idx=1:length(op_points)
        % wyznaczenie wartoœci sygna³ów steruj¹cych, dla których uzyskane jest
        % zadane wzmocnienie op_points(i)
        u0 = static_inv(op_points(op_point_idx),1);

        % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna³u
        % steruj¹cego u1 i zak³ócenia u2
        [~, s1] = step(u0, [step_size,0,0], D+1);
        s1 = (s1(2:D+1)-s1(1))/step_size;
        [~, s2] = step(u0, [0,step_size,0], D+1);
        s2 = (s2(2:D+1)-s2(1))/step_size;
        s = zeros(D, 2);
        s(:,1)=s1;
        s(:,2)=s2;

        % utworzenie listy regulatorów dmc na podstawie wygenerowanych
        % odpowiedzi skokowych
        controllers(op_point_idx)=DMC(s,N,Nu,D,lambdas(op_point_idx), op_points(op_point_idx), step_size, output_limit);
    end
    fc = FuzzyController(controllers, membership_fun);
else
    for step_idx=1:len(step_sizes)
        step_size = step_sizes(step_idx);
        for op_point_idx=1:length(op_points)
            % wyznaczenie wartoœci sygna³ów steruj¹cych, dla których uzyskane jest
            % zadane wzmocnienie op_points(i)
            u0 = static_inv(op_points(op_point_idx),1);

            % wyznaczenie odpowiedzi skokowych z danego punktu pracy dla sygna³u
            % steruj¹cego u1 i zak³ócenia u2
            [~, s1] = step(u0, [step_size,0,0], D+1);
            s1 = (s1(2:D+1)-s1(1))/step_size;
            [~, s2] = step(u0, [0,step_size,0], D+1);
            s2 = (s2(2:D+1)-s2(1))/step_size;
            s = zeros(D, 2);
            s(:,1)=s1;
            s(:,2)=s2;

            % utworzenie listy regulatorów dmc na podstawie wygenerowanych
            % odpowiedzi skokowych
            controllers(op_point_idx)=DMC(s,N,Nu,D,lambdas(op_point_idx, step_idx), op_points(op_point_idx), step_size);
        end
        fc = FuzzyController(controllers, membership_fun);
    end
end
if length(lambdas)==1
    fc = controllers(1);
end