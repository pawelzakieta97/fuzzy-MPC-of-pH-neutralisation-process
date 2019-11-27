clear;
n_steps = 50;
params = ModelParams();
n_sizes = 20;
min_size = -15;
max_size = 15;
for size_idx =1:n_sizes
    step_size = min_size+(max_size-min_size)*size_idx/n_sizes;
    for step_idx = 1:n_steps
        y0 = params.y_min + (params.y_max-params.y_min)*step_idx/n_steps;
        u0 = static_inv(y0, 1);
        [~, s] = step(u0, [step_size,0,0], 50);
        s = (s-s(1))/step_size;
        plot(s);
        title(['step size=', num2str(step_size),',  y_0=', num2str(y0)])
        ylim([0 s(100)]);
        print(['steps/step_size', num2str(step_size*10),'y0', num2str(y0*10)], '-dpng');
    end
end