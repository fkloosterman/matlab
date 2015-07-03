function v = circ_std( theta, dim, weights )
%CIRC_STD circular standard deviation
%
%  v=CIRC_STD(theta) computes the circular standard deviation of the
%  angles in theta.
%
%  v=CIRC_STD(theta, dim) computes the circular standard deviation along
%  dimension dim (default = 1).
%


%  Copyright 2005-2008 Fabian Kloosterman

% check input arguments
if nargin<1
  help(mfilename)
  return
end

if isvector(theta)
  theta = theta(:);
end

%default to dimension = 1
if nargin<2 || isempty(dim)
  dim = 1;
end

if nargin<3 || isempty(weights)
    weights = ones(size(theta));
end

%compute circular standard deviation
Rbar = abs( circ_ctrmoment( theta, [], dim, weights ) );

v = sqrt( -2.*log(Rbar) );

%print result, if no output arguments
if nargout==0   
    fprintf('circular standard deviation = %.2f\n', v);
end
