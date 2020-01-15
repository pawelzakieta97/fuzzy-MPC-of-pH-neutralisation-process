function weight = trapez(controller, current_model)
reference_model = controller.linear_model;
slopel = reference_model.slopel;
sloper = reference_model.sloper;
maxl = reference_model.maxl;
maxr = reference_model.maxr;
y = current_model.y(current_model.k);
if maxl<y<maxr
    weight = 1;
else
    if y<slopel || y>sloper
        weight = 0;
    else
        if y<maxl
            weight = (y-slopel)/(maxl-slopel);
        else
            weight = (sloper-y)/(sloper-maxr);
        end
    end
end