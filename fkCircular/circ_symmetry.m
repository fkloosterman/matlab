function p = circ_symmetry( theta, m )
%CIRC_SYMMETRY test for symmetry around median
%
%  p=CIRC_SYMMETRY(theta) tests if circular variable theta is distributed
%  symmetrically around its median and return the p-value.
%
%  p=CIRC_SYMMETRY(theta, m) tests if theta is symmetrically distributed
%  around the angle m.
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

%default to median
if nargin<2 || isempty(m)
    m = circ_median( theta );
end


%symmetry test
phi = limit2pi(theta - m, -pi);

phi( phi==0 ) = [];
n = numel(phi);

ri = tiedrank( abs(phi) );

wp = sum( ri( phi>0 ) );
wn = sum( ri( phi<0 ) ); %#ok

m = n*(n+1)/4;
s = sqrt( n.*(n+1)*(2.*n+1)./24 );

w = abs( wp - m ) ./ s;

p = 2.*(1-normcdf( w, 0, 1 ));
