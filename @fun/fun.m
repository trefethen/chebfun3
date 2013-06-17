classdef fun % (Abstract)
%FUN   Abstract FUN class for representing global functions on [a, b].

% [TODO]: Docs for this file.

% [TODO]: Test for minandmax, rdivide.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUN Class Description:
%
% The FUN class is an abstract class for representations of functions on the
% interval [a, b]. It acheives this my taking a ONEFUN on [-1, 1] and applying
% a mapping.
%
% The current instances of FUNs are BNDFUNS and UNBNDFUNS. The former are used
% to represent functions on bounded domains, whereas the latter are able to
% represent some functions on unbounded domains.
%
% Note that all binary FUN operators (methods which can take two FUN arguments)
% assume that the domains of the FUN objects agree. The methods will not throw
% warning in case the domains don't agree, but their output will be gibberish.
%
% Class diagram: [chebfun] <>-- [<<FUN>>] <>-- [<<onefun>>]
%                                 ^   ^
%                                /     \
%                          [bndfun]   [unbndfun]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Properties of FUN objects.
    properties (Access = public)
        domain
        mapping
        onefun
    end
    
    %% CLASS CONSTRUCTOR:
    methods (Static = true)
        function obj = constructor(op, domain, vscale, hscale, pref)
            
            % We can't return an empty FUN, so pass an empty OP down.
            if ( nargin == 0  )
                op = [];
            end
            
            % Obtain preferences if none given:
            if ( nargin < 5 )
                pref = fun.pref;
            else
                pref = fun.pref(pref);
            end
            
            % Get domain if none given:
            if ( nargin < 2 || isempty(domain) )
                domain = pref.fun.domain;
            end
            
            % Get vscale if none given:
            if ( nargin < 3 || isstruct(vscale) )
                vscale = 0;
            end
            
            % Get hscale if none given:
            if ( nargin < 4 || isempty(vscale) )
                hscale = norm(domain, inf);
            end
            % [TODO]: Explain this.
            if ( isinf(hscale) )
                hscale = 1;
            end

            % Call constructor depending on domain:
            if ( ~any(isinf(domain)) )
                % Construct a BNDFUN object:
                pref = bndfun.pref(pref, pref.fun);
                obj = bndfun(op, domain, vscale, hscale, pref);
                
            else
                % Construct an UNBNDFUN object:
                pref = unbndfun.pref(pref, pref.fun);
                obj = unbndfun(op, domain, vscale, hscale, pref);
                
            end
            
        end

    end
    
    %% STATIC METHODS IMPLEMENTED BY THIS CLASS.
    methods (Static = true)
        
        % Retrieve and modify preferences for this class.
        prefs = pref(varargin);

    end
    
    %% ABSTRACT STATIC METHODS REQUIRED BY THIS CLASS.
    methods(Abstract = true, Static = true)
                
        % Map from [-1, 1] to the domain of the FUN.
        m = createMap(domain);  
        
        % Make a FUN. (Constructor shortcut)
        f = make(varargin);
    end
    
    %% ABSTRACT METHODS REQUIRED BY THIS CLASS.
    methods(Abstract = true)
                
        % Evaluate a FUN.
        y = feval(f, x)
        
        % Compute the inner product of two FUN objects.
        out = innerProduct(f, g)
        
        % [TODO]: Many others.
        
    end           
    
    %% METHODS IMPLEMENTED BY THIS CLASS.
    methods
        
        % Plot (semilogy) the Chebyshev coefficients of a FUN object.
        h = chebpolyplot(f, varargin)

        % Complex conjugate of a FUN.
        f = conj(f)
        
        % FUN objects are not transposable.
        f = ctranspose(f)

        % Flip columns of a vectorised FUN object.
        f = fliplr(f)
        
        % Get properties of a FUN.
        f = get(prop, val);
        
        % Imaginary part of a FUN.
        f = imag(f)

        % True for an empty FUN.
        out = isempty(f)

        % Test if FUN objects are equal.
        out = isequal(f, g)

        % Test if a FUN is bounded.
        out = isfinite(f)

        % Test if a FUN is unbounded.
        out = isinf(f)

        % Test if a FUN has any NaN values.
        out = isnan(f)

        % True for real FUN.
        out = isreal(f)
        
        % True for zero FUN objects
        out = iszero(f)
        
        % Length of a FUN.
        len = length(f)

        % Convert a array-valued FUN into an ARRAY of FUN objects.
        g = mat2cell(f, M, N)

        % Global maximum of a FUN on [a,b].
        [maxVal, maxPos] = max(f)

        % Global minimum of a FUN on [a,b].
        [minVal, minPos] = min(f)

        % Global minimum and maximum on [a,b].
        [vals, pos] = minandmax(f)

        % Subtraction of two FUN objects.
        f = minus(f, g)

%         % [TODO]: Left matrix divide for FUN objects.
%         X = mldivide(A, B)

        % [TODO]: Right matrix divide for a FUN.
%         X = mrdivide(B, A)

        % Multiplication of FUN objects.
        f = mtimes(f, c)

        % Basic linear plot for FUN objects.
        varargout = plot(f, varargin)

        % [TODO]: Addition of two FUN objects.
%         f = plus(f, g)

        % Right array divide for a FUN.
        f = rdivide(f, c, pref)

        % Real part of a FUN.
        f = real(f)

        % Roots of a FUN in the interval [a,b].
        out = roots(f, varargin)

        % Simplify the ONEFUN of a FUN object.
        f = simplify(f, tol)

        % Size of a FUN.
        [size1, size2] = size(f, varargin)

        % FUN multiplication.
        f = times(f, g, varargin)
        
        % FUN obects are not transposable.
        f = transpose(f)

        % Unary minus of a FUN.
        f = uminus(f)

        % Unary plus of a FUN.
        f = uplus(f)

    end
end
