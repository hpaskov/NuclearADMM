function [ predicted ] = Predict( X, task_indices, W, b )

num_tasks = length(task_indices);
predicted = cell(num_tasks,1);
for T = 1:num_tasks
    predicted{T} = bsxfun(@plus,X(task_indices{T},:)*W{T},b{T});
end

end

