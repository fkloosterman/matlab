function [m, rbar, ci_mu] = circ_mean( theta, dim, weights )
%CIRC_MEAN calculate circular mean
%
%  m=CIRC_MEAN(theta) computes the circular mean. NaNs are excludeds.
%
%  m=CIRC_MEAN(theta, dim) computes the circular mean along dimension dim
%  (default = 1).
%
%  m=CIRC_MEAN(theta, dim, weights) computes the weighted circular
%  mean along dimension dim (default = 1). The weights array should
%  have the same size as theta.
%
%  [m,rbar]=CIRC_MEAN(...) returns the mean vector length rbar.
%
%  [m,rbar,ci]=CIRC_MEAN(...) returns the 95% confidence interval for the
%  circular mean.
%
%  See also CIRC_MEDIAN, CIRC_DISPERSION
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

if isvector( theta )
  theta = theta(:);
end

%default to dimension = 1
if nargin<2 || isempty(dim)
  dim = 1;
end

if nargin<3 || isempty(weights)
    weights = ones(size(theta));
elseif ~isnumeric(weights) || ~isequal(size(weights),size(theta))
    error('circ_moment:invalidWeights', 'Invalid weights')
end

%compute circular mean
S = nansum( weights.*sin( theta), dim );
C = nansum( weights.*cos( theta), dim );

m = atan2(S, C);

if nargout>1
  n = sum( ~isnan(theta).*weights, dim );
  
  %compute Rbar
  rbar  = sqrt(S.^2 + C.^2) ./ n;

  if nargout>2
    %compute confidence interval using circular dispersion
    alpha = 0.05;
    d = sqrt( circ_dispersion(theta, dim, weights)./n );
    ci_mu = asin( norminv(1 - 0.5*alpha, 0, 1) .* d );
    ci_mu = cat(dim, m-ci_mu, m+ci_mu);
  end
end

%print result, if no output arguments
if nargout==0   
    fprintf('mean = %.2f    Rbar = %.2f\n', m, rbar);
end
