function env = process_env(rootdir)
%PROCESS_ENV process environment
%
%  PROCESS_ENV(rootdir) lets the user specify the transformations between
%  the video image, the position data and the world coordinate
%  system. The procedure is as follows: both position and video image are
%  vertically flipped to make (0,0) the bottom-left corner. The user will
%  then register the video image to the position data, define the outline
%  and regions/segments that make up the environment and define the
%  trajectories. Finally the world transformation can be specified.
%

%  Copyright 2007-2008 fabian Kloosterman

%% create logger
sink = logging.FileHandler( fullfile( rootdir, 'logs', [mfilename '.log']), 'format', '[level] [date]::[id]::[msg]' );
logger = logging.Logger( mfilename, 'parent', 'fkPreProcessing', 'handlers', sink );

%% check arguments
if nargin<1 || isempty(rootdir)
    rootdir = pwd;
elseif ~ischar(rootdir) || ~exist(rootdir,'dir')
    logger.error( 'Invalid root directory' );
    error('process_env:invalidArgument', 'Invalid root directory'); %#ok
else
    rootdir = fullpath( rootdir );
    logger.info('Defining environment for %s', rootdir );
end

%% setting up default environment

[env, src] = load_env( rootdir );

if ~isempty(src)
    logger.info( 'Environment definition loaded from %s', src );
end

%% load behavior and video
if exist( fullfile(rootdir, 'position', 'behavior.p'), 'file' )
    f = mwlopen( fullfile(rootdir, 'position', 'behavior.p') );
    data = load(f);
    logger.info('Loaded behavior from behavior.p')    
    f = mwlopen( fullfile(rootdir, 'position', 'position.p') );
    tmp = load( f, {'diode1', 'diode2'} );
    data.diode1 = tmp.diode1;
    data.diode2 = tmp.diode2;
    logger.info('Loaded diode positions from position.p')
elseif exist( fullfile(rootdir, 'position', 'position.p'), 'file' )
    f = mwlopen( fullfile(rootdir, 'position', 'position.p') );
    data = load(f);
    logger.info('Loaded behavior and diode positions from position.p')
else
    error('fkEnvironment:process_env:noData', 'No position data')
end

%load video image if available
video = import_video( rootdir );
if isempty( video.video.still )
    logger.info('No video image found for %s', rootdir)
    img = [];
else
    logger.info('Video image found for %s', rootdir)
    img = video.video.still;
    if size(img,3)>1
        img = rgb2gray(img);
    end
end

Tposflip = TransformStack();
Tposflip.scale( [1 -1] );
Tposflip.translate( [0 env.info.env_size(2)+1] );

