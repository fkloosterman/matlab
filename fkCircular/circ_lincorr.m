function [r, a] = circ_lincorr( x, theta )
%CIRC_LINCORR find best linear correlation
%
%  [r,th]=CIRC_LINCORR(x,theta) finds the best linear correlation between
%  a linear variable x and a circular variable theta, by rotating the
%  circular variable. The function returns the largest correlation
%  coefficient and the rotation th that produces the largest
%  correlation.
%

%  Copyright 2005-2008 Fabian Kloosterman

x = x(:);
theta = limit2pi(theta(:));

valid = find( ~isnan(x) & ~isnan(theta) );
n = numel(valid);

c = @(phi) corr( x(valid), limit2pi( repmat(theta(valid),1,numel(phi)) - repmat(phi(:)', n, 1) ) );

[ev, ex] = max( abs( c( theta(valid) ) ) ); %#ok

r = c( theta(valid(ex)) );
a = theta(valid(ex));
