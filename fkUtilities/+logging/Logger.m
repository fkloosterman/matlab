
classdef Logger < handle
    
    properties (Constant=true)
        levels = {'DEBUG','INFO','WARNING','ERROR','CRITICAL'};
    end
    
    properties
        propagate = true;
        level = logging.getLevel('INFO');
        format = '[level]::[id]::[msg]';
        dateformat = 'dd-mmm-yyyy HH:MM:SS';
        enabled = true;
    end
    
    properties (SetAccess=protected)
        identifier = '';
        handlers = {};
        parent = [];
    end
    
    properties (Access=protected, Hidden=true)
        parentobj = []
        initialized = false;
    end
    
    methods
        
        function obj=Logger(id,varargin)
            
            %check identifier
            if nargin<1 || isempty(id)
                id = 'root';
            elseif ~isvarname( id )
                error('Logger:Logger:invalidID', 'Invalid identifier')
            end

            %logger already exists?
            c = [];
            if isappdata(0,'Logging')
                loggers = getappdata(0,'Logging');
                if isfield( loggers, id )
                    obj = loggers.(id);
                    
                    c = struct( 'propagate', obj.propagate, 'level', obj.level, 'format', obj.format, ...
                        'dateformat', obj.dateformat, 'enabled', obj.enabled, 'handlers', {obj.handlers}, 'parent', obj.parent );
                    
                    %remove all handlers
                    obj.handlers = {};
                    
                end
            end
            
            
            %if not, then get config and fold in optional arguments
            do_register = false;
            if isempty(c)
                c = logging.Logger.get_logger_config( id );
                do_register = true;
            end

            c = parseArgs( varargin, c );
            
            obj.identifier = id;
            obj.propagate = c.propagate;
            obj.level = c.level;
            obj.format = c.format;
            obj.dateformat = c.dateformat;
            obj.enabled = c.enabled;
            
            if isa( c.handlers, 'logging.Handler' )
                for k=1:numel(c.handlers)
                    addHandler( obj, c.handlers(k) );
                end
            elseif iscell(c.handlers)
                for k=1:numel(c.handlers)
                    if isstruct( c.handlers{k} )
                        addHandler(obj, logging.Handler.struct2handler( c.handlers{k} ) );
                    else
                        addHandler(obj, c.handlers{k} );
                    end
                end
            else
                error('Logger:Logger:invalidHandlers', 'Invalid handlers')
            end

            if isa( c.parent, 'logging.Logger' )
                obj.parent = c.parent.identifier;
                obj.parentobj = c.parent;
            elseif isempty(c.parent)
                obj.parent = [];
            elseif ischar(c.parent)
                obj.parent = c.parent;
                obj.parentobj = logging.Logger( c.parent );
            else
                error('Logger:Logger:invalidParent',  'Invalid parent logger')
            end
            
            if do_register
                register(obj);
            end
            
            obj.initialized = true;
            
        end
        function delete(obj)
            
            if obj.initialized
                logging.Logger.set_logger_config( obj );
                unregister( obj );
            end
            
        end
        
        function set.propagate(obj,val)
            if ~isscalar(val) || ~(isnumeric(val) || islogical(val))
                error('Logger:setpropagate:invalidValue', 'Invalid value for propagate property')
            end
            obj.propagate = isequal( val, true );
        end
        function set.level(obj,val)
            if ischar(val)
                ii = find( strcmp( val, logging.Logger.levels ) );
                if isempty(ii)
                    error('Logger:setlevel:invalidValue', 'Invalid level')
                else
                    obj.level = ii;
                end
            elseif ~isscalar(val) || ~isnumeric(val) || val<1 || val>numel(logging.Logger.levels)
                error('Logger:setlevel:invalidValue', 'Invalid level')
            else
                obj.level = round(val);
            end
        end
        function set.format(obj,val)
            if ~ischar(val)
                error('Logger:setformat:invalidValue', 'Invalid format string')
            end
            obj.format = val;
        end
        function set.dateformat(obj,val)
            if ~ischar(val)
                error('Logger:setdateformat:invalidValue', 'Invalid date format string')
            end
            obj.dateformat = val;
        end
        function set.enabled(obj,val)
            if ~isscalar(val) || ~(isnumeric(val) || islogical(val))
                error('Logger:setenabled:invalidValue', 'Invalid value for enabled property')
            end
            obj.enabled = isequal( val, true );
        end
        
        function addHandler(obj,h)
            
            if nargin<2 || ~isa(h, 'logging.Handler') || ~isscalar(h)
                error('Logger:addHandler:invalidObject', 'Invalid handler')
            end
            
            if isempty( obj.handlers )
                obj.handlers = {h};
            elseif ~any( cellfun( @(x) x==h, obj.handlers ) )
                obj.handlers{end+1} = h;
            end

        end
        function removeHandler(obj,h)
            
            if nargin<2 || ~isa(h, 'logging.Handler') || ~isscalar(h)
                error('Logger:removeHandler:invalidObject', 'Invalid handler')
            end
            
            if ~isempty( obj.handlers )
                ii = cellfun( @(x) x==h, obj.handlers );
                obj.handlers(ii) = [];
            end
            
        end
        
        function debug(obj,msg,varargin)
            obj.log(1,msg,varargin{:});
        end
        function info(obj,msg,varargin)
            obj.log(2,msg,varargin{:});
        end
        function warning(obj,msg,varargin)
            obj.log(3,msg,varargin{:});
        end
        function error(obj,msg,varargin)
            obj.log(4,msg,varargin{:});
        end
        function critical(obj,msg,varargin)
            obj.log(5,msg,varargin{:});
        end
        
        function log(obj,lvl,msg,varargin)
            
            if obj.enabled && lvl>=obj.level
                
                if numel(varargin)>0 && isstruct(varargin{end})
                    data = varargin{end};
                    args = varargin(1:end-1);
                else
                    data = struct();
                    args = varargin;
                end
                
                msg = sprintf( msg, args{:} );
                
                d = dbstack('-completenames');
                
                ii = find( ~strncmp( {d.name}, 'Logger', 6 ), 1, 'first' );
                if ~isempty(ii) && ~isempty(strfind( d(ii).file, '+logging' ))
                    ii = ii + 1;
                end
                
                if ~isempty(ii) && ii<=numel(d)
                    fcn = d(ii).name;
                    lineno = num2str(d(ii).line);
                else
                    fcn = 'unknown';
                    lineno = '?';
                end
                
                logrecord = struct( 'function', fcn, 'lineno', lineno, 'created', now, 'id', obj.identifier, ...
                    'levelno', lvl, 'level', logging.Logger.levels{lvl}, 'message', msg, 'data', data, ...
                    'default', struct('format', obj.format, 'dateformat', obj.dateformat) );
                
                for k=1:numel( obj.handlers )
                    
                    obj.handlers{k}.emit( logrecord );
                    
                end
                
                if obj.propagate && ~isempty(obj.parent)
                    
                    if ~isvalid(obj.parentobj)
                        obj.parentobj = logging.Logger(obj.parent);
                    end
                    
                    obj.parentobj.log( lvl, msg, data );
                    
                end
                    
            end
            
        end
        
        function s = logger2struct( obj )

            s = struct( 'parent', obj.parent, ...
                'propagate', obj.propagate, 'level', obj.level, 'format', obj.format, ...
                'dateformat', obj.dateformat, 'enabled', obj.enabled );
            
            s.handlers = cell( numel(obj.handlers), 1 );
            
            for k=1:numel(obj.handlers)
                
                s.handlers{k} = handler2struct( obj.handlers{k} );
                
            end
            
        end
              
    end
    
    methods (Access=private)
        
        function unregister( obj )
            
            loggers = getappdata(0, 'Logging' );
            loggers = rmfield( loggers, obj.identifier );
            setappdata(0, 'Logging', loggers );
            
        end
        function register( obj )
            
            if isappdata(0,'Logging')
                loggers = getappdata(0, 'Logging');
            else
                loggers = struct();
            end
            
            if isfield( loggers, obj.identifier )
                %already registered!!
                warning( 'Logger:register:alreadyRegistered', ['Logger ' obj.identifier ' is already registered'])
            else
                loggers.(obj.identifier) = obj;
                setappdata(0, 'Logging', loggers );
            end
            
        end
        
    end
    
    methods (Static=true)
        
        function c = get_logger_config( id )
            
            if ispref( 'Logging', id )
                c = getpref( 'Logging', id );
            else
                if strcmp( id, 'root' )
                    p = [];
                else
                    p = 'root';
                end
                c = struct( 'parent', p, 'propagate', true, 'level', 2, 'format', '[level]::[id]::[msg]', 'dateformat', 'dd-mmm-yyyy HH:MM:SS', 'handlers', {{}}, 'enabled', true );
            end
            
        end
        function set_logger_config( obj )
            
            c = logger2struct( obj );
            
            setpref( 'Logging', obj.identifier, c );
            
        end
        
    end
    
end