function [p, U2] = watson( theta )
%WATSON Watson 's U2 test
%
%  p=WATSON(theta) Watson's U2 test for uniformity / goodness of fit?
%
%  [p,U]=WATSON(theta) returns statistic U
%
%  Reference: Stephens, M. (1970). Use of the Kolmogorov-Smirnov,
%  Cramer-von Mises and related statistics without extensive
%  tables. Journal of the Royal Statistical Society, B32, 115-1221
%

%  Copyright 2005-2008 Fabian Kloosterman

n = numel(theta);
theta = sort( limit2pi( theta ) );
U = theta ./ (2*pi);

U2 = sum( U.^2 )- n.*mean(U).^2 - 2.*sum( (1:n).*U )./n + (n+1).*mean(U) + n/12;
%U2 = sum( (U-(2*[1:n]-1)./(2.*n)).^2 ) - n.*((mean(U)-0.5).^2) + 1./(12.*n)

%modified U2 according to Stephens, 1970
U2 = (U2 - 0.1./n + 0.1./(n.^2) ).*(1+0.8./n);


p = 2.*exp(-2.*U2.*(pi.^2));

if nargout==0   
    fprintf('p = %0.3f    U2 = %0.3f\n', p, U2);
end
