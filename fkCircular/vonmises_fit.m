function [mu, kappa, p, U2] = vonmises_fit( theta, mu, kappa )
%VONMISES_FIT fit von mises distribution to data
%
%  [mu,kappa]=VONMISES_FIT(theta) computes the parameters mu and kappa of
%  the Von Mises distribution that best fits the circular variable
%  theta. NaNs are excluded.
%
%  [mu,kappa,p,U2]=VONMISES_FIT(theta) returns the p-value and statistic
%  U2 for the Watson goodness of fit test.
%
%  [...]=VONMISES_FIT(theta, mu) computes the best fit and goodness of
%  fit for the Von Mises distribution with known parameter mu.
%
%  [...]=VONMISES_FIT(theta, [], kappa) computes the best fit and
%  goodness of fit for the Von Mises distribution with known parameter
%  kappa.
%
%  [...]=VONMISES_FIT(theta, mu, kappa) computes the best fit and
%  goodness of fit for the Von Mises distribution with known parameters
%  mu and kappa.
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

%remove NaNs
theta(isnan(theta)) = [];

n = numel(theta);

mu_known = 1;
kappa_known = 1;

%compute mu
if nargin<2 || isempty(mu)
    mu = circ_mean(theta);
    mu_known = 0;
end

%compute kappa
if nargin<3 || isempty(kappa)
    An = @(n,k) besseli(n,k) ./ besseli(0,k);
    rbar = sum(cos(theta - mu))./n;
    if rbar==1
        kappa = Inf;
        p = 0;
        U2 = NaN;
        return
    elseif rbar==0
        kappa = 0;
    else
        kappa = fzero( @(x) An(1, x)-rbar, 0 );    
    end
    kappa_known = 0;
end

%Goodness of fit test based on Watson U2
U = vonmisescdf( theta, mu, kappa );

U = sort( U );
U2 = sum( U.^2 )- n.*mean(U).^2 - 2.*sum( (1:n).*U )./n + (n+1).*mean(U) + n/12;

k = [0 0.5 1 1.5 2 4 Inf];
alpha = [0.5 0.25 0.15 0.1 0.05 0.025 0.01 0.005];

if mu_known && kappa_known
    %modified U2 according to Stephens, 1970
    U2 = (U2 - 0.1./n + 0.1./(n.^2) ).*(1+0.8./n);
    p = 2.*exp(-2.*U2.*(pi.^2));
    p = min( max( p, 0), 1 ); 
    
elseif mu_known && ~kappa_known
    table = [0.047 0.071 0.089 0.105 0.133 0.163 0.204 0.235;...
             0.048 0.072 0.091 0.107 0.135 0.165 0.205 0.237;...
             0.051 0.076 0.095 0.111 0.139 0.169 0.209 0.241;...
             0.053 0.080 0.099 0.115 0.144 0.173 0.214 0.245;...
             0.055 0.082 0.102 0.119 0.147 0.177 0.217 0.248;...
             0.058 0.086 0.107 0.124 0.153 0.183 0.224 0.255;...
             0.059 0.089 0.110 0.127 0.157 0.187 0.228 0.259];

    %interpolate table to get critical values for given kappa
    if kappa<=4
        cval = interp2( alpha, k(1:end-1), table(1:end-1,:), alpha, kappa );
    else
        cval = interp2( alpha, 1./k(end-1:end), table(end-1:end,:), alpha, 1./kappa );
    end
    
    %fit exponential to critical values
    %b = robustfit( cval, log(alpha) );    
    b = regress( cval', [ones(1,8) ; log(alpha)]' );
    p = exp( b(1) + b(2).*U2 );
    p = min( max( p, 0), 1 );    
    
elseif ~mu_known && kappa_known
    table = [0.047 0.071 0.089 0.105 0.133 0.163 0.204 0.235;...
             0.048 0.072 0.091 0.107 0.135 0.165 0.205 0.237;...
             0.051 0.076 0.095 0.111 0.139 0.169 0.209 0.241;...
             0.053 0.080 0.100 0.116 0.144 0.174 0.214 0.245;...
             0.055 0.082 0.103 0.119 0.148 0.177 0.218 0.249;...
             0.057 0.085 0.106 0.122 0.151 0.181 0.221 0.253;...
             0.057 0.085 0.105 0.122 0.151 0.180 0.221 0.252];
         
    %interpolate table to get critical values for given kappa
    if kappa<=4
        cval = interp2( alpha, k(1:end-1), table(1:end-1,:), alpha, kappa );
    else
        cval = interp2( alpha, 1./k(end-1:end), table(end-1:end,:), alpha, 1./kappa );
    end
    
    %fit exponential to critical values
    %b = robustfit( cval, log(alpha) );             
    b = regress( cval', [ones(1,8) ; log(alpha)]' );
    p = exp( b(1) + b(2).*U2 );
    p = min( max( p, 0), 1 );    
    
elseif ~mu_known && ~kappa_known
    table = [0.03 0.04 0.046 0.052 0.061 0.069 0.081 0.09;...
             0.031 0.042 0.05 0.056 0.066 0.077 0.09 0.1;...
             0.035 0.049 0.059 0.066 0.079 0.092 0.11 0.122;...
             0.039 0.056 0.067 0.077 0.092 0.108 0.128 0.144;...
             0.043 0.061 0.074 0.084 0.101 0.119 0.142 0.159;...
             0.047 0.067 0.082 0.093 0.113 0.132 0.158 0.178;...
             0.048 0.069 0.084 0.096 0.117 0.137 0.164 0.184];
         
    %interpolate table to get critical values for given kappa
    if kappa<=4
        cval = interp2( alpha, k(1:end-1), table(1:end-1,:), alpha, kappa );
    else
        cval = interp2( alpha, 1./k(end-1:end), table(end-1:end,:), alpha, 1./kappa );
    end
    
    %fit exponential to critical values
    %b = robustfit( cval, log(alpha) );    
    b = regress( log(alpha'), [ones(1,8) ; cval]' );
    p = exp( b(1) + b(2).*U2 );
    p = min( max( p, 0), 1 );
    
end
    
