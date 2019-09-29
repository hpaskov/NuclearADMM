function [ x, ind ] = flatten_cell( c )
%Stacks entries of cell c into a vector

n = cellfun(@length, c);
ind = [0; cumsum(n)];

x = zeros(sum(n), 1);
for i = 1 : length(c)
    x((ind(i)+1):ind(i+1)) = c{i};
end

end

