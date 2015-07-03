function [env, filename] = load_env( rootdir )

if ~ischar( rootdir ) || ~exist( rootdir, 'dir' )
    error('load_env:invalidArgument', 'Invalid root directory')
end


filename = fullfile(rootdir, 'environment', 'environment.def');
if exist( filename, 'file' )
    env = config2struct( configobj(filename) );
    return
else
    filename = fullfile(rootdir, 'environment', 'environment2.mat'); %old style
    if exist( filename, 'file' )
        env = load( filename );
        %save as new style
        save_env( rootdir, env );
        return
    end
end

filename = '';

%create default environment
env_pixel_size = [328 254];

env = struct( 'info', struct( 'description', '', 'env_size', env_pixel_size, ...
    'scale', 1, 'rotation', 0, 'diode_distance', NaN, 'units', 'pixels') );

env.transforms = struct( 'Timgflip', '', ...
    'Timg', '', ...
    'Tposflip', '', ...
    'Tworld', '');

env.video.registration = struct( 'rotation', 0, 'scale', [1 1], 'translation', [0 0] );

env.env = struct('tracks', {{}}, 'fields', {{}}, 'objects', {{}});
