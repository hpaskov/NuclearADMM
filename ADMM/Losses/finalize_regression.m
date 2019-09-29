function [W_final, b_final] = finalize_regression(vars, init_loss_args, lp, p, q)
%Finalizes output of regression proximal operator

b_final =  zeros(1, size(vars.W, 2));
for i = 1 : length(lp.TaskGroup)
    b_final(i) = sum(lp.epsilon{i})/size(lp.U{lp.TaskGroup(i)}, 1);
end

D = lp.groupScale(lp.TaskGroup, :)';
W_final = bsxfun(@times, (vars.W)./D, lp.YScale);

b_final = lp.YMean + b_final.*(lp.YScale) - sum(W_final.*(lp.groupMean(lp.TaskGroup, :)')); 

W_final = W_final(:, p);
b_final = b_final(:, p);

end

