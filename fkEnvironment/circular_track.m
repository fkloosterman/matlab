classdef circular_track < circular_env & linearization_base
   
    methods
        
        function obj = circular_track(varargin)
            obj = obj@circular_env(varargin{:});
        end
        
        function varargout = linearize(obj,varargin)
            [varargout{1:nargout}]=linearize_context_circle.linearize( obj.shape, varargin{:} );
        end
        function varargout = inv_linearize(obj,varargin)
            [varargout{1:nargout}]=linearize_context_circle.inv_linearize( obj.shape, varargin{:} );
        end
        function varargout = direction(obj,varargin)
            [varargout{1:nargout}]=linearize_context_circle.direction( obj.shape, varargin{:} );
        end
        function varargout = velocity(obj,varargin)
            [varargout{1:nargout}]=linearize_context_circle.velocity( obj.shape, varargin{:} );
        end
        function varargout = bin(obj,varargin)
            [varargout{1:nargout}]=linearize_context_circle.bin( obj.shape, varargin{:} );
        end
        function varargout = lineardistance(obj,varargin)
            [varargout{1:nargout}]=linearize_context_circle.distance( obj.shape, varargin{:} );
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
            
            c = circular_track( c );
            
        end
        
    end
    
end