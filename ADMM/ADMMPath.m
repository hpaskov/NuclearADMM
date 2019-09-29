function [W_path,b_path] = ADMMPath(X, Y, task_indices, lambdas, init_loss, init_reg, prox_loss, prox_reg, init_loss_args, init_reg_args, finalize, update_rho)

Max_Iterations = 2000;
Tol = 1e-6;

%Allow ADMM step size parameter tuning by default
if nargin < 12;	update_rho = true; end

num_tasks = length(task_indices);
num_features = size(X,2);
num_lambda = length(lambdas);

W_path = cell(num_tasks,1);
b_path = cell(num_tasks,1);

for q = 1:num_tasks
    W_path{q} = zeros(num_features,num_lambda);
    b_path{q} = zeros(1,num_lambda);
end

myVars = ADMMVars(num_features, num_tasks);

[loss_params, rho_org, p, q] = init_loss(X, Y, task_indices, lambdas, init_loss_args);
reg_params = init_reg(X, Y, task_indices, lambdas, init_reg_args, p, q);
rho = rho_org;
for K = 1:num_lambda
    fprintf('(%g) ', lambdas(K));
    tic;
    count = 0;
    r = Inf;
    s = Inf;
	
    while (count < Max_Iterations && (r > Tol || s > Tol))
		myVars.SaveZ();
        prox_loss(myVars, rho, lambdas(K),loss_params);
        prox_reg(myVars, rho, lambdas(K), reg_params);
		
        [r s] = myVars.Update(rho);
        
        %Performs a binary search to near optimal step parameter
        if (count > 10 && update_rho)
            if r > 20*s
                rho = 1.5*rho;
            elseif s > 20*r
                rho = 0.5*rho;
            end
        end
        
        count = count + 1;
    end
    time = toc;
    fprintf('%gs ', time);
	[W, b] = finalize(myVars, init_loss_args, loss_params, p, q);
    
    for t = 1:num_tasks
        W_path{t}(:, K) = W(:, t);
        b_path{t}(K) = b(t);
    end
end
fprintf('\n');
end






