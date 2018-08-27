function f = simplify( f, pref )
%SIMPLIFY  BALLFUN simplification
%
% F = SIMPLIFY( F ) returns a ballfun object simplified to have a
% compressed internal dimensions of coefficient tensor.
%
% This function is for internal use only.

% Copyright 2018 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

cfs = f.coeffs;
vals = ballfun.coeffs2vals( cfs );

vscl = max(1, max( abs( vals(:) ) ));

r_cfs = sum(sum( abs(cfs), 2), 3);
l_cfs = sum(sum( abs(cfs), 1), 3);
l_cfs = l_cfs(:);
t_cfs = sum(sum( abs(cfs), 1), 2);
t_cfs = t_cfs(:);

rTech = chebtech2.make( {'',r_cfs} );
lTech = trigtech.make( {'',l_cfs} );
tTech = trigtech.make( {'',t_cfs} );

rvals = rTech.coeffs2vals(rTech.coeffs);
rdata.vscale = vscl;
rdata.hscale = 1;
lvals = lTech.coeffs2vals(lTech.coeffs);
ldata.vscale = vscl;
ldata.hscale = 1;
tvals = tTech.coeffs2vals(tTech.coeffs);
tdata.vscale = vscl;
tdata.hscale = 1;

% Check happiness along each slice:
[resolved_r, cutoff_r] = happinessCheck(rTech, [], rvals, rdata);
[resolved_l, cutoff_l] = happinessCheck(lTech, [], lvals, ldata);
[resolved_t, cutoff_t] = happinessCheck(tTech, [], tvals, tdata);

% Simplify: 
if ( resolved_r )
    cfs = cfs(1:cutoff_r, :, :); 
end
if ( resolved_l )
    cfs = cfs(:, 1:cutoff_l, :); 
end
if ( resolved_t )
    cfs = cfs(:, :, 1:cutoff_t); 
end

f.coeffs = cfs;

end