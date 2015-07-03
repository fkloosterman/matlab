classdef shape_env < env_base
    
    
    properties (SetAccess=protected, Hidden=true)
        shape
    end
    
    properties (Dependent=true, SetAccess=protected)
        length
    end
    
    methods
        
        function obj = shape_env(varargin)
            if nargin==1 && isa( varargin{1}, 'shapes.shape_base' )
                obj.shape = varargin{1};
            else
                error('shape_env:shape_env:invalidArgument', 'Invalid shape')
            end
            obj.name = obj.shape.name;
            addlistener( obj, 'name', 'PostSet', @obj.sync_shape_name );
            addlistener( obj.shape, 'name', 'PostSet', @obj.sync_obj_name );
        end
        
        function sync_shape_name(obj,src,ev)
            obj.shape.name = obj.name;
        end
        function sync_obj_name(obj,src,ev)
            obj.name = obj.shape.name;
        end
        
        function val = get.length(obj)
            val = obj.shape.length;
        end
        
        function h = plot(obj, varargin)
            h = obj.shape.plot(varargin{:});
        end
        
        function s = tostruct(obj)
            s = struct( 'type', class(obj), 'info', obj.shape.tostruct() );
        end
        
        function transform(obj,T)
            obj.shape.transform(T);
        end
        
        function edit(obj,varargin)
            define_shape(obj.shape, varargin{:});
        end
        
        function d=distance(obj,xy)
           d = obj.shape.distance(xy); 
        end
        
    end
    
    methods (Static=true, Abstract=true)
        
        obj = define(varargin)
        
    end
    
    methods (Static=true)
       
        function obj = fromstruct(s)
            
            if ~isstruct(s) || ~isscalar(s) || ~all(isfield(s,{'type','info'}))
                error('shape_env:fromstruct:invalidArgument', 'Invalid struct')
            end
            
            obj = eval( [ s.type '( shapes.shape_base.fromstruct( s.info ) );'] );
            
        end
                
    end
    
end