function d = circ_density( theta, z, bandwidth, kernel, weights)
%CIRC_DENSITY circular kernel density estimate
%
%  d=CIRC_DENSITY(theta) compute circular density estimate of the
%  circular variable theta at 24 equal spaced angles using a Von Mises
%  kernel. NaN values are excluded.
%
%  d=CIRC_DENSITY(theta, z) compute circular density at every angle in
%  vector z.
%
%  d=CIRC_DENSITY(theta, z, kappa) use the concentration parameter kappa
%  for the Von Mises kernel.
%
%  d=CIRC_DENSITY(theta, z, bandwidth, 'box') uses a box kernel with the
%  specified width (default width = pi/6 ) as the kernel.
%
%
%  See also VONMISESPDF, KSDENSITY
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

%default to 24 equal spaced angles
if nargin<2 || isempty(z)
    z = (0:23)*2*pi./24;
end

%no data, then density is zero
if n==0
    d = zeros(1,numel(z));
    return;
end

%make sure 0<=z<2*pi and 0<=theta<2*pi
z = limit2pi(z);
theta = limit2pi(theta);

%default to von mises kernel
if nargin<4 || isempty(kernel)
    kernel = 'vonmises';
elseif ~ismember( kernel, {'vonmises', 'box'})
    error('Unknown kernel')
end

%default to kappa = 5 for von mises distribution and pi./6 for box
if nargin<3 || isempty(bandwidth)
    switch kernel
        case 'vonmises'
            bandwidth = 5; % bandwidth = concentration parameter
        case 'box'
            bandwidth = pi./6;
    end
end

if nargin<5 || isempty(weights)
    weights = ones(n,1);
elseif ~isnumeric(weights) || ~isvector(weights) || numel(weights)~=n
    error('Invalid weights')
end

%compute circular kernel density estimate
switch kernel
    case 'vonmises'
        
        theta = repmat( theta(:), 1, numel(z) );
        z = repmat( z(:)', n, 1 );
        d = vonmisespdf(z, theta, bandwidth);
        d = nansum(bsxfun(@times, d, weights(:)))./nansum(weights);
        
    case 'box'
        
        lb = repmat(theta(:) - 0.5*bandwidth,1,numel(z));
        hb = repmat(theta(:) + 0.5*bandwidth,1,numel(z));
        
        z = repmat( z(:)', n, 1);
        z( hb>2*pi & z<=(hb-2*pi) ) = z( hb>2*pi & z<=(hb-2*pi) ) + 2*pi;
        z( lb<0 & z>=(lb+2*pi) ) = z( lb<0 & z>=(lb+2*pi) ) - 2*pi;
        
        d = unifpdf( z, lb, hb );
        d = nansum(bsxfun(@times, d, weights(:)))./nansum(weights);
        
end
