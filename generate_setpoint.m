function Ysp = generate_setpoint(random)
if nargin<1
    random = false;
end
if random 
    Ysp = random_signal(500,50,[3,9]);
else
    Ysp = random_signal(500,50,[3,9], 1);
    Ysp = random_signal(500,50,[3,10], 1);
end