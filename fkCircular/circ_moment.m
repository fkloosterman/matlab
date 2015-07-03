function m = circ_moment( theta, p, dim, weights )
%CIRC_MOMENT non-centered sample trigonometric moments
%
%  m=CIRC_MOMENT(theta) compute first circular moment of the circular
%  variable theta. Nans are excluded.
%
%  m=CIRC_MOMENT(theta, p) compute the p-th circular moment.
%
%  m=CIRC_MOMENT(theta, p, dim) compute the p-th circular moment along
%  dimension dim (default = 1).
%
%  m=CIRC_MOMENT(theta, p, dim, weights) computes weighted circular
%  moment
%

%  See also CIRC_CTRMOMENT
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return
elseif isvector(theta)
  theta = theta(:);
end

%default to first moment
if nargin<2 || isempty(p)
    p = 1;
end

%default to dimension 1
if nargin<3 || isempty(dim)
  dim = 1;
end

if nargin<4 || isempty(weights)
    weights = ones(size(theta));
elseif ~isnumeric(weights) || ~isequal(size(weights),size(theta))
    error('circ_moment:invalidWeights', 'Invalid weights')
end

%calculate circular moment
n = sum( ~isnan(theta).*weights , dim );
S = nansum( weights.*sin(p.*theta), dim ) ./ n;
C = nansum( weights.*cos(p.*theta), dim ) ./ n;

m = C + i*S;

%print result, if no output argument
if nargout==0   
    fprintf('moment %d = %.2f %+.2fi\n', p, real(m), imag(m));
end
