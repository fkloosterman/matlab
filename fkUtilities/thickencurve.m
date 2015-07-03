function [s, ishole]=thickencurve(xy,w,varargin)
%THICKENCURVE create curve outline
%
%  outlines=THICKENCURVE(xy,width) create an outline for the curve
%  defined by the x,y coordinates in the nx2 matrix xy. The width
%  of the outline is measured from the curve to the outline on
%  either side. xy can be a cell array of curves and width can be a vector.
%  The algorithm first creates a 100-by-100 grid covering the curves and
%  computes the distances between each grid node and the curve(s). Next,
%  contourc is used to find the iso-distance lines. The function returns a
%  cell array with for each width a struct array containing the vertices of
%  all outlines and whether or not the outline is a hole.
%
%  outlines=THICKENCURVE(xy,width,'size', [ix iy]) optionally
%  specifies the x and y size of the grid used internally. Larger sizes
%  increase smoothness and detail of outlines, but also increase
%  computation time and memory overhead.
%

%  Copyright 2008-2009 Fabian Kloosterman


%% check input arguments
if nargin<2
    help(mfilename)
    return
end

if ~iscell( xy )
    xy = {xy};
end

if any( cellfun( @(x) ~isnumeric(x) || ndims(x)~=2 || size(x,2)~=2 || size(x,1)<2, xy ) )
    error('thickencurve:invalidArgument', 'Invalid curve coordinates')
end

if ~isnumeric(w) || ~isvector(w) || any(w<=0)
    error('thickencurve:invalidArgument', 'Invalid widths')
elseif numel(unique(w))~=numel(w)
    error('thickencurve:invalidArgument', 'Need vector of unique widths')
end

options=struct('size', [100 100]);
options=parseArgs(varargin,options);


%% construct grid
ma = cellfun( @max, xy, 'UniformOutput', false );
ma = max( vertcat( ma{:} ), [], 1 );
mi = cellfun( @min, xy, 'UniformOutput', false );
mi = min( vertcat( mi{:} ), [], 1 );

mw = max(w);

xv = linspace( mi(1)-1.5*mw, ma(1)+1.5*mw, options.size(1) )';
yv = linspace( mi(2)-1.5*mw, ma(2)+1.5*mw, options.size(end) );

[xx,yy] = ndgrid( xv, yv );

%% compute distance between curve and grid
d = Inf;
for k=1:numel(xy)
    [tmp,tmp] = point2polyline( xy{k}, [xx(:) yy(:)] , {'normal', 'normal'} );
    d = min( d, abs(tmp) );
end

%% find iso-distance lines
d = reshape( d, size(xx) );

if isscalar(w)
    z = contourc( xv, yv, d', [w w] );
else
    z = contourc( xv, yv, d', w );
end

%% construct output
if isempty(z)
    s = {};
    ishole = [];
    return
end

idx = 1;
nz = size(z,2);
s = repmat( {struct('vertices', {}, 'ishole', {})}, numel(w), 1 );
ishole = [];
xy = vertcat( xy{:} );
while idx<nz
    
    npairs = z(2,idx);
    s{z(1,idx)==w}(end+1) = struct( 'vertices', z(:,idx + (1:npairs))', 'ishole', ~any(inpoly(xy,z(:,idx + (1:npairs))')) );
    
    idx = idx + npairs + 1;
    
end