%transform position
pos = Tposflip.transform( data.headpos' );

logger.info( 'Transformed position: vertical flip and translate by %d', env.info.env_size(2)+1 );

%% register image with position data (Timg)
Timgflip = TransformStack();
Timg = TransformStack();
if ~isempty( img )
    
    answer = questdlg('Perform video image registration?', 'Video registration', 'Yes', 'No', 'Yes' );
    
    if strcmp( answer, 'Yes')
        
        logger.info('Let user register video image with position data.')
        
        Timgflip.scale([1 -1]);
        Timgflip.translate([0 size(img,1)+1]);
        
        %transform image
        img = Timgflip.imgtransform( img );
        
        logger.info( 'Transformed video image: vertical flip and translate by %d', size(img,1)+1 );
        
        %let user register image manually by scaling, rotation
        %and translation
        env.video.registration = registerimage( img, pos, ...
            'Scale', env.video.registration.scale,...
            'Translate', env.video.registration.translation,...
            'Rotate', env.video.registration.rotation);
        
        logger.info('Video image transformation: rotation = %f, scaling = [%f %f], translation = [%f %f]', env.video.registration.rotation, env.video.registration.scale, env.video.registration.translation );
        
        Timg.rotate( env.video.registration.rotation );
        Timg.scale( env.video.registration.scale );
        Timg.translate( env.video.registration.translation );
        
        %transform the image
        [img, xdata, ydata] = Timg.imgtransform( img );
        
    end
    
else
    
    logger.info('No video image, so no registration with position data needed.')
    
    img = [];
    xdata = NaN(1,2);
    ydata = xdata;
    
end

%% Define tracks, fields and objects
answer = questdlg('Define tracks, fields and/or objects?', 'Define tracks', 'Yes', 'No', 'Yes' );

if strcmp( answer, 'Yes')
    
    %Define tracks / fields / objects
    env.env.tracks = cellfun( @(x) env_base.fromstruct(x), env.env.tracks, 'UniformOutput', false );
    env.env.fields = cellfun( @(x) env_base.fromstruct(x), env.env.fields, 'UniformOutput', false );
    env.env.objects = cellfun( @(x) shape_base.fromstruct(x), env.env.objects, 'UniformOutput', false );
    
    env.env = define_env( env.env, 'position', pos, 'image', img, 'imagesize', [xdata;ydata] );
    
    env.env.tracks = cellfun( @(x) x.tostruct(), env.env.tracks, 'UniformOutput', false );
    env.env.fields = cellfun( @(x) x.tostruct(), env.env.fields, 'UniformOutput', false );
    env.env.objects = cellfun( @(x) x.tostruct(), env.env.objects, 'UniformOutput', false );
    
end

%% let user specify scale factor (assume pixels are square)
answer = questdlg( sprintf( 'The current scaling factor is: %f %s/pixel. Choose to determine scaling manually or based on diode distance or leave as is.', env.info.scale, env.info.units ), 'Environment scaling', 'Manual', 'Diode', 'Leave as is', 'Leave as is' );

switch answer
    case 'Manual'
        
        tmp = inputdlg({'Scale factor', 'Units after scaling'}, 'Scale factor', 1, {num2str(env.info.scale) env.info.units} );
        
        if ~isempty( tmp )
            newscale = str2double( tmp{1} );
            if isnan(newscale) || newscale<=0
                logger.warning('Invalid scaling factor entered. Scaling factor has not been changed')
            else
                env.info.scale = newscale;
                env.info.units = tmp{2};
                if isempty(env.info.units), env.info.units='pixels'; end;
                logger.info( 'Manually set scaling factor to %f %s/pixel', env.info.scale, env.info.units );
            end
           
        else
            
            logger.info( 'Scaling factor unchanged (%f %s/pixel)', env.info.scale, env.info.units );
            
        end
        
    case 'Diode'
        
        tmp = inputdlg({'Diode distance', 'Units after scaling'}, 'Scale factor', 1, {num2str(env.info.diode_distance) env.info.units});
        
        if ~isempty(tmp)
            newdiodedist = str2double(tmp{1});
            if isnan(newdiodedist) || newdiodedist<=0
                logger.warning('Invalid diode distance entered. Scaling factor has not been changed')
            else
                env.info.diode_distance = newdiodedist;
                env.info.units = tmp{2};
                if isempty(env.info.units), env.info.units='pixels'; end;
                
                %compute 90th percentile of diode distance
                dd = sqrt( sum( (data.diode2 - data.diode1).^2 ) );
                m = prctile( dd(~isnan(dd)), 90 );
                
                %compute scale factor as: user specified diode distance ./ 90th percentile
                env.info.scale = env.info.diode_distance ./ m;
                
                logger.info( 'Set scaling factor to %f %s/pixel, assuming 90th percentile of diode distance distribution in pixels = %f %s', env.info.scale, env.info.units, env.info.diode_distance, env.info.units );
            end

        else
            
            logger.info( 'Scaling factor unchanged (%f %s/pixel)', env.info.scale, env.info.units );
            
        end

        
    otherwise
        
        logger.info( 'Scaling factor unchanged (%f %s/pixel)', env.info.scale, env.info.units );

end

%% other info (description, world rotation)

tmp = inputdlg({'Environment description', 'Rotation of environment (radians)'}, 'Environment information', 1, {env.info.description num2str(env.info.rotation)});
if ~isempty(tmp)
    newrotation = str2double( tmp{2} );
    if isnan(newrotation)
        logger.warning('Invalid rotation entered. Rotation of environment has not been changed')
    else
        env.info.rotation = limit2pi( newrotation );
    end
    env.info.description = tmp{1};
    
    logger.info( 'Environment description = %s, environment rotation = %f PI', env.info.description, env.info.rotation./pi );
    
else
    logger.info( 'Environment information unchanged: description = %s, environment rotation = %f PI', env.info.description, env.info.rotation./pi );
end

%% construct transformations

%create world transformation matrix
Tworld = TransformStack();
Tworld.rotate( env.info.rotation );
Tworld.scale( env.info.scale );

%save transformation matrices
env.transforms.Timgflip = Timgflip.tostr();
env.transforms.Timg = Timg.tostr();
env.transforms.Tposflip = Tposflip.tostr();
env.transforms.Tworld = Tworld.tostr();

%% save environment definition to file
save_env( rootdir, env );
logger.info('Saved environment definition')
        
%% obsolete        
        
% %--LOCAL FUNCTION FOR ACTUAL PROCESSING---
% 
% env = struct( [] );
% env_pixel_size = [328 254];
% 
%     function local_process()
% 
%         %create environment directory
%         if ~exist( fullfile(rootdir, 'environment' ), 'dir' )
%             verbosemsg('Creating environment directory...')
%             [ret, msg, msgid] = mkdir(rootdir, 'environment');%#ok
%         end
%   
%         %load prior environment definition
%         filename = fullfile(rootdir, 'environment', 'environment2.mat');
%         if exist( filename, 'file' )
%             verbosemsg(['Loading previous environment definition from ' filename])    
%             env = load( filename );
%             LOG.modify = true;
%         end
%         
%         %load behavior
%         if exist( fullfile(rootdir, 'position', 'behavior.p'), 'file' )
%             verbosemsg('Loading behavior from behavior.p')
%             f = mwlopen( fullfile(rootdir, 'position', 'behavior.p') );
%             data = load(f);
%             verbosemsg('Loading diode positions from position.p')            
%             f = mwlopen( fullfile(rootdir, 'position', 'position.p') );
%             tmp = load( f, {'diode1', 'diode2'} );
%             data.diode1 = tmp.diode1;
%             data.diode2 = tmp.diode2;
%         elseif exist( fullfile(rootdir, 'position', 'position.p'), 'file' )
%             verbosemsg('Loading behavior and diode positions from position.p')    
%             f = mwlopen( fullfile(rootdir, 'position', 'position.p') );
%             data = load(f);
%         else
%             error('fkEnvironment:process_env:noData', 'No position data')
%         end
%         
%         %load video image if available
%         video = import_video( rootdir );
%         LOG.video = false;
%         if isempty( video.video.still )
%             verbosemsg('Video image NOT present...')
%             img = [];
%         else
%             verbosemsg('Video image present...')
%             img = video.video.still;
%             if size(img,3)>1
%                 img = rgb2gray(img);
%             end
%             LOG.video = true; 
%         end
%         
%         verbosemsg('Vertical flip transformation of position...')  
%   
%         Tposflip = TransformStack();
%         Tposflip.scale( [1 -1] );
%         Tposflip.translate( [0 env_pixel_size(2)+1] );
%         
%         %transform position
%         pos = Tposflip.transform( data.headpos' );
%         
%         %register image with position data (Timg)
%         Timgflip = TransformStack();
%         Timg = TransformStack();
%         if ~isempty( img )
% 
%             verbosemsg('Registering video image with position data...')
%             
%             Timgflip.scale([1 -1]);
%             Timgflip.translate([0 size(img,1)+1]);
% 
%             %transform image
%             img = Timgflip.imgtransform( img );
%             
%             %let user register image manually by scaling, rotation
%             %and translation
%             env.video.registration = registerimage( img, pos, ...
%                 'Scale', env.video.registration.scale,...
%                 'Translate', env.video.registration.translation,...
%                 'Rotate', env.video.registration.rotation);
%                     
%             LOG.registration.method = 'manual';
%             LOG.registration.rotation = env.video.registration.rotation;
%             LOG.registration.scale = env.video.registration.scale;
%             LOG.registration.translation = env.video.registration.translation;
%   
%             Timg.rotate( env.video.registration.rotation );
%             Timg.scale( env.video.registration.scale );
%             Timg.translate( env.video.registration.translation );
%             
%             %transform the image
%             [img, xdata, ydata] = Timg.imgtransform( img );
%             
%         else
%     
%             img = [];
%             xdata = NaN(1,2);
%             ydata = xdata;
%     
%         end
% 
%         %ask for general information
%         tmp = input(['Environment description [default=' env.info.description ']: '], 's');
%         if ~isempty(tmp), env.info.description = tmp; end
%         
%         LOG.description = env.info.description;
%         
%         %Define tracks / fields / objects
%         env.env.tracks = cellfun( @(x) env_base.fromstruct(x), env.env.tracks, 'UniformOutput', false );
%         env.env.fields = cellfun( @(x) env_base.fromstruct(x), env.env.fields, 'UniformOutput', false );
%         env.env.objects = cellfun( @(x) shape_base.fromstruct(x), env.env.objects, 'UniformOutput', false );
%         
%         env.env = define_env( env.env, 'position', pos, 'image', img, 'imagesize', [xdata;ydata] );
%         
%         env.env.tracks = cellfun( @(x) x.tostruct(), env.env.tracks, 'UniformOutput', false );
%         env.env.fields = cellfun( @(x) x.tostruct(), env.env.fields, 'UniformOutput', false );
%         env.env.objects = cellfun( @(x) x.tostruct(), env.env.objects, 'UniformOutput', false ); 
%         
%         verbosemsg('World transformation...')
%         %let user specify rotation of environment
%         answer = input(['Rotation of environment in radians [default=' num2str(env.info.rotation)  ']: ']);
%         if ~isempty(answer)
%             env.info.rotation = double( answer );
%         end
% 
%         LOG.world.rotation = env.info.rotation;
% 
%         
%         %let user specify scale factor (assume pixels are square)
%         answer = input(['The current scaling factor is: ' num2str(env.info.scale) ' ' env.info.units '/pixel\nChoose method to determine scaling of environent: \n1. leave as is\n2. ' ...
%             'enter factor manually\n3. enter diode distance\nEnter choice [default=leave as is]: '], ...
%             's');
% 
%         switch answer
%             case {'2', 'manual'}
%                 tmp = input(['Scale factor [default=' num2str(env.info.scale) ']: ']);
%                 if isempty(tmp)
%                     %pass
%                 elseif ~isnumeric(env.info.scale) || ~isscalar(env.info.scale) || env.info.scale<=0
%                   error('process_env:invalidScale', 'Invalid scaling factor')
%                 else
%                     env.info.scale = tmp;
%                 end
%                 
%                 tmp = input(['Environment units after scaling [default=' env.info.units ']: '], 's');
%                 if ~isempty(tmp), env.info.units = tmp; end
%                 
%                 LOG.world.scalemethod = 'manual';
%                 
%              case {'3', 'diode'}
%                 tmp = input(['Diode distance [default=' num2str(env.info.diode_distance) ']: ']);
%                 if isempty(tmp)
%                     %pass
%                 elseif ~isnumeric(env.info.diode_distance) || ~isscalar(env.info.diode_distance) || env.info.diode_distance<=0
%                   error('process_env:invalidDistance', 'Invalid diode distance')
%                 else
%                     env.info.diode_distance = tmp;
%                 end
%     
%                 %compute 90th percentile of diode distance
%                 dd = sqrt( sum( (data.diode2 - data.diode1).^2 ) );
%                 m = prctile( dd(~isnan(dd)), 90 );
%                 
%                 %m = nanmedian( sqrt( sum( (data.diode2 - data.diode1).^2 ) ) );
%     
%                 %compute scale factor as: user specified diode distance ./
%                 %90th percentile
%                 env.info.scale = env.info.diode_distance ./ m;
%                   
%                 tmp = input(['Environment units after scaling [default=' env.info.units ']: '], 's');                                
%                 if ~isempty(tmp), env.info.units = tmp; end
%                 
%                 LOG.world.scalemethod = 'diode';
%                 
%             otherwise
% 
%                 %env.scale = 1;
%                 %env.units = '';
% 
%                 LOG.world.scalemethod = 'none';
%                 
%         end
% 
%         if isempty( env.info.units )
%           env.info.units = 'pixels';
%         end
%            
%         LOG.world.scale = env.info.scale;
%         LOG.world.units = env.info.units;
%         
%         
%         %create world transformation matrix
%         Tworld = TransformStack();
%         Tworld.rotate( env.info.rotation );
%         Tworld.scale( env.info.scale );
% 
%         %save transformation matrices
%         env.transforms.Timgflip = Timgflip.tostr();
%         env.transforms.Timg = Timg.tostr();
%         env.transforms.Tposflip = Tposflip.tostr();
%         env.transforms.Tworld = Tworld.tostr();
%         
%         %save environment definition to file
%         verbosemsg('Saving environment definition...')
%         
%         save(fullfile(rootdir, 'environment', 'environment2.mat'),'-struct','env');
%   
%     end
%         
% %--LOCAL FUNCTION FOR ARGUMENT CHECKING---
% 
%     function local_check_args()
% 
%         %check root directory
%         if ~exist('rootdir', 'var')
%           rootdir = pwd;
%         elseif ~ischar(rootdir) || ~exist(rootdir,'dir')
%             error('process_env:invalidArgument', 'Invalid root directory')
%         else
%             rootdir = fullpath( rootdir );
%         end
% 
%         LOG_ARGS = {'rootdir', rootdir};
%         LOG_DESCRIPTION = 'define environment';
% 
%         %setting up default environment
%         env = struct( 'info', struct( 'description', '', 'env_size', env_pixel_size, ...
%               'scale', 1, 'rotation', 0, 'diode_distance', NaN, 'units', 'pixels') );
% 
%         env.transforms = struct( 'Timgflip', '', ...
%                                  'Timg', '', ...
%                                  'Tposflip', '', ...
%                                  'Tworld', '');
% 
%         env.video.registration = struct( 'rotation', 0, 'scale', [1 1], 'translation', [0 0] );
% 
%         env.env = struct('tracks', {{}}, 'fields', {{}}, 'objects', {{}});
%         
%     end
% 
% %---END OF LOCAL FUNCTIONS---
% 
% %-------------------------------------------------------------------
% 
% %---START OF DIAGNOSTICS/VERBOSE/ARGUMENT CHECKING LOGIC---
% 
% local_check_args();
% 
% %---VERBOSE---
% VERBOSE_MSG_ID = mfilename; %#ok
% VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
% %---VERBOSE---
% 
% %---M-FILE DEVELOPMENT STATUS---
% MODIFICATION_DATE = '$Date: 2009-10-06 20:20:18 -0400 (Tue, 06 Oct 2009) $';
% REVISION = '$Revision: 2254 $';
% MFILE_DEV_STATUS = regexp( [MODIFICATION_DATE REVISION], ['\$Date: (?<modification_date>.*) \$\$Revision: (?<revision>[0-9]+) \$'], 'names'); %#ok
% %---M-FILE DEVELOPMENT STATUS---
% 
% %---DIAGNOSTICS---
% LOGFILE = diagnostics( fullfile(rootdir, 'logs', [mfilename '.log']) );
% if ~exist('LOG_ARGS','var')
%     LOG_ARGS = {};
% end
% if ~exist('LOG_DESCRIPTION','var')
%     LOG_DESCRIPTION='none';
% end
% LOG = new_diagnostics_log( LOG_DESCRIPTION, LOG_ARGS{:} );
% %---DIAGNOSTICS---
% 
% errobj = [];
% 
% try
% 
%     local_process();
%     
%     %---DIAGNOSTICS---
%     LOG.status = 'complete';
%     LOGFILE = addlog( LOGFILE, LOG );
%     %---DIAGNOSTICS---
%     
% catch
%    
%     %get error
%     errobj = lasterror;
%   
%     %---DIAGNOSTICS---
%     LOG.status = 'fail';
%     LOG.ERROR = configobj(errobj);
%     LOGFILE = addlog( LOGFILE, setcomment(LOG, 'ABORTED', 'inline') );    
%     %---DIAGNOSTICS---
%   
% end
% 
% %---DIAGNOSTICS---
% write(LOGFILE);
% %---DIAGNOSTICS---
% 
% if ~isempty(errobj)
%     rethrow(errobj);
% end
% 
% end
% 
% 
% 
