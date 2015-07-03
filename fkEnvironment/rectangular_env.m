classdef rectangular_env < shape_env
    
    properties (Dependent=true)
        center
        width
        height
        rotation
    end
    
    methods
        
        function obj=rectangular_env(varargin)
            if nargin==1 && isa( varargin{1}, 'shapes.shape_rectangle' )
                shape = varargin{1};
            else
                shape = shapes.shape_rectangle(varargin{:});
            end
            
            obj = obj@shape_env( shape );
        end
        
        function val=get.center(obj)
            val=obj.shape.center;
        end
        function set.center(obj,val)
            obj.shape.center = val;
        end
        function val=get.width(obj)
            val=obj.shape.width;
        end
        function set.width(obj,val)
            obj.shape.width = val;
        end
        function val=get.height(obj)
            val=obj.shape.height;
        end
        function set.height(obj,val)
            obj.shape.height = val;
        end
        function val=get.rotation(obj)
            val=obj.shape.rotation;
        end
        function set.rotation(obj,val)
            obj.shape.rotation = val;
        end
        
    end

    methods (Static=true)
       
        function c = define(varargin)
            
            options = struct('position', []);
            [options,~,remainder] = parseArgs(varargin,options);
            
            if isempty(options.position)
                c = 'rectangle';
            else
                maxpos = nanmax( options.position );
                minpos = nanmin( options.position );
                c = shapes.shape_rectangle( (maxpos + minpos )./2, maxpos(1)-minpos(1), maxpos(2)-minpos(2), 0);
            end
            
            c = define_shape( c, remainder{:} );
            
            c = rectangular_env( c );
            
        end
               
    end
    
end