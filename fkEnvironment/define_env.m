function tracks = define_env( tracks, varargin)

options = struct( 'image', [], 'imagesize', [], 'position', [] );
options = parseArgs(varargin,options);

%check image
if ~isempty(options.image)
  
  if ~isnumeric(options.image) || ndims(options.image)>3
    error('define_env:invalidArgument', 'Invalid image')
  elseif size(options.image,3)>1
    options.image = rgb2gray(options.image);
  end
  
  if isempty(options.imagesize)
    options.imagesize = [0 0 ; fliplr(size(options.image))-1]';
  elseif ~isnumeric(options.imagesize) || ndims(options.imagesize)>2 || ...
        ~isequal(size(options.imagesize),[2 2])
    error('define_env:invalidArgument', 'Invalid image size')
  end
  
end

%check position
if ~isempty(options.position) && (~isnumeric(options.position) || ndims(options.position)>2 ...
                              || size(options.position,2)~=2)
  error('define_env:invalidArgument', 'Invalid position data')
end

%set up figure / axes / controls
hFig = figure('colormap',gray(256));
hLayout = layoutmanager( hFig, 1, 2, 'width', [1 -30], 'fcn', @uipanel );
hControls = layoutmanager( hLayout(2), 2, 1, 'height', [1 -15],'fcn', @uipanel );

hAx = axes('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Parent', hLayout(1) );

hList = uicontrol('Style', 'listbox', 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.9], 'Parent', hControls(1));

hListener = addlistener( hList, 'Value', 'PostSet', @select_track );

%load icons
bg = [0.7 0.7 0.7];
icons = {'track1.png','track2.png','track3.png','track4.png','field1.png','field2.png','field3.png','object1.png','object2.png','object3.png'};
icons = cellfun( @(x) imread( fullfile( fileparts( mfilename( 'fullpath' ) ), x ), 'BackgroundColor', bg ), icons, 'UniformOutput', false );

pixpos = getpixelposition( hControls(2) );

uicontrol( 'Units', 'pixels', 'Position', [5 pixpos(4)-21 pixpos(3)-10 15], 'Parent', hControls(2), 'Style', 'text', 'String', 'Actions', 'HorizontalAlignment', 'left', 'BackgroundColor', [0.5 0.5 0.5], 'ForegroundColor', [0.9 0.9 0.9], 'FontWeight', 'bold' );
hBtn(1) = uicontrol('Units', 'pixels', 'Position', [15+2*(pixpos(3)-20)/3 pixpos(4)-42 (pixpos(3)-20)/3 20], 'Parent', hControls(2), 'String', 'Delete', 'ForegroundColor', [1 0 0], 'Callback', @delete_track);
hBtn(2) = uicontrol('Units', 'pixels', 'Position', [10+(pixpos(3)-20)/3 pixpos(4)-42 (pixpos(3)-20)/3 20], 'Parent', hControls(2), 'String', 'Rename', 'ForegroundColor', [0 0 1], 'Callback', @rename_track);
hBtn(3) = uicontrol('Units', 'pixels', 'Position', [5 pixpos(4)-42 (pixpos(3)-20)/3 20], 'Parent', hControls(2), 'String', 'Edit', 'ForegroundColor', [0 0 1], 'Callback', @edit_track);

uicontrol( 'Units', 'pixels', 'Position', [5 pixpos(4)-63 pixpos(3)-10 15], 'parent', hControls(2), 'Style', 'text', 'String', 'New track', 'HorizontalAlignment', 'left', 'BackgroundColor', [0.5 0.5 0.5], 'ForegroundColor', [0.9 0.9 0.9], 'FontWeight', 'bold'  );
hBtn(4) = uicontrol('Units', 'pixels', 'Position', [5 pixpos(4)-96 32 32], 'Parent', hControls(2), 'CData', icons{1}, 'TooltipString', 'Linear track', 'Callback', @(src,ev) add_track('track', 'linear_track'), 'BackgroundColor', bg );
hBtn(5) = uicontrol('Units', 'pixels', 'Position', [42 pixpos(4)-96 32 32], 'Parent', hControls(2), 'CData', icons{2}, 'TooltipString', 'Circular track', 'Callback', @(src,ev) add_track('track', 'circular_track'), 'BackgroundColor', bg );
hBtn(6) = uicontrol('Units', 'pixels', 'Position', [79 pixpos(4)-96 32 32], 'Parent', hControls(2), 'CData', icons{3}, 'TooltipString', 'Rectangular track', 'Callback', @(src,ev) add_track('track', 'rectangular_track'), 'BackgroundColor', bg );
hBtn(7) = uicontrol('Units', 'pixels', 'Position', [116 pixpos(4)-96 32 32], 'Parent', hControls(2), 'CData', icons{4}, 'TooltipString', 'Complex track', 'Callback', @(src,ev) add_track('track', 'complex_track'), 'BackgroundColor', bg );

