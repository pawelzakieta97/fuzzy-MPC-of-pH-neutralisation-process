function M=generateM(N, Nu, D, s)
K = s(D);
s(D:N) = K;
M = zeros(N, Nu);
for row = 1:N
    M(row, 1:min(row,Nu)) = s(row:-1:max(1,row-Nu+1));
end
end
