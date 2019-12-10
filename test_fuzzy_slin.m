addpath('./membership_functions/');

fc = get_fuzzy_slin_controller([
    7, 0.1, 1;
    3,0.1, 1;
    5, 0.1, 1;
    8.5, 0.1, 1;
    10, 0.1, 1;
%     ,@output_and_step_size);
    3, 2, 1;
    5, 2, 1;
    7, 2, 1;
    8.5, 2, 1;
    5, -2, 1;
    7, -2, 1;
    8.5, -2, 1;
    10, -2, 1], @output_and_step_size);
    