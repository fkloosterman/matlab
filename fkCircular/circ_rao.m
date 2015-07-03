function [p, L] = circ_rao( theta )
%CIRC_RAO Rao's test of equal spacing
%
%  [p,l]=CIRC_RAO(theta) Rao's test of equal spacing
%

%  Copyright 2005-2008 Fabian Kloosterman

theta = sort( limit2pi( theta ) );

n = numel(theta);

d = [diff(theta) theta(1)-theta(end)+2*pi];

L = 0.5.*sum(abs(d-2*pi/n));

p = 0; %STILL TO DO...
