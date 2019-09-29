function [ y, mu, scale ] = normalize_response( y, scaletype )
%Normalizes regression response

mu = mean(y);
y = y - mu;

switch scaletype
    case 'L2'
        scale = sqrt(sum(y.*y));
    case 'L1'
        scale = sum(abs(y));
    case 'Linf'
        scale = max(abs(y));
    otherwise
        scale = 1;
end

if scale < 1e-6; scale = 1; end;
y = y/scale;


end

