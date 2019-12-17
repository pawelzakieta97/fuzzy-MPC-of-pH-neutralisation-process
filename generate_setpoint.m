function Ysp = generate_setpoint(random, samples)
if nargin<1
    random = false;
end
if nargin<2
    samples = 500;
end
if random 
    Ysp = random_signal(samples,50,[3,9]);
else
    Ysp = random_signal(samples,50,[3,9], 1);
    Ysp = random_signal(samples,50,[3,10], 1);
end