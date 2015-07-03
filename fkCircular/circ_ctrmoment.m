function m = circ_ctrmoment( theta, p, dim, weights )
%CIRC_CTRMOMENT centered sample trigonometric moment
%
%  m=CIRC_CTRMOMENT(theta) compute the first centered moment of the
%  circular variable theta. NaN values are excluded.
%
%  m=CIRC_CTRMOMENT(theta, p) compute the p-th centered moment.
%
%  m=CIRC_CTRMOMENT(theta, p, dim) compute the p-th centered coment along
%  dimension dim (default = 1).
%
%  m=CIRC_CTRMOMENT(theta, p, dim, weights) computes weighted
%  centered circular moment
%

%  See also CIRC_MOMENT
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return
elseif isvector(theta)
  theta=theta(:);
end

%default to first moment
if nargin<2 || isempty(p)
    p = 1;
end

%default to dimension 1
if nargin<3 || isempty(dim)
  dim = 1;
elseif dim<1 || dim>ndims(theta)
  error('Invalid dimension')
end

if nargin<4 || isempty(weights)
    weights = ones(size(theta));
elseif ~isnumeric(weights) || ~isequal(size(weights),size(theta))
    error('circ_moment:invalidWeights', 'Invalid weights')
end

%create replication size vector for repmat
%r = ones( 1, ndims( theta ));
%r( 1,dim ) = size(theta, dim );

%calculate angle of circular moment
m1 = angle( circ_moment( theta, p, dim, weights ) );

%calculate centered circular moment
n = sum( ~isnan(theta).*weights , dim );
S = nansum( weights .* sin( p.* ( bsxfun(@minus, theta, m1) ) ), dim ) ./ n;
C = nansum( weights .* cos( p.* ( bsxfun(@minus, theta, m1) ) ), dim ) ./ n;

m = C + i*S;

%print result, if no output argument
if nargout==0   
    fprintf('centered moment %d = %.2f %+.2fi\n', p, real(m), imag(m));
end
