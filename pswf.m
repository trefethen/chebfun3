function [P, lam] = pswf(N, c, dom, flag)
%PSWF   Prolate spheroidal wave functions.
% P = PSWF(N, C) computes a CHEBFUN representing the Nth prolate spheroidal
% wave function (PSWF) with bandwidth C on the interval [-1,1]. C must be a
% scalar but N may be a vector of non-negative integers, in which case the
% output is an array-valued CHEBFUN with LENGTH(N) columns.
%
% P = PSWF(N, C, DOM) computes the PSWFs as above, but scaled to the interval 
% DOM, which must be a finite 2-vector.
%
% [P, LAM] = PSWF(N, C, ...) returns also a vector LAM of length N containing the
% corresponding eigenvalues of the bandwidth-C PSWF differential
% eigenvalue problem.
%
% [V, LAM] = PSWF(N, C, DOM, 'coeffs') or [V, LAM] = PSWF(N, C, 'coeffs')
% returns the matrix V of Legendre coefficients for the computed PSWF
% rather than a CHEBFUN.
%
% Example:
%
% plot(pswf([1 3 5],100))
%
% See also PSWFPTS.

% Copyright 2020 by The University of Oxford and The Chebfun Developers. 
% See http://www.chebfun.org/ for Chebfun information.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Developer note: The approach is to compute the (approximate) normalised
% Legendre coefficients of the PSWFs by solving an eigenvalue problem [1].
% The Legendre coefficients are then converted to Chebyshev via LEG2CHEB,
% and a Chebfun constructed.
%
% [1] H. Xiao, V. Rokhlin and N. Yarvin, Prolate spheroidal wavefunctions,
% quadrature and interpolation, Inverse Problems, 17 (2001) 805–838.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defaults:
if ( nargin < 3 )
    dom = [-1 1];
    flag = 'chebfun';
end
if ( nargin == 3 )
    if ( isnumeric(dom) )   
        flag = 'chebfun';
    else
        flag = dom;
        dom = [-1 1];
    end
end

% Parse inputs:
assert( all(round(N)==N) && all(N>=0) , ...
    'N must be vector of non-negative integers.');
assert( (numel(c)==1) && (c>=0) , ...
    'C must be a non-negative scalar.');
assert( numel(dom)==2 && all(isfinite(dom)) , ...
    'Domain must be a finite two-vector.');

% Set discretisation size. Heuristic estimates for initialisation.
M = max(ceil([2*sqrt(c)*N, 2*c, 20]));

% Increase discretisation size until the trailing Legendre coefficients are
% sufficiently small:
ishappy = 0;
tol = 1e-14;
count = 0;

while ( ~ishappy )

    % Construct the matrix (see Xiao et al):
    j = (0:M).';
    Asub = c^2*j.*(j-1)./((2*j-1).*sqrt((2*j-3).*(2*j+1)));
    Adia = j.*(j+1) + c^2*(2*j.*(j+1)-1)./((2*j+3).*(2*j-1));
    Asup = c^2*(j+2).*(j+1)./((2*j+3).*sqrt((2*j+5).*(2*j+1)));
    A = diag(Asub(3:end), -2) + diag(Adia, 0) + diag(Asup(1:end-2), 2);
    
    % Split in to even and odd parts for efficiency/accuracy. 
    Ae = A(1:2:end,1:2:end);
    Ao = A(2:2:end,2:2:end);
    
    % Compute (sorted) eigenvectors:
    [Ve, De] = eig(Ae);
    [lame, idx] = sort(diag(De), 'ascend');
    Ve = Ve(:,idx);
    [Vo, Do] = eig(Ao);
    [lamo, idx] = sort(diag(Do), 'ascend');
    Vo = Vo(:,idx);
    
    % Reassemble full V and eigenvalues:
    V = zeros(M+1,M+1);
    V(1:2:end,1:2:end) = Ve;
    V(2:2:end,2:2:end) = Vo;
    lam = zeros(M+1,1);
    lam(1:2:end) = lame;
    lam(2:2:end) = lamo;
    
    % Check discretisation size was large enough;
    ishappy = sum(abs(V(end-3:end,N+1)))/(2*length(N)) < tol;
    if ( ~ishappy )
        M = 2*M;
    end
    
    % Failsafe:
    count = count + 1;
    if ( count > 10 )
        break
    end
    
end

% Extract required columns and unnormalise:
V = bsxfun(@times, V(:,N+1), sqrt((0:M)'+1/2) );
lam = lam(N+1);

% Trim trailing coefficients below machine precision:
M = max(abs(V), [],2);
idx = find(M > eps, 1, 'last');
V = V(1:idx,:);

% Quit now if only coefficients are required:
if ( strcmpi(flag, 'coeffs') )
    P = V;
    return
end

% Convert to Chebyshev coeffs:
W = leg2cheb(V);

% Enforce even/oddness (which is lost in leg2cheb):
idx = abs(W(1,:)) < tol;
W(1:2:end,idx) = 0;
W(2:2:end,~idx) = 0;

% Create a Chebfun from the Chebyshev  coefficients:
P = chebfun(W, dom, 'coeffs');

% The coefficients are trimmed in V, so simplifying should not be necessary.
% P = simplify(P);    

end