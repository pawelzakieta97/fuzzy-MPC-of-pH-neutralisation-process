function y = simulate_steering(u)
model = Model(zeros(length(u),1));
for k=1:length(u)
    model.update(u(k,:));
end
y = model.y;
