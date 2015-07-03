classdef linear_env < shape_env
    
    properties (Dependent=true)
        nodes
        isclosed
        isspline
    end
    
    methods
        
        function obj=linear_env(varargin)
            if nargin==1 && isa( varargin{1}, 'shapes.shape_polyline' )
                shape = varargin{1};
            else
                shape = shapes.shape_polyline(varargin{:});
            end
            
            obj = obj@shape_env( shape );
        end
        
        function val=get.nodes(obj)
            val=obj.shape.nodes;
        end
        function set.nodes(obj,val)
            obj.shape.nodes = val;
        end
        function val=get.isclosed(obj)
            val=obj.shape.isclosed;
        end
        function set.isclosed(obj,val)
            obj.shape.isclosed = val;
        end
        function val=get.isspline(obj)
            val=obj.shape.isspline;
        end
        function set.isspline(obj,val)
            obj.shape.isspline = val;
        end
        
    end
    
    methods (Static=true)
       
        function c = define(varargin)
            
            options = struct('position', []);
            [~,~,remainder] = parseArgs(varargin,options);
                        
            c = define_shape( 'polyline', remainder{:} );
            
            c = linear_env( c );
            
        end
        
    end
    
end