uicontrol( 'Units', 'pixels', 'Position', [5 pixpos(4)-117 pixpos(3)-10 15], 'parent', hControls(2), 'Style', 'text', 'String', 'New field', 'HorizontalAlignment', 'left', 'BackgroundColor', [0.5 0.5 0.5], 'ForegroundColor', [0.9 0.9 0.9], 'FontWeight', 'bold'  );
hBtn(8) = uicontrol('Units', 'pixels', 'Position', [5 pixpos(4)-150 32 32], 'Parent', hControls(2), 'CData', icons{5}, 'TooltipString', 'Circular field', 'Callback', @(src,ev) add_track('field', 'circular_env'), 'BackgroundColor', bg );
hBtn(9) = uicontrol('Units', 'pixels', 'Position', [42 pixpos(4)-150 32 32], 'Parent', hControls(2), 'CData', icons{6}, 'TooltipString', 'Rectangular field', 'Callback', @(src,ev) add_track('field', 'rectangular_env'), 'BackgroundColor', bg );
hBtn(10) = uicontrol('Units', 'pixels', 'Position', [79 pixpos(4)-150 32 32], 'Parent', hControls(2), 'CData', icons{7}, 'TooltipString', 'Custom field', 'Callback', @(src,ev) add_track('field', 'linear_env','isclosed',true,'allowclose',false), 'BackgroundColor', bg );

uicontrol( 'Units', 'pixels', 'Position', [5 pixpos(4)-171 pixpos(3)-10 15], 'parent', hControls(2), 'Style', 'text', 'String', 'New object', 'HorizontalAlignment', 'left', 'BackgroundColor', [0.5 0.5 0.5], 'ForegroundColor', [0.9 0.9 0.9], 'FontWeight', 'bold'  );
hBtn(11) = uicontrol('Units', 'pixels', 'Position', [5 pixpos(4)-204 32 32], 'Parent', hControls(2), 'CData', icons{8}, 'TooltipString', 'Circular object', 'Callback', @(src,ev) add_track('object','circle'), 'BackgroundColor', bg );
hBtn(12) = uicontrol('Units', 'pixels', 'Position', [42 pixpos(4)-204 32 32], 'Parent', hControls(2), 'CData', icons{9}, 'TooltipString', 'Rectangular object', 'Callback', @(src,ev) add_track('object', 'rectangle'), 'BackgroundColor', bg );
hBtn(13) = uicontrol('Units', 'pixels', 'Position', [79 pixpos(4)-204 32 32], 'Parent', hControls(2), 'CData', icons{10}, 'TooltipString', 'Polyline object', 'Callback', @(src,ev) add_track('object', 'polyline'), 'BackgroundColor', bg );

axis( hAx, 'equal' );

%plot image and position data
if ~isempty(options.image)
  hImg = imagesc( 'XData', options.imagesize(1,:), 'YData', options.imagesize(2,:), ...
                  'CData', options.image, 'parent', hAx, 'hittest', 'off'); %#ok
end
if ~isempty(options.position)
  hData = line( options.position(:,1), options.position(:,2), 'parent', hAx, 'color', [1 0.5 0.25], 'hittest', 'off'); %#ok
end

xl = get( hAx, 'Xlim' );
yl = get( hAx, 'YLim' );

set( hAx, 'XLim', xl + [-0.1 0.1].*diff(xl), 'YLim', yl + [-0.1 0.1].*diff(yl) );

objects = cell(0,3);

