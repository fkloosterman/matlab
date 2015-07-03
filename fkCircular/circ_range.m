function w = circ_range( theta, dim )
%CIRC_RANGE circular range
%
%  w=CIRC_RANGE(theta) find smallest arc that contains all angles.
%
%  w=CIRC_RANGE(theta, dim) find smallest arc along dimension dim
%  (default = 1).
%


%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

%default to dimension = 1
if nargin<2 || isempty(dim)
  dim = 1;
elseif dim>ndims(theta)
  error('circ_range:invalidDimension', 'Invalid dimension')
end

%sort theta values
theta = sort( theta, dim );

%calculate ordinary difference
T = diff( theta, 1, dim );

%append difference between first and last element
indx1 = repmat( {':'} , 1, ndims( theta ) );
indx2 = indx1;
indx3 = indx1;

indx1{dim} = size(T,dim)+1;
indx2{dim} = size(theta,dim);
indx3{dim} = 1;

T( indx1{:} ) = 2*pi - theta(indx2{:}) + theta(indx3{:});

%compute circular range
w = 2*pi - max( T, [], dim );

%print result, if no output arguments
if nargout==0   
    fprintf('circular range = %.2f\n', w);
end
