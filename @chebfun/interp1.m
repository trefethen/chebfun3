function p = interp1(x, y, method)
%INTERP1    CHEBFUN polynomial interpolant at any distribution of points.
%   P = INTERP1(X, Y), where X and Y are vectors, returns the CHEBFUN P defined
%   on the domain [X(1), X(end)] corresponding to the polynomial interpolant
%   through the data Y(j) at points X(j).
%
%   If Y is a matrix with more than one column then then Y(:,j) is taken as the
%   value to be matched at X(j) and P is an array-valued CHEBFUN with each
%   column corresponding to the appropriate interpolant.
%
%   EXAMPLE: The following commands plot the interpolant in 11 equispaced points
%   on [-1, 1] through the famous Runge function:
%       d = [-1, 1];
%       ff = @(x) 1./(1+25*x.^2);
%       x = linspace(d(1), d(2), 11);
%       p = interp1(x, ff(x))
%       plot(chebfun(ff, d), 'k', p, 'r', x, ff(x), '.r'), grid on
%
%   P = interp1(X, Y, METHOD) specifies alternate interpolation methods. The
%   default is as described above. (Use an empty matrix [] to specify the
%   default.) Available methods are:
%       'linear'   - linear interpolation
%       'spline'   - piecewise cubic spline interpolation (SPLINE)
%       'pchip'    - shape-preserving piecewise cubic interpolation
%       'cubic'    - same as 'pchip'
%
% See also INTERP1, SPLINE, PCHIP.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www..chebfun.org/ for Chebfun information.

if ( nargin < 3 )
    method = [];
end

switch method
    case {[], 'poly'}
        p = interp1Poly(x, y);
    case 'spline'
        p = chebfun.spline(x, y);
    case {'pchip', 'cubic'}
        p = chebfun.pchip(x, y);
    case 'linear'
        p = interp1Linear(x, y);
    otherwise
        error('CHEBFUN:interp1:method', 'Unknown method ''%s''', method);
end

end

function p = interp1Poly(x, y)
% Polynomial interpolation

% Compute barycentric weights for these points:
w = baryWeights(x);
% Define the interpolant using CHEBTECH.BARY():
f = @(z) chebtech.bary(z, y, x, w);
% Construct a CHEBFUN:
p = chebfun(f, [x(1), x(end)], length(x));

end

function p = interp1Linear(x, y)
% Linear interpolation

% Ensure x is a column vector:
if ( size(x, 1) == 1 )
    x = x.';
end

% Number of intervals:
numInts = numel(x) - 1;

% Piecewise Chebyshev grid:
xx = chebpts(repmat(2, numInts, 1), x);

% Forgive some transpose issues:
if ( ~any(size(y) == size(x))  )
    y = y.';
end

% Evaluate on the Chebyshev grid using built-in spline:
yy = interp1(x, y, xx, 'linear');

% Construct the CHEBFUN:
data = mat2cell(yy, repmat(2, numInts, 1), size(yy, 2));
p = chebfun(data, x.');

end

function w = baryWeights(x)
%BARYWEIGHTS   Barycentric weights
%   W = BARYWEIGHTS(X) returns scaled barycentric weights for the points X. The
%   weights are scaled such that norm(W, inf) == 1.

n = length(x);
if ( isreal(x) )
    C = 4/(max(x) - min(x)); % Capacity of interval.
else
    C = 1; % Scaling by capacity doesn't apply for complex nodes.
end

% [TODO]: Why is the top loop not used? (IF 0)
if ( n < 2001 && 0 )         % For small n using matrices is faster.
   V = C*bsxfun(@minus, x, x.');
   V(logical(eye(n))) = 1;
   VV = exp(sum(log(abs(V))));
   w = 1./(prod(sign(V)).*VV).';
   
else                         % For large n use a loop
   w = ones(n,1);
   for j = 1:n
       v = C*(x(j)-x); v(j) = 1;
       vv = exp(sum(log(abs(v))));
       w(j) = 1./(prod(sign(v))*vv);
   end
end

% Scaling:
w = w./max(abs(w));

end



