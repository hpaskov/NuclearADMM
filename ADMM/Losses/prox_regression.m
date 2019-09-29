function prox_regression( vars, rho, lambda, lp )
%Cache-optimized regression proximal operator for multitask regression problems

if (lp.rho ~= rho)
    lp.rho = rho;
    lp.G3 = init_regression_helper( lp.TaskGroup, lp.U, lp.S, lp.missing, lp.N, rho);
end

%Eta
mexComputeEta(vars.W, vars.Z, vars.E, lp.R, rho,lp.N);
G = length(lp.gid) - 1;
for g = 1 : G
    tid = (lp.gid(g)+1):lp.gid(g+1);
    Vteta = lp.V{g}'*vars.W(:, tid);
    %Handle epsilon
    epsilon = bsxfun(@times, lp.S{g}, bsxfun(@plus, lp.S{g}.^2, rho*lp.N(tid)).^-1).*Vteta;
    mexComputeEpsilon(tid, lp.U{g}, lp.G3, lp.epsilon, epsilon, lp.missing32, lp.Nmissing);
    epsilon = bsxfun(@times, lp.S{g}, bsxfun(@plus, lp.S{g}.^2, rho*lp.N(tid)).^-1).*epsilon;
    %Handle w
    epsilon = epsilon + bsxfun(@minus, bsxfun(@plus, lp.S{g}.^2, rho*lp.N(tid)).^-1,(lp.N(tid)*rho).^-1).*Vteta;
    mexFinishW(vars.W, lp.V{g}, epsilon, rho, lp.N, lp.gid(g)+1, lp.gid(g+1));
end

end