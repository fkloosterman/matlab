function p = vonmisescdf( theta, mu, kappa, tol)
%VONMISESCDF von Mises distribution function
%
%  p=VONMISESCDF(theta) computes the cumulative probability densitity at
%  the angles theta of the Von Mises distribution with mu=0 and kappa=1.
%
%  p=VONMISESCDF(theta, mu) uses the specified mu.
%
%  p=VONMISESCDF(theta, mu, kappa) uses the specified mu and kappa
%  parameters.
%
%  p=VONMISESCDF(theta, mu, kapp, tol) sets the conversion tolerance for
%  the computation (default = 1e-20).
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return;
end

%default to mu=0
if nargin<2
    mu = 0;
end

%default to kappa=1
if nargin<3
    kappa = 1;
end

%default to tolerance = 1e-20
if nargin<4
    tol = 1.e-20;
end

if isinf(kappa)
    error('vonmisescdf:invalidArgument', 'Cannot deal with kappa=Inf')
end

%make sure 0<=theta<2*pi
theta = limit2pi(theta);

  %define cdf function
  function p = pvm( x )
  n = 1;
  s = 0;
  term = 2*tol;
  while any( abs(term) > tol ) || n>100000
    term = besseli(n, kappa) .* sin( n.* ( x ) ) ./ n;
    s = s+term;
    n = n + 1;
  end  
  p = x./(2*pi) + s./(pi.*besseli(0,kappa));
  end


%compute cdf
if (mu == 0)

    p = pvm( theta );

else
    idx = find( theta <=  mu );
    upper = limit2pi( theta(idx)-mu );
    upper( upper==0 ) = 2*pi;
    lower = limit2pi( -mu );
    p(idx) = pvm(upper) - pvm(lower);
    
    idx = find( theta>mu );
    upper = theta(idx) - mu;
    lower = limit2pi( mu );
    p(idx) = pvm(upper) + pvm(lower);

end

end
