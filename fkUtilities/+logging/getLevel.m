function val=getLevel(val)

if ~ischar(val)
    error('logging:getLevel:invalidArgument', 'Invalid level')
end

val = find( strcmp( val, logging.Logger.levels ) );

if isempty( val )
    error('logging:getLevel:invalidArgument', 'Invalid level')
end

