function [r,p,U] = circ_rankcorr( x, theta )
%CIRC_RANKCORR calculate rank correlation coefficient for circular data
%
%  r=CIRC_RANKCORR(x, theta) compute the rank correlation between linear
%  variable x and circular variable theta.
%
%  [r,p]=CIRC_RANKCORR(...) returns the p-value
%
%  [r,p,U]=CIRC_RANKCORR(...) returns the statistic U.
%
%  Reference: Fisher, Statistical Analysis of Circular Data
%  (1993). Section 6.2.2

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2
  help(mfilename)
  return
end

n = numel( x );

%make sure 0<=theta<2*pi
theta = limit2pi( theta );

%rank of x
rank_x = tiedrank( x );

%circular ranks or uniform scores
rank_theta = circ_rank( theta );

%compute correlation coefficient
Tc = sum( rank_x .* cos( rank_theta ) );
Ts = sum( rank_x .* sin( rank_theta ) );

U = 24*(Tc.^2+Ts.^2)./(n.^3+n.^2);

%calculate scaling factor
if mod(n,2) == 0 %even
    a = 1 ./ (1+5*cot(pi/n).^2+4*cot(pi/n).^4);
else %odd
    a = (2*sin(pi/n).^4) ./ ( (1+cos(pi/n)).^3 );
end

r = a.*(Tc.^2+Ts.^2);


if nargout>1
  
  if n>100
    p = 1 - chi2cdf( U, 2);
  else
    %calculate p by permutation test
    niter = 5000;
    %random distribution
    rd = randdist( @(x,y) sum( x.*cos(y) ).^2 + sum(x.*sin(y)).^2 , rank_x, ...
                   niter, {rank_theta} , @(x) x( randperm( size(x,1) ), : ) );
    %test statistic
    dd = sum( rank_x.*cos(rank_theta) ).^2 + sum(rank_x.*sin(rank_theta)).^2;
    %compute p value
    p = numel(find(rd>dd))./niter;
  end
  
end

