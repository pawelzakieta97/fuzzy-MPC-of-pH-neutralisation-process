clear;
min_size = -5;
max_size = 5;
step_sizes = [-5, -2.5, -1, -0.5, -0.25, -0.1, 0.1, 0.25, 0.5, 1, 2.5, 5];
n_sizes = length(step_sizes);
n_steps = 70;
params = ModelParams();
model = SLinearModel([]);
y0_min = 3;
y0_max = 10;
for size_idx =1:n_sizes
    step_size = min_size + (max_size-min_size)*size_idx/n_sizes;
    step_size = step_sizes(size_idx);
    for step_idx =1:n_steps
        y0 = y0_min + (y0_max-y0_min)*step_idx/n_steps;
        [~, s] = SLinear_step(y0, step_size, 50);
        s = (s-s(1))/step_size;
        f = figure('visible', 'off');
        plot(s);
        title(['step size=', num2str(step_size),',  y_0=', num2str(y0)])
        ylim([0 1.1]);
        if step_size>0
            filename = ['steps_slin/step_size_', num2str(step_size*100),'y0', num2str(y0*100)];
        else
            filename = ['steps_slin/step_size_neg', num2str(abs(step_size*100)),'y0', num2str(y0*100)];
        end
        print(filename, '-dpng');
        close(f)
    end
end


