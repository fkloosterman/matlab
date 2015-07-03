function varargout = circ_regression( xx, theta, bound_slope )
%CIRC_REGRESSION linear-circular regression
%
%  coef=CIRC_REGRESSION(x, theta) computes linear regression of circular
%  variable theta on linar regressor x. The model  is: theta = A + B*x
%  (mod 2pi). This function willcalculate A and B by minimizing the sum
%  of circular distances. Returned are the coefficients A and B.
%
%  coef=CIRC_REGRESSION(x, theta, slopebounds) specifies boundaries for
%  the slope parameter B in the model.
%
%  [coef,r]=CIRC_REGRESSION(...) returns the correlation coefficient.
%
%  [coef,r,fcn]=CIRC_REGRESSION(...) returns the handle of the function
%  for the best fit line (i.e. A+B*x)
%
%  [coef,r,fcn,res]=CIRC_REGRESSION(...) returns the residuals.
%
%  See also: 
%
  
%  Copyright 2005-2008 Fabian Kloosterman

% check input arguments
if nargin<2
    help(mfilename)
    return
end

%default to no slope limits
if nargin<3
  bound_slope=[];
end

%exclude NaNs
valid = find(~isnan(theta));

theta = theta(valid);
xx = xx(valid);

%define objective function for minimization
xx = [ones(numel(xx),1) xx(:)];
theta = theta(:);

objfcn = @(coef) sum( circ_diff( repmat( theta, 1, size(coef,1) ), xx*coef').^2 );

%using genetic algorithm to find inital coefficients
coef = ga( objfcn, 2, gaoptimset( 'PopInitRange', [0 -1; 2*pi 1] ) );

if isempty(bound_slope)
  %find minimum
  coef = fminsearch( objfcn, coef);
else
  %get first estimate
  [ox, oy] = meshgrid( 0:0.05:2*pi, linspace(bound_slope(1), bound_slope(2), 100) );
  oo = objfcn( [ox(:) oy(:)] );
  [m, mi] = min( oo ); %#ok
  %finf minimum
  coef = fmincon( objfcn, [ox(mi) oy(mi)], [], [], [], [], [ 0 bound_slope(1) ], [2*pi ...
                      bound_slope(2) ] );
end

%make sure 0<=A<2*pi
coef(1) = limit2pi(coef(1));

%set output arguments
if nargout>=1
    varargout{1} = coef;
end

if nargout>=2
  %calculate residuals
  theta_residual = limit2pi( theta - xx*coef' );
  %compute correlation coefficient
  varargout{2} = sqrt( 1 - sum( circ_diff(theta_residual, circ_mean(theta_residual)).^2 )./sum( circ_diff(theta, circ_mean(theta)).^2 ) );
end

if nargout>=3
  %define fit function
  varargout{3} = @(x) coef(1) + coef(2).*x;
end

if nargout>=4
  varargout{4} = theta_residual;
end
  
