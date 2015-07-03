function p = circ_tmono_corr( theta, phi )
%CIRC_TMONO_CORR circular-circular correlation (T-monotone association)
%
%  r=CIRC_TMONO_CORR(theta, phi) computes the correlation between to
%  circular variables according to the T-monotone association.
%


%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if numel(theta) ~= numel(phi)
    error('circ_tmono_corr:invalidArguments', ...
          'Theta and phi vector have different lengths')
end

valid = find( ~isnan(theta) & ~isnan(phi) );

n = numel(valid);

theta = limit2pi( theta(valid) );
phi = limit2pi( phi(valid) );

y = circ_rank( theta );
e = circ_rank( phi );

A = sum( cos(y).*cos(e) );
B = sum( sin(y).*sin(e) );
C = sum( cos(y).*sin(e) );
D = sum( sin(y).*cos(e) );

p = (4./ (n.^2) ) .* ( A.*B - C.*D );

%s = (n-1).*p; %statistic, lookup critical value in table

