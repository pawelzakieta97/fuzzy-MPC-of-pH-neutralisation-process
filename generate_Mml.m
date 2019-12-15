function Mml = generate_Mml(Nu, ss)
    D = size(ss,2);
    N = size(ss,1);
    K = ss(:,D-1);
    ss = [ss, repmat(K, [1, N-D])];
    Mml = zeros(N, Nu);
    for row = 1:N
        Mml(row, 1:min(row,Nu)) = ss(row, row:-1:max(1,row-Nu+1));
    end
end