function theta = vonmisesrnd( mu, kappa, varargin )
%VONMISESRND random sample from von Mises distribution
%
%  theta=VONMISESRND(mu, kappa) returns a randomly sample angle from the
%  Von Mises distribution with specified mu and kappa.
%
%  theta=VONMISESRND(mu, kappa, [M N ...]) returns a matrix of size [M N
%  ...] with randonly sampled angles.
%
%  theta=VONMISESRND(mu, kappa, M, N, ...) same as above syntax.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin < 2
    help(mfilename)
    return
end

if nargin==3 && isscalar(varargin{1})
    n = {varargin{1} 1};
else
    n = varargin;
end

u = unifrnd(0,1, n{:});

%slow analytic version
%theta = vonmisesinv( u, mu, kappa );

%faster approximation
npoints = 1000;
a = pi*linspace(0,2,npoints);
p = vonmisescdf(a, 0, kappa);
p(end) = 1;
theta = limit2pi(interp1( p, a, u ) + mu, -pi);