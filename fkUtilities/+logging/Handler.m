classdef Handler < handle
    
    properties
        level = 1;
        format
        dateformat
        enabled = true
    end
    
    methods
        
        function obj = Handler(varargin)
            
            options = struct( 'level', 1, 'format', [], 'dateformat', [], 'enabled', true );
            options = parseArgs( varargin, options );
            
            obj.level = options.level;
            obj.format = options.format;
            obj.dateformat = options.dateformat;
            obj.enabled = options.enabled;
            
        end
        
        function set.enabled(obj,val)
            if ~isscalar(val) || ~(isnumeric(val) || islogical(val))
                error('Handler:setenabled:invalidValue', 'Invalid value for enabled property')
            end
            obj.enabled = isequal( val, true );
        end
        
        function set.level(obj,val)
            if isempty(val)
                obj.level = 1;
            elseif ischar(val)
                ii = find( strcmp( val, logging.Logger.levels ) );
                if isempty(ii)
                    error('Handler:setlevel:invalidValue', 'Invalid level')
                else
                    obj.level = ii;
                end
            elseif ~isscalar(val) || ~isnumeric(val) || val<1 || val>numel(logging.Logger.levels)
                error('Handler:setlevel:invalidValue', 'Invalid level')
            else
                obj.level = round(val);
            end
        end
        function set.format(obj,val)
            if isempty(val)
                obj.format = [];
            elseif ~ischar(val)
                error('Handler:setformat:invalidValue', 'Invalid format string')
            else
                obj.format = val;
            end
        end
        function set.dateformat(obj,val)
            if isempty(val)
                obj.dateformat = [];
            elseif ~ischar(val)
                error('Handler:setdateformat:invalidValue', 'Invalid date format string')
            else
                obj.dateformat = val;
            end
        end
        
        function msg = formatmessage(obj, logrecord )
            
            data = logrecord.data;
            data.msg = logrecord.message;
            data.id = logrecord.id;
            data.level = logrecord.level;
            data.fcn = logrecord.function;
            data.lineno = logrecord.lineno;
            
            if isempty(obj.dateformat) && isempty(logrecord.default.dateformat)
                data.date = datestr( logrecord.created );
            elseif ~isempty(obj.dateformat)
                data.date = datestr( logrecord.created, obj.dateformat );
            else
                data.date = datestr( logrecord.created, logrecord.default.dateformat );
            end

            if ~isempty( obj.format )
                fmt = obj.format;
            else
                fmt = logrecord.default.format;
            end
            
            keys = fieldnames( data );
            vals = struct2cell( data );
            
            for k=1:numel(keys)
                keys{k} = ['\[' keys{k} '\]'];
            end
            
            msg = regexprep( fmt, keys, vals );
            
        end
        
        function s = handler2struct( obj )
            s = struct( 'class', class(obj), 'level', obj.level, 'format', obj.format, 'dateformat', obj.dateformat, 'enabled', obj.enabled );
        end
        
    end
    
    methods (Static=true)
        
        function obj = struct2handler( s )
            obj = feval( [s.class '.struct2handler'], s );
            %obj.level = s.level;
            %obj.format = s.format;
            %obj.dateformat = s.dateformat;
            %obj.enabled = s.enabled;
        end
        
    end
    
    methods (Abstract=true)
        
        emit(obj)
            
    end
    
end