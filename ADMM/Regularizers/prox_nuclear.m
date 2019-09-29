function prox_nuclear(myVars, rho, lambda, reg_params)
    % Proximal operator for nuclear norm
	myVars.Z = prox_nuclear_helper(myVars.W + myVars.E./rho, lambda/rho);
end