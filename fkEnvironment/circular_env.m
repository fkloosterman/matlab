classdef circular_env < shape_env
    
    properties (Dependent=true)
        center
        radius
    end
    
    methods
        
        function obj=circular_env(varargin)
            
            if nargin==1 && isa( varargin{1}, 'shapes.shape_circle' )
                shape = varargin{1};
            else
                shape = shapes.shape_circle(varargin{:});
            end
            
            obj = obj@shape_env( shape );
            
        end
        
        function val=get.center(obj)
            val=obj.shape.center;
        end
        function set.center(obj,val)
            obj.shape.center = val;
        end
        function val=get.radius(obj)
            val=obj.shape.radius;
        end
        function set.radius(obj,val)
            obj.shape.radius = val;
        end

    end
    
    methods (Static=true)
       
        function c = define(varargin)
            
            options = struct('position', []);
            [options,~,remainder] = parseArgs(varargin,options);
            
            if isempty(options.position)
                c = 'circle';
            else
                maxpos = nanmax( options.position );
                minpos = nanmin( options.position );
                c = shapes.shape_circle( (maxpos + minpos )./2, max( (maxpos-minpos)./2 ) );
            end
            
            c = define_shape( c, remainder{:} );
            
            c = circular_env( c );
            
        end
        
    end
    
end