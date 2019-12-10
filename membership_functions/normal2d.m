function weight = normal2d(ref1, ref2, x1, x2)
weight = gaussmf(ref1, [1,x1])*gaussmf(ref2, [1,x2]);
end