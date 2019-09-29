function [ lambdas ] = nuclear_lambda( X, Y, task_indices, init_loss_args )

[NAll D] = size(X);
T = length(Y);

%Check arguments
n = cellfun(@length, Y);
n2 = cellfun(@length, task_indices);
if max(abs(n - n2)) > 0; throw(MException('ArgumentException', 'Y and task index length mismatch')); end;
check_valid_indices( task_indices, NAll);
if ~isempty(init_loss_args) && mod(length(init_loss_args), 2) == 1; throw(MException('ArgumentException', 'Incorrect initialization arguments')); end;

%Defaults
groupId = {1:T};
normalize = '';
xscale = 'Std';
yscale = 'none';
%Parse
if ~isempty(init_loss_args)
    for i = 1 : 2 : length(init_loss_args)
        switch init_loss_args{i}
            case 'normalize'
                normalize = init_loss_args{i + 1};
            case 'groups'
                groupId = init_loss_args{i + 1};
                [a b] = size(groupId);
                if b > a; groupId = groupId'; end;
            case 'xscale'
                xscale = init_loss_args{i + 1};
            case 'yscale'
                yscale = init_loss_args{i + 1};
        end
    end
    
    check_valid_indices( groupId, T);
    present = zeros(T, 1);
    for i = 1 : length(groupId)
        present(groupId{i}) = present(groupId{i}) + 1;
    end
    if min(present) == 0; throw(MException('ArgumentException', 'Not all tasks are represented')); end;
    if max(present) > 1; throw(MException('ArgumentException', 'Task is represented one or more times')); end;
end

g = length(groupId);

%Should we perform full normalization?
needsNormalization = false;
groupMean = zeros(g, D);
groupScale = zeros(g, D);
if strcmp(normalize, 'full')
    [X, mu, scale] = normalize_features(X, xscale);
    groupMean = repmat(mu, g, 1);
    groupScale = repmat(scale, g, 1);
else
    needsNormalization = true;
end

%Reindex tasks
gid = [0; cumsum(cellfun(@length, groupId))];
p = zeros(T, 1);
q = zeros(T, 1);
for t = 1 : g
    p(groupId{t}) = (gid(t)+1):gid(t+1);
    q((gid(t)+1):gid(t+1)) = groupId{t};
end
Y = Y(q);
task_indices = task_indices(q);
N = cellfun(@length, task_indices)';

%Separate out X
XFull = cell(g, 1);
u = cell(g, 1);
TaskGroup = zeros(T, 1);
for t = 1 : g
    u{t} = cell_union(task_indices((gid(t) + 1):gid(t+1)), NAll);
    TaskGroup((gid(t)+1):gid(t+1)) = t;
    v = X(u{t}, :);
    if needsNormalization
        [v, groupMean(t, :), groupScale(t,:) ] = normalize_features(v, xscale);
    end
    XFull{t} = v;
end

%Find left out points (and reindex them)
new_id = cell(T, 1);
for i = 1 : T
    all = zeros(NAll, 1);
    all(u{TaskGroup(i)}) = 1:length(u{TaskGroup(i)});
    new_id{i} = all(task_indices{i});
end

%Compute W
W = zeros(D, T);
for t = 1 : g
    ind = (gid(t)+1):gid(t+1);
    for i = ind
        [Ytmp] = normalize_response(Y{i}, yscale);
        myX = XFull{t}(new_id{i}, :);
        myX = bsxfun(@minus, myX, mean(myX));
        C = myX*myX';
        C = C + sum(diag(C))*eye(length(C))/(1e6);
        W(:, i) = myX'*(C\Ytmp);
    end
end

nlambda = 100;
s = svd(W);
smax = nlambda*max(s);
delta = (1e-3)^(1/(nlambda - 1));
lambdas = smax*(delta.^(0:1:(nlambda - 1)));

end

