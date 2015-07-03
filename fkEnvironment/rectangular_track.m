classdef rectangular_track < rectangular_env & linearization_base
   
    methods
        
        function obj = rectangular_track(varargin)
            obj = obj@rectangular_env(varargin{:});
        end
        
        function varargout = linearize(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.linearize( rect2polyline(obj.shape), varargin{:} );
        end
        function varargout = inv_linearize(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.inv_linearize( rect2polyline(obj.shape), varargin{:} );
        end
        function varargout = direction(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.direction( rect2polyline(obj.shape), varargin{:} );
        end
        function varargout = velocity(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.velocity( rect2polyline(obj.shape), varargin{:} );
        end
        function varargout = bin(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.bin( rect2polyline(obj.shape), varargin{:} );
        end
        function varargout = distance(obj,varargin)
            [varargout{1:nargout}]=linearize_context_polyline.distance( rect2polyline(obj.shape), varargin{:} );
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
            
            c = rectangular_track( c );
            
        end
               
    end
    
end