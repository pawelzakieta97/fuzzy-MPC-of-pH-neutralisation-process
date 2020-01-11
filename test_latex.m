x = [1:100]/10;
y = sin(x);
plot(x,y);
csvwrite_with_headers('test.csv', [x',y'], {'x', 'y'});