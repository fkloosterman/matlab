function [vertices,polylines] = define_complex_track(varargin)

options = struct( 'parent', [], 'color', [0 0 0] );
[options, other] = parseArgs(varargin,options);

[vertices, polylines, edges] = check_complex_track( other{:} );

delete_fig = false;

%set up figure / axes / controls
if isempty( options.parent )
    hFig = figure('colormap', gray(256), 'Interruptible', 'off', 'BusyAction', 'cancel');
    hAx = axes('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Parent', hFig);
    axis( hAx, 'equal');
    delete_fig = true;
elseif ~ishandle( options.parent ) || ~strcmp( get(options.parent, 'type'), 'axes' )
    error('define_complex_track:invalidArgument', 'Invalid parent axes')
else
    hAx = options.parent;
    hFig = ancestor( hAx, 'figure' );
    set( hFig, 'Interruptible', 'off', 'BusyAction', 'cancel');
end

%connect each polyline to vertices
maxkey = size(vertices,1);
keys = (1:maxkey)';

hPol = {};

% draw polylines
for k=1:numel(polylines)
    hPol{k} = polylines{k}.iplot('parent', hAx, 'ContextClose', false, 'Color', options.color);
    hPol{k}.lockVertices( [1 size(polylines{k}.nodes,1)] );
end
    
% draw vertices
if size(vertices,1)==0
    hVert = line( NaN, NaN, 'Color', [0 1 0], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0 1 0], 'MarkerSize', 15, 'Parent', hAx );
else
    hVert = line( vertices(:,1), vertices(:,2), 'Color', [0 1 0], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', [0 1 0], 'MarkerFaceColor', [0 1 0], 'MarkerSize', 15, 'Parent', hAx );
end

%backup old callbacks
cb = { get(hAx, 'ButtonDownFcn'), get(hFig,'KeyPressFcn') };

set( hFig, 'KeyPressFcn', @key_press );
set( hVert, 'ButtonDownFcn', @edit_vertex );
set( hAx, 'ButtonDownFcn', @add_vertex );

oldpointer = get( hFig, 'pointer' );
set( hFig, 'pointer', 'circle' );

% wait until user is done
waitfor(hVert)

%restore callbacks
if ishandle(hFig)
    set( hFig, 'KeyPressFcn', cb{2}, 'pointer', oldpointer );
end
if ishandle(hVert)
    delete(hVert);
end
if ishandle(hAx)
    set( hAx, 'ButtonDownFcn', cb{1} );
end
%delete polylines
for k=1:numel(hPol)
    if isvalid( hPol{k} )
        delete( hPol{k} );
    end
end

if delete_fig && ishandle(hFig)
    delete(hFig);
end

    function key_press(~,ev)
        if strcmp(ev.Key,'escape') %done
            %resume
            %uiresume(hFig);
            delete(hVert)
        elseif strcmp(ev.Key, 'e') %new edge
            add_polyline();
        end
    end

    function update_vertices()
        set( hVert, 'XData', vertices(:,1), 'YData', vertices(:,2) );
    end

    function add_vertex(~,~)
        pos = get(hAx, 'CurrentPoint');
        vertices = cat(1,vertices, pos(1,1:2) );
        maxkey = maxkey + 1;
        keys = cat(1, keys, maxkey );
        update_vertices();
    end

    function edit_vertex(~,~)
       
        btn = get(hFig, 'SelectionType');
        pos = get( hAx, 'CurrentPoint' );
        pos = pos(1,1:2);
        
        [~,idx] = min( sum( bsxfun( @minus, vertices, pos ).^2, 2 ) );
        
        switch btn
            
            case 'extend' %move
                pos = pos - vertices(idx,:);
                set( hFig, 'WindowButtonMotionFcn', @(h,e) mouseMove(pos,idx) );
                set( hFig, 'WindowButtonUpFcn', @(h,e) mouseUp() );
                
            case 'alt' %delete
                
                ii = find( any( edges == keys(idx), 2 ) );
                
                vertices(idx,:) = [];
                keys(idx) = [];
                
                for kk=1:numel(ii)
                    delete( hPol{ii(kk)} );
                    polylines(ii(kk)) = [];
                end
                
                update_vertices;
                
        end
        
    end

    function mouseMove(delta,idx)
        pos = get(hAx,'CurrentPoint');
        pos = pos(1,1:2);
        
        vertices(idx,:) = pos - delta;
        
        % allo move any polylines attached to this vertex
        
        for kk=1:numel(polylines)
            if edges(kk,1)==keys(idx)
                polylines{kk}.updatenode(1,pos-delta);
            end
            if edges(kk,2)==keys(idx)
                polylines{kk}.updatenode( size(polylines{kk}.nodes,1), pos-delta );
            end
        end
                
        
        update_vertices;
    end

    function mouseUp()
        set( hFig, 'WindowButtonMotionFcn', [] );
        set( hFig, 'WindowButtonUpFcn', [] );
    end

    function add_polyline()
        %only if we have at least two vertices
        if size(vertices,1)<2
            errordlg('Please define at least two vertices first')
            return
        end
        
        %disable key presses and creation of new vertices
        set( hAx, 'hittest', 'off' );
        set (hFig, 'KeyPressFcn', [] );
        
        p = shapes.getpolyline( 'parent', hAx, 'minnodes', 2);
        
        if ~isempty(p)
            ii = numel(polylines)+1;
            
            [~,idx] = min( sum( bsxfun( @minus, vertices, p.nodes(1,:) ).^2, 2 ) );
            p.nodes(1,:) = vertices(idx,:);
            edges(ii,1) = keys(idx);
            [~,idx] = min( sum( bsxfun( @minus, vertices, p.nodes(end,:) ).^2, 2 ) );
            p.nodes(end,:) = vertices(idx,:);
            edges(ii,2) = keys(idx);
            
            %create polyline object
            polylines{ii} = shapes.shape_polyline( p.nodes, false, p.isspline );
            hPol{ii} = shapes.Polyline( polylines{ii}, 'Parent', hAx, 'ContextClose', false, 'Color', options.color );
            
            hPol{ii}.lockVertices( [1 size(p.nodes,1)] );

        end
        
        uistack(hVert, 'top' );

        set( hAx, 'hittest', 'on' );
        set( hFig, 'KeyPressFcn', @key_press );
        
    end

end