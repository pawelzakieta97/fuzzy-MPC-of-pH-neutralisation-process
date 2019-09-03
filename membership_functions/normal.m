function weight = normal(model1, model2)
weight = gaussmf(model1.y(model1.k), [1,model2.y(model2.k)]);
end