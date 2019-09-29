function check_valid_indices( c, T )
%Checks that contents of cell are between 1 and T (inclusive)
if min(cellfun(@(x) min(x), c)) <= 0
    throw(MException('ArgumentException', 'Nonpositive index detected'))
end

if max(cellfun(@(x) max(x), c)) > T
    throw(MException('ArgumentException', 'Index out of bounds detected'))
end

end

