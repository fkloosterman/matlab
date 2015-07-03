classdef linearize_context_polyline < linearize_context
    
    methods (Static=true)
        function varargout=linearize(obj,varargin)
            [varargout{1:nargout}] = obj.projection(varargin{:});
        end
        function varargout=inv_linearize(obj,varargin)
            if obj.isspline
                [varargout{1:nargout}]=linearize_context_polyline.inv_linearize_spline(obj,varargin{:});
            else
                [varargout{1:nargout}]=linearize_context_polyline.inv_linearize_polyline(obj,varargin{:});
            end
        end
        function varargout=direction(obj,varargin)
            if obj.isspline
                [varargout{1:nargout}]=linearize_context_polyline.direction_spline(obj,varargin{:});
            else
                [varargout{1:nargout}]=linearize_context_polyline.direction_polyline(obj,varargin{:});
            end
        end
        function varargout=velocity(obj,varargin)
            if obj.isspline
                [varargout{1:nargout}]=linearize_context_polyline.velocity_spline(obj,varargin{:});
            else
                [varargout{1:nargout}]=linearize_context_polyline.velocity_polyline(obj,varargin{:});
            end
        end
        function varargout=bin(obj,varargin)
            if obj.isspline
                [varargout{1:nargout}]=linearize_context_polyline.bin_spline(obj,varargin{:});
            else
                [varargout{1:nargout}]=linearize_context_polyline.bin_polyline(obj,varargin{:});
            end
        end
        function varargout=distance(obj,varargin)
            if obj.isspline
                [varargout{1:nargout}]=linearize_context_polyline.distance_spline(obj,varargin{:});
            else
                [varargout{1:nargout}]=linearize_context_polyline.distance_polyline(obj,varargin{:});
            end
        end
    end
    
    methods (Static=true,Access=protected,Hidden=true)
        
        %POLYLINE METHODS
        function xy = inv_linearize_polyline(obj,p,dist)
            
            nodes = fullnodes(obj);
            
            %compute length
            l = cumsum( [0; sqrt( sum( diff( nodes ).^2, 2 ) )] );
            
            %interpolate to find x,y coordinates
            xy = interp1( l, nodes, p, 'linear', 'extrap' );
            
            %apply distance to polyline if requested
            if nargin>2
                
                %compute normal
                d = floor( interp1( l, [1:(size(nodes,1)-1) (size(nodes,1)-1)]', p, 'linear', 'extrap') );
                d = atan2( nodes(d+1 , 2) - nodes(d, 2), nodes(d+1, 1) - nodes(d, 1) ) + 0.5*pi;
                
                %add offsets to x,y coordinates
                xy = xy + [dist.*cos(d) dist.*sin(d)];
                
            end
        end
        function d = direction_polyline(obj,p)
            nodes = fullnodes(obj);
            %compute length
            l = cumsum( [0; sqrt( sum( diff( obj.nodes ).^2, 2 ) )] );
            
            %compute direction
            d = floor( interp1( l, [1:(size(nodes,1)-1) (size(nodes,1)-1)]', p, 'linear', 'extrap' ) );
            d = atan2( nodes(d+1 , 2) - nodes(d, 2), nodes(d+1, 1) - nodes(d, 1) );

        end
        function vel = velocity_polyline(obj,p,dt)
            %unwrap linear position if polyline is closed
            if obj.isclosed
                factor = 2*pi./obj.length;
                p = unwrap( p.*factor )./factor;
            end
            
            %compute gradient
            if nargin>2
                vel = gradient( p, dt );
            else
                vel = gradient( p, 1./30 );
            end
        end
        function [bins,nbins,binsize] = bin_polyline(c,binsize)
            nbins = ceil( c.length./binsize );
            bins = linspace(0,c.length,nbins+1);
            binsize = c.length ./ nbins;
        end
        function d = distance_polyline(obj,a,b)
            if obj.isclosed
                tmp = [b-a obj.length-b+a];
                [mi,mi] = min(tmp,[],2);
                %d = min( min(a,b) + obj.length-max(a,b), abs(a-b) );
                d = tmp(sub2ind( size(tmp), 1:size(tmp,1), mi ) );
            else
                d = b-a;
            end
        end
        
        %SPLINE METHODS
        function xy = inv_linearize_spline(obj,p,dist)
            nodes = fullnodes(obj);
            %oversample spline
            s = cscvn( nodes' );
            t = linspace( s.breaks(1), s.breaks(end), numel(s.breaks).*100 );
            sxy = fnval( s, t )';
            
            %compute length
            l = cumsum( [0 ; sqrt( sum( diff( sxy ).^2, 2 ) ) ] );
            
            %interpolate to find x,y coordinates
            xy = interp1( l, sxy, p, 'linear', 'extrap' );
            
            %apply distance to spline if requested
            if nargin>2
                %compute derivative of spline
                sder = fnder( s );
                d = fnval( sder, interp1( l, t(:), p, 'linear', 'extrap' ) )';
                %compute normal
                d = atan2( d(:,2), d(:,1) ) + 0.5*pi;
                %add offsets to x,y coordinates
                xy = xy + [dist.*cos(d) dist.*sin(d)];
            end
        end
        function d = direction_spline(obj,p)
            nodes = fullnodes(obj);
            
            %oversample spline
            s = cscvn( nodes' );
            t = linspace( s.breaks(1), s.breaks(end), numel(s.breaks).*100 );
            sxy = fnval( s, t )';
            
            %compute length
            l = cumsum( [0 ; sqrt( sum( diff( sxy ).^2, 2 ) ) ] ); 
            
            %spline derivative
            sder = fnder( s );
            
            %compute direction
            d = fnval( sder, interp1( l, t(:), p ) )';
            d = atan2( d(:,2), d(:,1) );
        end
        function vel = velocity_spline(obj,p,dt)
            %unwrap linear position if spline is closed
            if obj.isclosed
                factor = 2*pi./obj.length;
                p = unwrap( factor.*p )./factor;
            end
            
            %compute gradient
            if nargin>3
                vel = gradient( p, dt );
            else
                vel = gradient( p, 1./30 );
            end
        end
        function [bins,nbins,binsize] = bin_spline(c,binsize)
            nbins = ceil( c.length./binsize );
            bins = linspace(0,c.length,nbins+1);
            binsize = c.length ./ nbins;
        end
        function d = distance_spline(obj,a,b)
            if obj.isclosed
                d = min( min(a,b) + obj.length-max(a,b), abs(a-b) );
            else
                d = abs(a-b);
            end
        end
        
    end
    
end