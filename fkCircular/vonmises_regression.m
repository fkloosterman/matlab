function varargout = vonmises_regression( xx, theta, option, coef )
%VONMISES_REGRESSION regression of circular variable and linear covariate
%
%  [x,fval,exitflag,output]=VONMISES_REGRESSION(x,theta,option,coef)
%  computes the regression between a circular variable with a Von Mises
%  distribution and linear variable x. Option can be 'mean',
%  'concentration' or 'full' to specify whether only mu, kappa or both
%  co-vary with x. Initial coefficients can be set in coef. Returned are
%  the results from the call to fminsearch.
%
%  See also FMINSEARCH
%
  
%  Copyright 2005-2008 Fabian Kloosterman  
  
% check input arguments
if nargin<4
  help(mfilename)
  return
end
  
An = @(n,k) besseli(n,k) ./ besseli(0,k);

%Ainv lookup table
Ainv_y = -50:0.5:50;
Ainv_x = An(1,-50:0.5:50);

%Ainv = @(r) fzero( @(z) An(1,z)-r, 0 );
Ainv = @(r) interp1(Ainv_x, Ainv_y, r);


n = size(xx,1);

    function ml = mean_likelihood(b0)
        G = 2*atan(xx*b0);      
        ss = S(xx,theta,G);
        cc = C(xx,theta,G);
        mm = atan2( ss, cc );        
        rr = sqrt(ss.^2 +cc.^2);
        kk = Ainv(rr);
        ml = - (-n*log(besseli(0,kk)) + kk.*sum(cos( repmat(theta,1,size(G,2)) - repmat(mm,n,1) - G ) ) );
    end

    function ml = concentration_likelihood(b0)
        K = exp( repmat(b0(1,:),n,1) + xx*b0(2,:) );
        mu = atan2(S(theta, K), C(theta, K) );
        ml = -( -sum(log(besseli(0, K ) ) )  +  sum( K .* cos( repmat(theta,1,size(K,2)) - repmat(mu,n,1)) ) );
    end

    function ml = full_likelihood(b0)
        G = 2*atan(xx*b0(3,:));
        K = exp(repmat(b0(1,:),n,1) + xx*b0(2,:));
        mu = atan2( S(theta, K, G), C(theta,K,G) );
        ml = -( -sum( log( besseli(0, K) ) ) + sum( K .* cos( repmat(theta,1,size(K,2)) - repmat(mu,n,1) - G ) ) );
    end

switch option
    
    case 'mean'

        S = @(x, y, gg) sum( sin( repmat(y,1,size(gg,2)) - gg ) ) /n;
        C = @(x, y, gg) sum( cos( repmat(y,1,size(gg,2)) - gg ) ) /n;


        varargout = cell(1,max(nargout,1));

        [varargout{:}] = fminsearch( @mean_likelihood, coef, optimset('TolFun', 1.e-12));

%         gx = [-0.2:0.001:0.2];
%         L = mean_likelihood( gx );
%         [mi, mix] = min(L);
%         L(mix);
%         gx(mix);
%         
%         ezplot(@(xi) mean_likelihood( xi' ), gx([1 end]));
%         
    case 'concentration'
        
        S = @(y, kk) sum( kk .* repmat( sin(y),1,size(kk,2) ) );
        C = @(y, kk) sum( kk .* repmat( cos(y),1,size(kk,2) ) );
             
        varargout = cell(1,max(nargout,1));

        [varargout{:}] = fminsearch( @concentration_likelihood, coef, optimset('TolFun', 1.e-12));
        
% $$$         ezsurf( @(xi,yi) concentration_likelihood( [xi yi]' ), [-10 10 -2 1]);
% $$$      
% $$$         [gx,gy] = meshgrid( -10:0.2:10, -5:0.1:5);
% $$$         L = concentration_likelihood( [gx(:) gy(:)]' );
% $$$         [mi, mix] = min(L);
% $$$         L(mix)
% $$$         gx(mix), gy(mix)
        
        %fplot( @(xi) concentration_likelihood( [-0.25 xi]) , [-0.2 0.2]);
        
    case 'full'
        
        S = @(y,kk,gg) sum( kk .* sin( repmat(y,1,size(kk,2)) - gg ) );
        C = @(y,kk,gg) sum( kk .* cos( repmat(y,1,size(kk,2)) - gg ) );
        
        varargout = cell(1,max(nargout,1));

        [varargout{:}] = fminsearch( @full_likelihood, coef, optimset('TolFun', 1.e-12));
    
% $$$         [gx,gy,gz] = ndgrid(-5:0.1:5, -0.1:0.01:0.1,-0.1:0.01:0.1);
% $$$         L = full_likelihood( [gx(:) gy(:) gz(:)]' );
% $$$         [mi, mix] = min( L );
% $$$         L(mix);
% $$$         gx(mix), gy(mix), gz(mix);
        
end

end

