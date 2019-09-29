function W = prox_nuclear_helper(Y, lambda)
	[m n] = size(Y);
	%Assume matrix is tall
	if m < n
		Y = Y';
	end
	
	[Q S] = eig(Y'*Y);
	s = sqrt(max(0, diag(S)));
	ind = s > 1e-8;
    s = s(ind)';
    Q = Q(:, ind);
    R = bsxfun(@times, Q, max(0, s - lambda)./s);
	W = (Y*R)*Q';
	
	if m < n
		W = W';
	end
end