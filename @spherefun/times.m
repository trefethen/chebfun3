function varargout = times(varargin)
% .*    Pointwise multiplication for SPHEREFUN objects.
%
%   F.*G multiplies SPHEREFUN objects F and G. Alternatively F or G could be a
%   double.

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

[varargout{1:nargout}] = times@separableApprox(varargin{:});

end