function sx = cart2nsph( x )
%CART2NSPH transform cartesian coordinates to n-dimensional hyperspherical coordinates
%
%  s=CART2NSPH(x) where x is a matrix where each row is a n-dimensional
%  coordinate. Function returns a matrix where the first columsn is the
%  radial coordinate and the remaining columns are angular coordinates.
%

%  Copyright 2010 Fabian Kloosterman

% see: http://en.wikipedia.org/wiki/N-sphere#Hyperspherical_coordinates

sx = x.^2;

sx(:,1) = sqrt( sum( sx, 2 ) );

sx(:,end:-1:2) = sqrt( cumsum( sx(:,end:-1:2), 2 ) );
sx(:,2:end-1) = atan( sx(:,2:end-1) ./ x(:, 1:end-2) );
sx(:,end) = atan2( x(:,end), x(:,end-1) );
