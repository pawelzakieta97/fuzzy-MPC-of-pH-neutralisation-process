g = tf([2], [3,1]);
g = c2d(g,1);
s = step(g);
stairs(0:15, s(1:16));
hold on;
stairs(-5:1:15, [zeros(5,1); ones(16,1)]);
legend('sygna³ wyjœciowy', 'sygna³ steruj¹cy', 'Location', 'northwest');
grid on;
hold off;
figure;
plot([0,1],[0,2]);
hold on;
scatter([0,1],[0,2]);
xlim([-0.5 1.5])
ylim([-0.5 2.5])
xlabel('u_1');
ylabel('y_{stat}');
grid on;