function y = circ_unifpdf( theta )
%CIRC_UNIFPDF circular uniform probability density function
%
%  y=CIRC_UNIFPDF(theta)  returns the circular uniform probablity density
%  at the angles in theta.
%

%  Copyright 2005-2008 Fabian Kloosterman

y = ones( size(theta) ) ./ (2*pi);
