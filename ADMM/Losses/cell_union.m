function [ ret ] = cell_union( c, N)

present = false(N, 1);
for i = 1 : length(c)
    present(c{i}) = true;
end

ret = sort(find(present));

end

