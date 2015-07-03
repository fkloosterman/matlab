classdef ConsoleHandler < logging.Handler
   
    methods
        
        function obj = ConsoleHandler(varargin)
            obj = obj@logging.Handler(varargin{:});
        end
        
        function emit(obj, logrecord)
            if obj.enabled && logrecord.levelno>=obj.level
                msg = obj.formatmessage( logrecord );
                fprintf( 1, '%s\n', msg );
            end
        end
        
    end
    
     methods (Static=true)
       
        function obj = struct2handler(s)
            
            obj = feval( s.class, 'level', s.level, 'format', s.format, 'dateformat', s.dateformat, 'enabled', s.enabled );
            
        end
        
     end
    
    
end

