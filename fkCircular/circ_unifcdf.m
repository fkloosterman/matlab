function p = circ_unifcdf( theta )
%CIRC_UNIFCDF circular uniform distribution function
%
%  p=CIRC_UNIFCDF(theta) returns the circular uniform cumulative
%  distribution density at the angles in theta
%


%  Copyright 2005-2008 Fabian Kloosterman

p = limit2pi(theta) ./ (2*pi);
