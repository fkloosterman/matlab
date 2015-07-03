function shape = define_shape( shape, varargin)

options = struct( 'parent', [] );
[options,~,remainder] = parseArgs(varargin,options);

delete_fig = false;

%set up figure / axes / controls
if isempty( options.parent )
    hFig = figure('colormap', gray(256), 'Interruptible', 'off', 'BusyAction', 'cancel');
    hAx = axes('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Parent', hFig);
    axis( hAx, 'equal');
    delete_fig = true;
elseif ~ishandle( options.parent ) || ~strcmp( get(options.parent, 'type'), 'axes' )
    error('define_shape:invalidArgument', 'Invalid parent axes')
else
    hAx = options.parent;
    hFig = ancestor( hAx, 'figure' );
    set( hFig, 'Interruptible', 'off', 'BusyAction', 'cancel');
end

%cb = get( hFig, 'KeyPressFcn' );

if nargin<1 || isempty(shape)
    shape = 'polyline';
elseif ~ischar(shape)
    hPlot = iplot(shape, 'parent', hAx, remainder{:});
end

%xl = get( hAx, 'Xlim' );
%yl = get( hAx, 'YLim' );

%set( hAx, 'XLim', xl + [-0.1 0.1].*diff(xl), 'YLim', yl + [-0.1 0.1].*diff(yl) );

if ischar(shape)
    switch shape
        case 'circle'
            shape = shapes.shape_circle.icreate( 'parent', hAx, remainder{:} );
        case 'rectangle'
            shape = shapes.shape_rectangle.icreate( 'parent', hAx, remainder{:} );
        case 'polyline'
            shape = shapes.shape_polyline.icreate( 'parent', hAx, remainder{:}, 'minnodes', 2 );
        otherwise
            error('define_shape:invalidShape', 'Invalid shape')
    end
    hPlot = iplot(shape, 'ContextDelete', false, 'parent', hAx, remainder{:});
end
   
%set( hFig, 'KeyPressFcn', @key_press );

% wait until user is done
set( hFig, 'CurrentCharacter', ' ' );
waitfor(hFig, 'CurrentCharacter', 27 )

if isvalid( hPlot )
    delete( hPlot );
end

if delete_fig && ishandle(hFig)
    delete(hFig);
end

%     function key_press(src,ev)
%         if strcmp(ev.Key,'escape') %done
%             %resume
%             %uiresume(hFig);
%             delete(hPlot)
%         end
%     end

end