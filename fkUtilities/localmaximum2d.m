function [x,y,z] = localmaximum2d(varargin)
%LOCALMAXIMUM2D find local maxima in matrix
%
%  [ix,iy]=LOCALMAXIMUM2D(m) find x (row) and y (column) indices of
%  the local maxima in the matrix m. NaNs are replace by -Inf.
%
%  [ix,iy,z]=LOCALMAXIMUM2D(m) also returns the values at the maxima
%
%  [x,y,z]=LOCALMAXIMUM2D(mx,my,m) where mx and my are vectors that
%  specify the x (row) and y (column) coordinates of matrix m. The
%  location of the maxima are returned in these coordinates.
%
%  [...]=LOCALMAXIMUM2D(...,param1,val1,...) specify optional
%  parmater/value pairs. Valid parameters are:
%   threshold - minimum peak height
%   mindist - minimum distance between peaks
%

%  Copyright 2008-2008 Fabian Kloosterman

options = struct('threshold', -Inf, 'mindist', 0);
[options, other] = parseArgs(varargin, options);

narg = numel(other);

if narg<1
    help(mfilename)
    return
elseif narg==1
    m = other{1};
    mx = 1:size(m,1);
    my = 1:size(m,2);
elseif narg==3
    [mx, my, m] = other{:};
else
    error('localmaximum2d:invalidArgument', ['Invalid number of ' ...
                        'arguments'])
end

if ndims(m)~=2 || ~isnumeric(m)
    error('localmaximum2d:invalidArgument', 'Invalid matrix')
end

[sx, sy] = size(m);

if ~isnumeric(mx) || ~isnumeric(my) || ~isvector(mx) || ~isvector(my) ...
        || length(mx)~=sx || length(my)~=sy
    error('localmaximum2d:invalidArgument', ['Invalid x or y ' ...
                        'vectors'])
end

mcopy = m;

%remove NaNs
m( isnan(m) ) = -Inf;

%find peaks and label them
m = bwlabel( imregionalmax( m ) );

npeaks = max( m(:) );

x = NaN(npeaks,1);
y = NaN(npeaks,1);
z = NaN(npeaks,1);

%find peak indices and value
xi = cell(npeaks,1);
yi = cell(npeaks,1);
for k=1:npeaks
    [xi{k}, yi{k}] = ind2sub( size(m), find( m==k ) );
    tmp = ndmedian( [xi{k}(:) yi{k}(:)] , [], 1);
    x(k) = mx(tmp(1));
    y(k) = my(tmp(2));
    z(k) = mcopy( tmp(1), tmp(2) );
end

%apply threshold
invalid = z<options.threshold;
x(invalid)=[];
y(invalid)=[];
z(invalid)=[];

%apply minimum distance
if options.mindist>0

    %sort vector
    [zsort, si] = sort( z );
    %find indices to inverse sort
    [si_inv, si_inv] = sort( si );
    
    %compute distance between peaks
    d = sqrt( bsxfun( @minus, x(si), x(si)' ).^2 + bsxfun( @minus, y(si), y(si)' ).^2 );
    
    %for all peak pairs with distance < minimum, throw out the
    %lowest one
    invalid = sum( tril( d<options.mindist, -1 ) ) > 0;
    invalid = invalid(si_inv);
    
    x(invalid)=[];
    y(invalid)=[];
    z(invalid)=[];    
    
end