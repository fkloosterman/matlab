classdef linearize_context_circle < linearize_context
    
    methods (Static=true)
        
        function varargout = linearize(c,xy)
%             [theta, rho] = cart2pol( xy(:,1)-c.center(1), xy(:,2)-c.center(2) );
%             theta = limit2pi(theta).*c.radius;
%             rho = rho - c.radius;
            [varargout{1:nargout}] = projection( c, xy );
        end
        
        function xy = inv_linearize(c,linpos,delta)
            %convert linearized positions to x,y coordinates
            if nargin<3
                delta = 0;
            elseif ~isnumeric(delta) || ~isscalar(delta)
                error('linearize_context_circle:inv_linearize:invalidArgument', 'Invalid delta')
            end
            
            [x,y] = pol2cart( linpos./c.radius, c.radius+delta );
            
            xy = [x+c.center(1) y+c.center(2)];
        end
        
        function d = direction(c,linpos)
            d = linpos ./ c.radius + 0.5*pi;
        end
        
        function vel = velocity(c,linpos,dt)
            %unwrap linearized position
            linpos = unwrap( linpos./c.radius ).*c.radius;
            
            %compute gradient
            if nargin>2
                vel = gradient( linpos, dt );
            else
                vel = gradient( linpos, 1./30 );
            end
        end
        
        function [bins,nbins,binsize] = bin(c,binsize)
            nbins = ceil( c.length./binsize );
            bins = linspace(0,c.length,nbins+1);
            binsize = c.length ./ nbins;
        end
        
        function d = distance(c,a,b)
            d = circ_diff( a./c.radius, b./c.radius, 1 ).*c.radius;
        end
        
    end
    
end