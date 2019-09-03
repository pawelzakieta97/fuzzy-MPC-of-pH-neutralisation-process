function signal = random_signal(length, T, range, seed)
    if nargin>3
        rng(seed);
    end
    k = 0;
    signal = [];
    while k<length
        len = int16(randn*T/2+T);
        signal = [signal; ones(len,1) * (rand*(range(2)-range(1))+range(1))];
        k = k + len;
    end
    signal = signal(1:length);
    