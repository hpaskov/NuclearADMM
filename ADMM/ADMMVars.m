classdef ADMMVars < handle
    % This class contains internal variables for the ADMM solver
    properties
        W;
        Z;
        E;
        b;
        Zold;
    end
    
    methods
        function cl = ADMMVars(D, T)
            cl.W = zeros(D, T);
            cl.Z = zeros(D, T);
            cl.E = zeros(D, T);
            cl.b = zeros(1, T);
            cl.Zold = [];
        end
        
        function SaveZ(cl)
            cl.Zold = cl.Z;
        end
        
        function [ r s ] = Update(cl, rho) 
            [r s] = mexUpdateHelper(cl.W, cl.Z, cl.E, cl.Zold, rho);
        end
    end
    
end

