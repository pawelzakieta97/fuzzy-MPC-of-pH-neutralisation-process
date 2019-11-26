[u,y] = static_char(1000,1,ModelParams());
figure;
plot(u(:,1),y);
xlabel('u_1');
ylabel('y_{stat}');

u_s1 = ModelParams().u_nominal;
u_s2 = u_s1;
u_s1(1)=16.5;
u_s2(1)=13.5;
[x,ys1] = step(u_s1, [0.25, 0, 0]);
[x,ys2] = step(u_s2, [0.25, 0, 0]);
figure;
plot((ys1-ys1(1))*4);
hold on;
plot((ys2-ys2(1))*4);
legend('skok z wartoœci u1=16.5', 'skok z wartoœci u1=13.5', 'Location', 'east');
xlabel('t')