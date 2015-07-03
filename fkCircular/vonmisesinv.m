function theta = vonmisesinv( p, mu, kappa, tol )
%VONMISESINV inverse von Mises distribution function
%
%  theta=VONMISESINV(p) computes the inverse of the Von Mises
%  distribution with mu=0 and kappa=1 for the given p-values.
%
%  theta=VONMISESINV(p, mu) uses a Von Mises distribution with specified
%  mu.
%
%  theta=VONMISESINV(p, mu, kappa) uses a Von Mises distribution with
%  specified mu and kappa.
%
%  theta=VONMISESINV(p, mu, kapp, tol) sets a convergence tolerance level
%  for the computation (default = 1e-6).
%
%  See also VONMISESCDF
%

%  Copyright 2005-2008 Fabian Kloosterman

%check  input arguments
if nargin<1
    help(mfilename)
    return
end

%default to mu=0
if nargin<2
  mu = 0;
end

%default to kappa = 1
if nargin<2
  kappa = 1;
end

%default to tol = 1e-6
if nargin<4
  tol = 1.e-6;
end

%maximum  number of iterations
it_max = 150;

theta = NaN( size(p) );

for k=1:numel(p)
  
    %fast computation if p<=0 or p>=1 
    if ( p(k) <= 0 || 1 <= p(k) )
        theta(k) = limit2pi( mu - pi );
        continue
    end

    x1 = 0;
    cdf1 = 0.0;

    x2 = 2*pi;

    %
    %  Now use bisection.
    %
    
    it = 0;

    while ( it<it_max )

        it = it + 1;

        x3 = 0.5 * ( x1 + x2 );
        cdf3 = vonmisescdf( x3, mu, kappa );

        if ( abs ( cdf3 - p(k) ) < tol )
            theta(k) = x3;
            break
        end

        if ( ( p(k) <= cdf3 && p(k) <= cdf1 ) || ( cdf3 <= p(k) && cdf1 <= p(k) ) )
            x1 = x3;
            cdf1 = cdf3;
        else
            x2 = x3;
        end

    end
    
    if it>=it_max
        warning('vonmisesinv:maxIteration', ['No conversion in ' num2str(it_max) ' iterations']);
    end

end
