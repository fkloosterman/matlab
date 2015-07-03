function [m, mdev, mdiff] = circ_median( theta )
%CIRC_MEDIAN circular median, mean deviation and mean difference
%
%  m=CIRC_MEDIAN(theta) computes the circular median for the vector of
%  angles theta. NaNs are excluded.
%
%  [m,mdev]=CIRC_MEDIAN(theta) returns mean deviation between angles in
%  theta and the median.
%
%  [m,mdev,mdiff]=CIRC_MEDIAN(theta) returns mean circular difference
%  between every pair of angles in theta.
%
%  See also CIRC_MEAN
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

theta = theta(:);

%remove NaNs
theta(isnan(theta))=[];
n = numel(theta);

%return if only one value in theta
if n==1
    m = theta;
    mdev = 0;
    mdiff = 0;
    return
end

%make sure 0<=theta<2*pi
theta = limit2pi( theta );

%define mean circular difference function
d = @(a) sum( pi - abs( pi - abs( theta - a ) ) ) ./ n;

%minimize mean circular difference to find median
[m, mdev] = fminbnd( d, 0, 2*pi);

mdiff = 0;

if nargout>=3
  %compute mean difference
  for k=1:n
    mdiff = mdiff + d( theta(k) );
  end
  mdiff = mdiff ./ n;
end

%print result, if no output arguments
%if nargout==0   
%    fprintf('median = %.2f   mean deviation = %.2f\n', m, mdev);
%end
