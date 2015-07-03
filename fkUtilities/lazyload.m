function fcn = lazyload(file)
%LAZYLOAD load .mat file variables on request
%
%  fcn=LAZYLOAD(file) returns a function handle through which you can load
%  variables from the specified .mat file. After the first request,
%  variables are kept in memory for faster access next time. The retruned
%  function can be used in the following ways:
%   data=fcn() - load all data
%   data=fcn(var1,var2,...) - load only specified variables
%   data=fcn({var1,var2,...}) - load only specified variables
%   data=fcn(0) - unload all variables
%   data=fcn(0,var1,var2,...) - unload specified variables
%   data=fcn(0,{var1,var2,...}) - unload specified variables
%   data=fcn('-list') - list variables in file
%

if nargin<1 || ~ischar(file) || ~isvector(file)
    error('lazyload:invalidArgument', 'Need a file name')
end

try
    file = fullpath(file);
    vars = who( '-file', file );
catch me
    base_me = MException('lazyload:invalidFile', ...
        'Invalid .mat file %s', file);
    new_me = addCause(base_me, me);
    throw(new_me);
end
    
data = cell(size(vars));

fcn = @(varargin) localloadvar( file, varargin{:} );

    function y=localloadvar( f, varargin )
       
        if nargin<2

            loadvars = vars;
            unloadvars = {};
            
        elseif nargin==2 && ischar( varargin{1} ) && strcmp( varargin{1}, '-list')
            
            y = vars;
            return
            
        elseif isequal( varargin{1}, 0 )
            
            loadvars = {};
            
            if nargin==2
                 unloadvars = vars;
            elseif iscellstr(varargin(2:end))
                unloadvars = varargin(2:end);
            elseif nargin==3 && iscellstr(varargin{2})
                unloadvars = varargin{2};
            else
                error('lazyload:invalidArguments', 'Invalid arguments')
            end
            
            if ~isvector(unloadvars) || ~all(ismember(unloadvars,vars))
                error('lazyload:invalidVariables', 'Invalid variable names. Cannot unload')
            end
            
        elseif iscellstr( varargin )
            loadvars = varargin;
            unloadvars = {};
        elseif nargin==2 && iscellstr( varargin{1} )
            loadvars = varargin{1};
            unloadvars = {};
        else
            error('lazyload:invalidArguments', 'Invalid arguments');            
        end
        
        % load variables
        if ~isempty(loadvars)
            
            if ~isvector(loadvars) || ~all(ismember(loadvars,vars))
                error('lazyload:invalidVariables', 'Invalid variable names. Cannot unload')
            end
            
            %which variables should we return
            [tf,idx] = ismember( loadvars, vars );
            idx = idx(tf);
            
            %which variables need to be loaded
            needload = cellfun( 'isempty', data(idx) );
            
            %load
            if sum(needload)>0
                data( idx(needload) ) = struct2cell( load( f, vars{ idx(needload) } ) );
            end
            
            y = cell2struct( data( idx ), vars( idx ), 1 );
            
        end
        
        % unload variables
        if ~isempty(unloadvars)
            
            if ~isvector(unloadvars) || ~all(ismember(unloadvars,vars))
                error('lazyload:invalidVariables', 'Invalid variable names. Cannot load')
            end
            
            %which variables were specified
            [tf,idx] = ismember( unloadvars, vars );
            idx = idx(tf);
            
            %unload
            [data{ idx }] = deal([]);
            
            y = [];
            
        end
        
    end

end