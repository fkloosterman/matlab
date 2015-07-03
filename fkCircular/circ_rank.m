function g = circ_rank(theta)
%CIRC_RANK circular rank or uniform score (with tie correction)
%
%  g=CIRC_RANK(theta) compute circular rank of a vector of angles. NaNs
%  are excluded.
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

%exclude NaNs
theta = theta( ~isnan(theta) );

n = numel(theta);

%initialize output
g = [];

%if no valid data, return
if n==0 
  return
end

%compute tied rank
r = tiedrank( theta );
%convert to circular ranks
g = 2*pi*r ./ n;
