classdef FileHandler < logging.Handler
    
    properties
        path = '';
        file = '';
    end
    
    methods
        
        function obj = FileHandler(file, varargin)
            
            if nargin<1 || isempty(file) || ~ischar(file)
                error('FileHandler:FileHandler:invalidFile', 'Invalid file')
            end
            
            [filepath,file,ext] = fileparts( file );
            
            obj = obj@logging.Handler( varargin{:} );
            
            obj.path = filepath;
            obj.file = [file ext];
            
        end
        
        function set.path(obj,val)
            if ~isempty(val) && (~ischar(val) || ~exist(val,'dir'))
            end
            obj.path = fullpath( val );
        end
        
        function set.file(obj,val)
            if ~ischar(val) || isempty(val)
            end
            obj.file = val;
        end
        
        function emit(obj, logrecord)
            
            if obj.enabled && logrecord.levelno>=obj.level
            
                msg = obj.formatmessage( logrecord );
                fid = fopen( fullfile( obj.path, obj.file ), 'a' );
                fprintf(fid, '%s\n', msg);
                fclose(fid);
                
            end
            
        end
        
        function s = handler2struct( obj )
            
            s = handler2struct@logging.Handler(obj);
            s.path = obj.path;
            s.file = obj.file;
            
        end
        
    end
    
    methods (Static=true)
       
        function obj = struct2handler(s)
            
            obj = feval( s.class, fullfile( s.path, s.file ), 'level', s.level, 'format', s.format, 'dateformat', s.dateformat, 'enabled', s.enabled );
            
        end
        
    end
    
end