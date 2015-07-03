classdef linearize_context
    
    methods (Static=true,Abstract=true)
        linearize
        inv_linearize
        direction
        velocity
        bin
        distance
    end
    
end