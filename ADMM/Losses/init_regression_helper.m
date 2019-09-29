function [ G3 ] = init_regression_helper( TaskGroup, U, S, missing, N, rho)

G3 = cell(length(TaskGroup), 1);
for t = 1 : length(TaskGroup)
    if isempty(missing{t}); continue; end;
    u = U{TaskGroup(t)}(:, missing{t})';
    K = N(t)*rho*(u*bsxfun(@times, u', (S{TaskGroup(t)}.^2 + rho*N(t)).^-1));
    G3{t} = chol(.5*(K + K') - size(U{TaskGroup(t)}, 2)^-1);
end

end

