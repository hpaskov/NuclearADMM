function [ ret_obj, rho, p, q ] = init_regression( X, Y, task_indices, lambdas, init_loss_args )
%Initializes regression proximal operator

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
missing = cell(T, 1);
for i = 1 : T
    all = zeros(NAll, 1);
    all(u{TaskGroup(i)}) = 1:length(u{TaskGroup(i)});
    missing{i} = all(setdiff(u{TaskGroup(i)}, task_indices{i}));
end

%Compute R
R = zeros(D, T);
Ytmp = zeros(NAll, T);
YMean = zeros(1, T);
YScale = zeros(1, T);
for t = 1 : g
    ind = (gid(t)+1):gid(t+1);
    for i = ind
        [Ytmp(task_indices{i}, i), YMean(i), YScale(i)] = normalize_response(Y{i}, yscale);
    end
    R(:, ind) = XFull{t}'*Ytmp(u{t},ind);
end

%Compute SVD
U = cell(g, 1);
S = cell(g, 1);
V = cell(g, 1);
rho = 0;
for t = 1:g
    [U{t}, S{t}, V{t}] = svd(XFull{t}, 'econ');
    S{t} = diag(S{t});
    U{t} = U{t}';
    smallest = min(N((gid(t)+1):gid(t+1)));
    rho = rho + mean(S{t})/smallest;
end
rho = rho/g;

G3 = init_regression_helper( TaskGroup, U, S, missing, N, rho);

ret_obj = regression_args(gid, TaskGroup, N, missing, R, U, S, V, G3, groupMean, groupScale, YMean, YScale, rho);

end