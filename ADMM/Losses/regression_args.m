classdef regression_args < handle
    %Internal class regression proximal operator arguments
    properties
        gid;
        TaskGroup;
        N;
        Nmissing;
        missing;
        missing32;
        R;
        U;
        S;
        V;
        G3;
        rho;
        groupMean;
        groupScale;
        YMean;
        YScale;
        epsilon;
    end
    
    methods
        function ra = regression_args(gid, TaskGroup, N, missing, R, U, S, V, G3, groupMean, groupScale, YMean, YScale, rho)
            ra.gid = gid;
            ra.TaskGroup = TaskGroup;
            ra.N = N;
            ra.Nmissing = cellfun(@length, missing);
            ra.missing = missing;
            ra.missing32  = cell(length(missing));
            for i = 1 : length(missing)
                ra.missing32{i} = int32(missing{i}) - 1;
            end
            ra.R = R;
            ra.U = U;
            ra.S = S;
            ra.V = V;
            ra.G3 = G3;
            ra.groupMean = groupMean;
            ra.groupScale = groupScale;
            ra.YMean = YMean;
            ra.YScale = YScale;
            ra.rho = rho;
            ra.epsilon = cell(length(TaskGroup), 1);
            for i = 1 : length(ra.epsilon)
                ra.epsilon{i} = zeros(length(missing{i}),1);
            end
        end
    end
    
end

