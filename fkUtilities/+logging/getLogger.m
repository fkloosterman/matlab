function L = getLogger( id )
%GETLOGGER
%
%  l=GETLOGGER() get root logger (create if doesn't exist)
%
%  l=GETLOGGER(id) get specified logger.
%

L = [];

if ~isappdata(0,'Logging')
    L = logging.Logger();
    return;
else
    loggers = getappdata( 0, 'Logging' );
end

if nargin<1 || isempty(id)
    id = 'root';
elseif ~isvarname( id )
    error('logging:getLogger:invalidID', 'Invalid identifier')
end

try
    L = loggers.(id);
catch ME
    if ( strcmp( ME.identifier, 'MATLAB:nonExistentField' ) )
        if strcmp( id, 'root' )
            L = logging.Logger();
        end
        return
    else
        throw(ME)
    end
end

return

parent = [];


if nargin<1 || isempty(id)
    id = 'root';
elseif ~ischar(id)
    error('logging:getLogger:invalidID', 'Invalid identifier')
elseif ~strncmp(id,'root',4)
    id = ['root.' id];
end

try
    logid = strrep( id, '.', '.children.' );
    L = eval( ['loggers.' logid '.object'] );
catch ME
    if ( strcmp( ME.identifier, 'MATLAB:nonExistentField' ) )
        return
    else
        throw(ME)
    end
end

if ~strcmp(id, 'root' )
    ii = strfind( id, '.' );
    id = id(1:(ii(end)-1));
    logid = strrep( id, '.', '.children.' );
    parent = eval( ['loggers.' logid '.object'] );
end
