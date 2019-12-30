function cost = get_cost(u1, N, sim_model, lambda)
model = sim_model.clone();
Nu = length(u1);
u = repmat(model.params.u_nominal, [N, 1]);
u(1:Nu, 1) = u1;
u(Nu+1:end, 1) = u1(Nu);
cost = 0;
up = model.get_up(1);
up = up(1);
if model.k>length(model.Ysp)
    ysp = model.Ysp(length(model.Ysp));
else
    ysp = model.Ysp(model.k);
end
for k=1:N
    model.update(u(k,:));
    cost = cost + (ysp - model.y(model.k))^2 + ...
        lambda * (model.u(model.k-1,1) - up)^2;
    up = model.u(model.k-1,1);
end
a=1;
