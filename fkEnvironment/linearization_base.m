classdef linearization_base < handle
    
    methods (Abstract=true)
        linearize(obj)
        inv_linearize(obj)
        direction(obj)
        velocity(obj)
        bin(obj)
        lineardistance(obj)
    end
    
end