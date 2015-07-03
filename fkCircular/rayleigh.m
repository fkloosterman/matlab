function [p, S] = rayleigh( theta, dim )
%RAYLEIGH rayleigh test for uniformity
%
%  p=RAYLEIGH(theta) computes Rayleigh's test for uniformity of the
%  circular variable theta against a unimodal alternative along the
%  first dimension. The function returns the p-value. NaNs are excluded.
%
%  p=RAYLEIGH(theta,dim) computes Rayleigh's test along dimension dim.
%
%  [p,S]=RAYLEIGH(...) returns the statistic S.
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

%default to dimension = 1
if nargin<2 || isempty(dim)
  dim = 1;
end

%remove NaNs
%theta(isnan(theta)) = [];

n = sum( ~isnan(theta), dim );

%compute circular mean and Rbar
[mu, rbar] = circ_mean( theta, dim ); %#ok

%compute statistic
S = (1-1./(2.*n)).*2.*n.*rbar.^2 + n.*rbar.^4./2;

%compute p-value
p = 1- chi2cdf( S, 2 );

%alternatively (Fisher)
%Z = n*rbar.^2;
%p = exp(-Z) * (1 + (2*Z - Z^2) / (4*n) - (24*Z - 132*Z^2 + 76*Z^3 - 9*Z^4) / (288*n^2))

%print result, if no output arguments
%if nargout==0   
%    fprintf('p = %0.3f    S = %0.2f\n', p, S);
%end

