function [p, V] = kuiper( theta, dim )
%KUIPER kuiper's test for uniformity
%
%  p=KUIPER(theta) computes Kuiper's statistic for uniformity of the
%  circular variable theta along the first dimension. The function
%  returns the p-value. NaNs are excluded.
%
%  p=KUIPER(theta,dim) computes Kuiper's statistic along dimension
%  dim.
%
%  [p,V]=KUIPER(...) returns the statistic V.
%
%  Reference: Stephens, M. (1970). Use of the Kolmogorov-Smirnov,
%  Cramer-von Mises and related statistics without extensive
%  tables. Journal of the Royal Statistical Society, B32, 115-122
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


%compute modified statistic
theta = sort( limit2pi( theta ), dim );

U = theta ./ (2*pi) - bsxfun(@rdivide, shiftdim(1:size(theta,dim),2-dim), n);

V = nanmax(U,[],dim) - nanmin(U,[],dim) + 1./n;

%modified according to Stephens
V = V.*(sqrt(n) + 0.155 + 0.24./sqrt(n));

%atable = [0.15 0.10 0.05 0.025 0.01];
%vtable = [1.537 1.620 1.747 1.862 2.001];

%compute p-value
p = (8*V.^2-2).*exp(-2.*V.^2);

%print result, if no output arguments
%if nargout==0   
%    fprintf('p = %0.3f    V = %0.2f\n', p, V);
%end

