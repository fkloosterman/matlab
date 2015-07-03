function y = vonmisespdf(theta, mu, kappa)
%VONMISESPDF probability density function for von Mises distribution
%
%  y=VONMISESPDF(theta) computes the probability density of the angles
%  theta for the Von Mises distribution with mu=0 and kappa=1.
%
%  y=VONMISESPDF(theta, mu) uses specified mu.
%
%  y=VONMISESPDF(theta, mu, kappa) uses specified mu and kappa.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

if nargin<2
    mu = 0;
end
if nargin<2
    kappa = 1;
end

y = exp(kappa.*cos(theta-mu))./(2*pi*besseli(0,kappa));
