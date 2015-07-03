function rt = circ_tlinear_association( theta, phi )
%CIRC_TLINEAR_ASSOCIATION circular-circular assocation
%
%  r=CIRC_TLINEAR_ASSOCIATION(theta, phi) computes the correlation
%  between two circular variables acoording to the T-linear association.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if numel(theta)~=numel(phi)
    error('circ_tlinear_association:invalidArguments', ...
          'Theta and phi should have same number of elements')
end

valid = find( ~isnan(theta(:)) & ~isnan(phi(:)) );

n = numel(valid);

A = sum(cos(theta(valid)).*cos(phi(valid)));
B = sum(sin(theta(valid)).*sin(phi(valid)));
C = sum(cos(theta(valid)).*sin(phi(valid)));
D = sum(sin(theta(valid)).*cos(phi(valid)));
E = sum(cos(2*theta(valid)));
F = sum(sin(2*theta(valid)));
G = sum(cos(2*phi(valid)));
H = sum(sin(2*phi(valid)));

rt = 4.*(A.*B - C.*D) ./ sqrt((n.^2 - E.^2 - F.^2).*(n.^2 - G.^2 - H.^2));
