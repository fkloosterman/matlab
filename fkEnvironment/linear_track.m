classdef linear_track < linear_env & linearization_base
    
    methods
        
        function obj=linear_track(varargin)
            obj = obj@linear_env(varargin{:});            
        end
        
        function varargout = linearize(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.linearize( obj.shape, varargin{:} );
        end
        function varargout = inv_linearize(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.inv_linearize( obj.shape, varargin{:} );
        end
        function varargout = direction(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.direction( obj.shape, varargin{:} );
        end
        function varargout = velocity(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.velocity( obj.shape, varargin{:} );
        end
        function varargout = bin(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.bin( obj.shape, varargin{:} );
        end
        function varargout = lineardistance(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.distance( obj.shape, varargin{:} );
        end
    
    end
    
    methods (Static=true)
       
        function c = define(varargin)
            
            options = struct('position', []);
            [~,~,remainder] = parseArgs(varargin,options);
                        
            c = define_shape( 'polyline', remainder{:} );
            
            c = linear_track( c );
            
        end
        
    end
end