if nargin>=1 && ~isempty(tracks)
 
    for k=1:numel(tracks.tracks)
        objects(k,:) = {'track', tracks.tracks{k}, local_plot('track', tracks.tracks{k})};
    end
    for k=1:numel(tracks.fields)
        objects(end+1,:) = {'field', tracks.fields{k}, local_plot('field', tracks.fields{k})};
    end
    for k=1:numel(tracks.objects)
        objects(end+1,:) = {'object', tracks.objects{k}, local_plot('object', tracks.objects{k})};
    end
    
    update_listbox();
    select_track();
end

uiwait( hFig );

tracks = struct('tracks',{{}},'fields',{{}},'objects',{{}});

ii = strcmp( 'track', objects(:,1) );
tracks.tracks = objects(ii,2);
ii = strcmp( 'field', objects(:,1) );
tracks.fields = objects(ii,2);
ii = strcmp( 'object', objects(:,1) );
tracks.objects = objects(ii,2);

    function update_listbox()
        s = cellfun( @(x,y) [x ' - ' y.name], objects(:,1), objects(:,2), 'UniformOutput', false );
        set( hList, 'String', s );
    end

    function select_track(src,ev)
        %get selection
        idx = get( hList, 'Value' );
        if ~isempty(idx) && idx<=size(objects,1)
            set( [objects{:,3}], 'Selected', 'off');
            set( objects{idx,3}, 'Selected', 'on' );
        end
    end

    function rename_track(src,ev)
        %get selection
        idx = get( hList, 'Value');
        if ~isempty(idx) && idx<=size(objects,1)
            answer = inputdlg( {'Name'}, 'Provide new name', 1, {objects{idx,2}.name} );
            if ~isempty(answer)
                objects{idx,2}.name = answer{1};
            end
            update_listbox();
        end
    end

    function delete_track(src,ev)
        %get selection
        idx = get( hList, 'Value');
        %delete track
        if ~isempty(idx) && idx<=size(objects,1)
            delete( objects{idx,3} );
            delete( objects{idx,2} );
            objects(idx,:) = [];
        end
        %update listbox
        update_listbox();
        %set selection
        set( hList, 'Value', min( idx, size(objects,1) ) );
        select_track();
    end

    function edit_track(src,ev)
        %get selection
        idx = get( hList, 'Value');
        if ~isempty(idx) && idx<=size(objects,1)
            %disable buttons, delete plotted track/object
            set( hBtn, 'Enable', 'off');
            delete( objects{idx,3} );

            %edit track/object
            switch objects{idx,1}
                case {'track','field'}
                    objects{idx,2}.edit('parent', hAx);
                case {'object'}
                    objects{idx,2} = define_shape( objects{idx,2}, 'parent', hAx, 'Color', [0 0.5 0] );
            end
            
            %enable buttons, plot track/object, update selection
            set( hBtn, 'Enable', 'on');
            objects{idx,3} = local_plot( objects{idx,1}, objects{idx,2} );
            select_track();
        end
    end

    function add_track(obj_type, obj_class, varargin)
        %disable buttons & turn selection off
        set( hBtn, 'Enable', 'off');
        set( [objects{:,3}], 'Selected', 'off');

        %define track
        switch obj_type
            case {'track'}
                tmp = eval( [obj_class '.define(varargin{:}, ''parent'', hAx, ''position'', options.position, ''Color'', [0 0 1] );'] );
            case {'field'}
                tmp = eval( [obj_class '.define(varargin{:}, ''parent'', hAx, ''position'', options.position, ''Color'', [1 0.5 0.5] );'] );
            case {'object'}
                tmp = define_shape( obj_class, 'parent', hAx, 'Color', [0 0.5 0] );
        end
        
        %save and plot
        if ~isempty(tmp)
            objects(end+1,:) = {obj_type, tmp, local_plot(obj_type,tmp)};
        end
        
        %enable buttons, update listbox, update selection
        set( hBtn, 'Enable', 'on');
        update_listbox();
        set( hList, 'Value', size(objects,1) );
        select_track();
    end
        

    function h = local_plot( env_type, obj )
       
        switch env_type
            case {'track'}
                h = obj.plot( 'parent', hAx, 'Color', [0 0 1], 'LineWidth', 2 );
            case {'field'}
                h = obj.plot( 'parent', hAx, 'Color', [1 .5 .5], 'LineWidth', 2 );
            case 'object'
                h = obj.plot( 'parent', hAx, 'Color', [0 0.5 0], 'LineWidth', 2 );
        end
        
    end

end