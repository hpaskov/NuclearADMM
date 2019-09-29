function [ X, mu, scale ] = normalize_features( X, scaletype )
%Normalizes feature matrix columns
mu = mean(X);
X = bsxfun(@minus, X, mu);

switch scaletype
    case 'L2'
        scale = sqrt(sum(X.*X));
    case 'Std'
        scale = sqrt(mean(X.*X));
    case 'L1'
        scale = sum(abs(X));
    otherwise
        scale = ones(1, size(X, 2));
end

scale(scale < 1e-6) = 1;
X = bsxfun(@times, X, scale.^-1);

end

