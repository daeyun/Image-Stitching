%% Test select_putative_matches
a = [1 2 3; 1 1 2; 4 1 4; 1 1 1];
b = [1 2 9; 1 1 2; 3 1 1; 1 4 1];
[q, w] = select_putative_matches(a, b, 0, 2);
assert(isequal(q, [2; 2]));
assert(isequal(w, [2; 1]));