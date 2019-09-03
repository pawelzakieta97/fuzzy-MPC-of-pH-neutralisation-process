function Mp = generateMp(N, D, s)
K = s(D);
s(D:N+D) = K;
Mp = zeros(N, D-1);
for row = 1:N
    Mp(row, :) = s(row+1:row+D-1)-s(1:D-1);
end
end
