classdef env_base < handle
    
    properties (SetObservable=true)
        name
    end
    
    methods (Abstract=true)
        plot(obj)
    end
    
    methods
        
        function set.name(obj,val)
            if ~ischar(val)
                error('env_base:set_name:invalidValue', 'Invalid name')
            end
            obj.name = val;
        end

        function s=tostruct(obj)
            s = struct('type', class(obj));
        end
        
    end
    
    methods (Static=true)
        function obj=fromstruct(s)
           if ~isstruct(s) || ~all(isfield(s, {'type','info'})) || ~isscalar(s)
               error('env_base:fromstruct:invalidArgument', 'Invalid structure')
           end
           obj = eval( [s.type '.fromstruct( s );'] );
        end
    end
    
end