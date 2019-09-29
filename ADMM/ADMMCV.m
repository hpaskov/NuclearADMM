function [ predicted, foldID ] = ADMMCV(foldID, method, nfolds, X, Y, task_indices, lambdas, init_loss, init_reg, prox_loss, prox_reg, init_loss_args, init_reg_args, finalize, update_rho)

num_tasks = length(task_indices);
num_lambda = length(lambdas);

predicted = cell(num_tasks,1);

for p = 1:num_tasks
    nrows = size(Y{p},1);
    predicted{p} = zeros(nrows,num_lambda);
end

%if foldID is empty select cross-val fold ids
if (isempty(foldID)) 
    foldID = cell(num_tasks,1);
    
    for r = 1:num_tasks
        nrows = size(Y{p},1); 
        foldID{r} = zeros(nrows,1);
    end
    
   if(strcmp(method, 'full'))
        nAll = size(X,1);
        splits = repmat(1:nfolds, 1, ceil(nAll/nfolds));
        splits = splits(randperm(length(splits)));
        splits = splits(1:nAll);
        
		num = 1:nAll;
        for K1 = 1:nfolds
            ind1 = num(splits == K1);
            for p = 1:num_tasks
                ind_intersect = intersect(ind1,task_indices{p}); 
                foldID{p}(ind_intersect) = K1;
            end
        end
    else
    for t = 1:num_tasks
         nrows = size(Y{t},1); 
         splits = repmat(1:nfolds, 1, ceil(nrows/nfolds));
         splits = splits(randperm(length(splits)));
         splits = splits(1:nrows);
         foldID{t} = splits;
    end

    end
end

%Iterate through folds, split into training and held-out sets and predict
for K = 1:nfolds
    fprintf('Fold %d\n', K)
    train_Y = cell(num_tasks,1);
    train_task_indices = cell(num_tasks,1);
    test_task_indices = cell(num_tasks,1);

    for j = 1:num_tasks
        ind = foldID{j} == K;
        train_Y{j} = Y{j}(~ind);
        train_task_indices{j} = task_indices{j}(~ind,:);
        test_task_indices{j} = task_indices{j}(ind,:);
    end
    
    [W_path,b_path] = ADMMPath(X, train_Y, train_task_indices, lambdas, init_loss, init_reg, prox_loss, prox_reg, init_loss_args, init_reg_args, finalize, update_rho);
    temp_predicted = Predict(X,test_task_indices,W_path,b_path);
        
    for z = 1:num_tasks
        predicted{z}(foldID{z} == K,:) = temp_predicted{z};
    end

end
end


