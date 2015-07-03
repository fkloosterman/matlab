function d = circ_dispersion( theta, dim, weights )
%CIRC_DISPERSION sample circular dispersion
%
%  d=CIRC_DISPERSION(theta) compute circular dispersion of the circular
%  variable theta.
%
%  d=CIRC_DISPERSION(theta, dim) compute circular dispersion along
%  dimension dim (default = 1).

%  See also CIRC_MEAN
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

%check imput arguments
if nargin<2 || isempty(dim)
  dim = 1;
end

if nargin<3 || isempty(weights)
    weights = ones(size(theta));
elseif ~isnumeric(weights) || ~isequal(size(weights),size(theta))
    error('circ_moment:invalidWeights', 'Invalid weights')
end

%compute dispersion
R = abs( circ_ctrmoment( theta, [], dim, weights ) );
p2 = abs( circ_ctrmoment( theta, 2, dim, weights ) );

d = (1 - p2) ./ (2*R.^2);

%print result, if no output arguments
if nargout==0   
    fprintf('circular dispersion = %.2f\n', d);
end
