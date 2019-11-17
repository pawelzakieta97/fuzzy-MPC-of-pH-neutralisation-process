params = ModelParams();
model = Model(zeros(500,1));
[~,y1] = step(params.u_nominal, [1,0,0], 100);
[~,y2] = step(params.u_nominal, [0,1,0], 100);
s1 = y1(2:end) - y1(1);
s2 = y2(2:end) - y2(1);
stairs(s1);
sm = StepRespModel([s1',s2'], 7);
u = [repmat(params.u_nominal, [30,1]); repmat(params.u_nominal+[1,0,0], [200,1])];
for k=1:length(u)
    sm.update(u(k,:));
    model.update(u(k,:));
end
