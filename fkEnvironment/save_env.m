function save_env( rootdir, env )

if ~ischar( rootdir ) || ~exist( rootdir, 'dir' )
    error('save_env:invalidArgument', 'Invalid root directory')
end

if ~isstruct(env)
    error('save_env:invalidArgument', 'Invalid environment struct')
end

if ~exist( fullfile(rootdir, 'environment' ), 'dir' )
    [ret, msg, msgid] = mkdir(rootdir, 'environment');%#ok
end

c = configobj( env );
write( c, fullfile( rootdir, 'environment', 'environment.def' ) );
