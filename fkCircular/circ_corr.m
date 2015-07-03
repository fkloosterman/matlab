function [r2, p, U] = circ_corr(x, theta)
%CIRC_CORR calculate circular correlation
%
%  r2=CIRC_CORR(x, theta) compute the circular correlation between the
%  linear variable x and the circular variable theta. The function
%  returns the squared r-value.
%
%  [r2,p]=CIRC_CORR(...) also returns the p-value
%
%  [r2,p,U]=CIRC_CORR(...) also returns the statistic U
%

%  Copyright 2005-2008 Fabian Kloosterman


%check arguments
if n<2
    r2 = NaN;
    p = NaN;
    U = NaN;
    return
end

n = numel(x);

%compute correlation between x, sin(theta) and cos(theta)
rxc = corrcoef( x, cos(theta) );
rxs = corrcoef( x, sin(theta) );
rcs = corrcoef( cos(theta), sin(theta));

rxc = rxc(1,2);
rxs = rxs(1,2);
rcs = rcs(1,2);

r2 = (rxc.^2 + rxs.^2 - 2.*rxc.*rxs.*rcs) ./ (1-rcs.^2);

%compute statistic
U = ((n-3).*r2) ./ (1-r2);

%compute p-value
p = 1 - fcdf( U, 2, n-3 );
