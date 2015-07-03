classdef complex_track < env_base & linearization_base
    
    properties (Hidden=true)
        edges = zeros(0,2) %list of (v1,v2) vertices
        vertices = zeros(0,2) %list of (x,y) coordinates
        vertex_labels = {};
        polylines = zeros(0,2) %list of polylines corresponding to the edges
        graph = []
        pathlengths = []
        tol = 1e-3;
    end
    
    properties (Dependent=true,SetAccess=protected)
        length
        edge_lengths
    end
    
    methods
        
        function obj = complex_track(vertices,polylines)
            obj.set_vertices_and_polylines(vertices,polylines);
            obj.name = 'complex track';
        end
        
        function val = get.length(obj)
            val = sum( obj.edge_lengths );
        end
        function set_vertices_and_polylines(obj,vertices,polylines)
            
            [vertices, polylines, edges] = check_complex_track( vertices, polylines, obj.tol, false );

            vertexlabels = cell( size(vertices,1), 1 );
            for k=1:size(vertices,1)
                vertexlabels{k} = ['vertex' num2str(k)];
            end
            
            nv = size(vertices,1);
            
            %make sure all polylines and vertices are connected
            if any( isnan( edges(:) ) ) || ~all( ismember( 1:nv, edges(:) ) )
                error('complex_track:set_vertices_and_polylines:invalidArguments', 'Not all polylines/vertices are connected')
            end
            
            if any( edges(:,1)==edges(:,2) )
                error('complex_track:set_vertices_and_polylines:invalidArguments', 'polylines cannot start and end at the same vertex')
            end
            
            if nv<2 || isempty(polylines)
                error('complex_track:set_vertices_and_polylines:invalidArguments', 'Need at least two vertices and 1 polyline')
            end
            
            %create graph
            obj.graph = Inf( nv );
            obj.graph( sub2ind( [nv nv], 1:nv, 1:nv ) ) = 0;
            for k=1:numel(polylines)
                obj.graph(edges(k,1),edges(k,2)) = min( obj.graph(edges(k,1),edges(k,2)), polylines{k}.length );
                obj.graph(edges(k,2),edges(k,1)) = obj.graph(edges(k,1),edges(k,2));
            end
            
            obj.edges = edges;
            obj.vertices = vertices;
            obj.polylines = polylines;
            
            obj.vertex_labels = vertexlabels;
            
            obj.pathlengths = FloydWarshall( obj.graph );
            
        end
        
        function set.vertex_labels(obj,val)
            if ~iscellstr(val) || numel(val)~=size(obj.vertices,1) || any( cellfun( 'isempty', val) )
                error('complex_track:set_vertex_labels:invalidArgument', 'Invalid vertex labels')
            end
            obj.vertex_labels = val;
        end
        
        function d = distance(obj,xy)
            d = Inf( size(xy,1), 1 );
            for k=1:numel(obj.polylines)
                d = min( d, obj.polylines{k}.distance(xy) );
            end
        end
        
        function [p2,d,p] = linearize(obj,xy)
            %preallocate outputs
            p = NaN( size(xy,1), 2 );
            d = Inf( size(xy,1), 1 );
            
            %loop through all polylines
            l = cellfun( @(x) x.length, obj.polylines(:) );
            for k=1:numel(obj.polylines)
                %linearize all x,y coordinates using this child context
                [tmp_p,tmp_d]=linearize_context_polyline.linearize(obj.polylines{k},xy);
                %test whether distance to child is smaller than anything we had
                %before and save the linearized position, distance and child index
                idx = find( abs(tmp_d)<abs(d) );
                p(idx,1) = tmp_p(idx);
                %end point of segments are not included (to make sure there
                %is an unique mapping between linearized position and segmented
                %position)
                p(idx,1) = min( p(idx,1), l(k)-0.0001 );
                p(idx,2) = k;
                d(idx) = tmp_d(idx);
            end
            
            %for all valid points...
            valid = ~isnan( p(:,1) );
            
            %compute the linearized position
            csl = cumsum([0;l]);
            p2 = NaN( size(p,1),1);
            p2(valid) = p(valid,1) + csl( p(valid,2) );
        end
        function xy = inv_linearize(obj,p,dist)
            %convert linearized position to segmented linearized position
            p = convert2seglinear( p, cellfun(@(x) x.length, obj.polylines(:) ) );
            
            %preallocate output
            xy = NaN( size(p) );
            
            %loop through all polylines
            for k=1:numel(obj.polylines)
                %find points p on this child
                idx = find( p(:,2)==k );
                %inverse linearize
                if nargin>2
                    xy(idx,:) = linearize_context_polyline.inv_linearize( obj.polylines{k}, p(idx,1), dist(idx));
                else
                    xy(idx,:) = linearize_context_polyline.inv_linearize( obj.polylines{k}, p(idx,1) );
                end
            end
        end
        function d = direction(obj,p)
            %convert linearized position to segmented linearized position
            p = convert2seglinear( p, cellfun(@(x) x.length, obj.polylines(:) ) );
            
            %preallocate output
            d = NaN( size(p,1), 1 );
            
            %loop through all polylines
            for k=1:numel(obj.polylines)
                %find points p on that polyline
                idx = find( p(:,2)==k );
                %and compute direction
                d(idx) = linearize_context_polyline.direction( obj.polylines{k}, p(idx,1) );
            end
        end
        function v = velocity(obj,p,dt)
%             %convert linearized position to segmented linearized position
%             l = cellfun( @(x) x.length, obj.polylines(:) );
%             p = convert2seglinear( p, l );
%             
%             %remove NaNs
%             invalid = isnan( p(:,1 ) );
%             tmp = p; tmp( invalid,:) = [];
%             
%             %find transitions between child contexts
%             idx = find( diff( tmp(:,2) )~=0 );
%             tmp1 = round( tmp(idx,1)./l(tmp(idx,2)) );
%             tmp2 = round( tmp(idx+1,1)./l(tmp(idx+1,2)) );
%             
%             %compute correction values
%             cs = zeros( size(tmp,1), 1 );
%             cs(idx+1) = tmp1.*l(tmp(idx,2)) - tmp2.*l(tmp(idx+1,2));
%             
%             cs = cumsum( cs );
%             
%             cs2 = NaN( size(p,1), 1 );
%             cs2( ~invalid ) = cs;
%             
%             %apply corrections
%             p = p(:,1) + cs2;
%             
% %             %for every part on a closed track, unwrap and adjust later positions
% %             isclosed = find( cellfun( @(x) x.issclosed, obj.polylines(:) ) );
% %             
% %             for k=1:numel(isclosed)
% %                 
% %                 %find segments
% %                 q = find(tmp(:,2)==isclosed(k));
% %                 b = burstdetect( q, 'MinISI', 1, 'MaxISI', 1 );
% %                 segs = [ q(b==1) q(b==3) ];
% %                 
% %                 factor = 2*pi*l(isclosed(k));
% %                 
% %                 for j=1:size(segs,1)
% %                     oldval = p(segs(j,2));
% %                     
% %                     %unwrap
% %                     p((segs(j,1)+1):segs(j,2)) = unwrap( factor.*p( segs(j,1):segs(j,2) ...
% %                         ) )./factor;
% %                     
% %                     %update position after segment
% %                     p((segs(j,2)+1):end) = p((segs(j,2)+1):end) + p(segs(j,2)) - oldval;
% %                     
% %                 end
% %             end
%             
%             %compute gradient
%             if nargin<3 || isempty(dt)
%                 v = gradient( p, 1./30 );
%             else
%                 v = gradient( p, dt );
%             end
            
            if nargin<3 || isempty(dt)
                dt = 1./30;
            end
            
            v = NaN( size(p,1), 1 );
            v(1) = obj.lineardistance( p(1,:), p(2,:) )./dt;
            v(end) = obj.lineardistance( p(end-1,:), p(end,:) )./dt;
            v(2:end-1) = (obj.lineardistance( p(2:end-1,:), p(3:end,:) ) - obj.lineardistance( p(2:end-1,:), p(1:end-2,:) ) ) ./ (2*dt);
            
        end
        function [edges, nbins, binsize] = bin(obj,binsize)
            %compute number of bins separately for each child
            l = cellfun( @(x) x.length, obj.polylines(:) );
            csl  = cumsum( [0;l] );
            nbins = ceil( l./binsize );
            binsize = l./nbins;
            
            edges = [];
            
            %loop through child contexts
            for k=1:numel(obj.polylines)
                
                %compute bin edges for child
                edges = [edges linspace(csl(k),csl(k+1),nbins(k)+1) ]; %#ok
                
            end

            edges = unique(edges);
            
        end
        function d = lineardistance(obj,a,b)
            l = cellfun(@(x) x.length, obj.polylines(:) );
            a = convert2seglinear(a,l);
            b = convert2seglinear(b,l);
            
            d = Inf( size(a,1), 1 );
            idx = a(:,2)==b(:,2);
            
            d(idx) = b(idx,1)-a(idx,1);
            
            %for points on different segments compute shortest distance
            idx = find( ~idx);
            for k=1:numel(idx)
                
                if (isnan(a(idx(k))) || isnan(b(idx(k))))
                    d(idx(k)) = NaN;
                    continue
                end
                
                tmp = [
                    -(obj.pathlengths( obj.edges(a(idx(k),2),1), obj.edges(b(idx(k),2),1) ) + a(idx(k),1) + b(idx(k),1)) ...
                    -(obj.pathlengths( obj.edges(a(idx(k),2),1), obj.edges(b(idx(k),2),2) ) + a(idx(k),1) + l(b(idx(k),2)) - b(idx(k),1)) ...
                    obj.pathlengths( obj.edges(a(idx(k),2),2), obj.edges(b(idx(k),2),1) ) + l(a(idx(k),2)) - a(idx(k),1) + b(idx(k),1) ...
                    obj.pathlengths( obj.edges(a(idx(k),2),2), obj.edges(b(idx(k),2),2) ) + l(a(idx(k),2)) - a(idx(k),1) + l(b(idx(k),2)) - b(idx(k),1) ...
                    ];
                
                [~,mi] = min( abs(tmp) );
                
                d(idx(k)) = tmp(mi);
            end
            
        end
        
        function h = plot(obj,varargin)
            %plot polylines
            for k=1:numel(obj.polylines)
                h(k) = obj.polylines{k}.plot(varargin{:});
            end
        end
        
        function val = get.edge_lengths(obj)
            val = cellfun( @(x) x.length, obj.polylines );
        end
        
        function s = tostruct(obj)
            s = struct('type', class(obj), 'info', struct( 'name', obj.name, 'vertices', obj.vertices, 'vertex_labels', {obj.vertex_labels}, 'polylines', { cellfun( @(x) x.tostruct(), obj.polylines, 'UniformOutput', false ) } ) );
        end
        
        function transform(obj,T)
            obj.vertices = T.transform( obj.vertices );
            for k=1:numel(obj.polylines)
                obj.polylines{k}.transform(T);
            end
        end
        
        function edit( obj, varargin )
            [v, p] = define_complex_track( obj.vertices, obj.polylines, varargin{:} );
            obj.set_vertices_and_polylines( v, p );
        end
        
    end
   
    methods (Static=true)
       
        function c = define( varargin )
            
            %filter out position option (not used for complex track)
            options = struct('position', []);
            [~,~,remainder] = parseArgs(varargin,options);
            
            [v, p] = define_complex_track( zeros(0,2), {}, remainder{:} );
            
            c = complex_track( v, p );
            
        end
        
        function obj = fromstruct( s )
           
            if ~isstruct(s) || ~isscalar(s) || ~isfield(s, 'type' ) || ~isequal( s.type, 'complex_track' ) || ~isfield( s, 'info' ) || ~all(isfield( s.info, {'name', 'vertices','vertex_labels', 'polylines'}))
                error('complex_track:fromstruct:invalidArgument', 'Invalid structure' )
            end
            
            obj = complex_track( s.info.vertices, cellfun( @(x) shapes.shape_polyline.fromstruct(x), s.info.polylines, 'UniformOutput', false ) );
            obj.vertex_labels = s.info.vertex_labels;
            obj.name = s.info.name;
            
        end
        
    end
    
end

function pout = convert2seglinear(p, l)
%CONVERT2SEGLINEAR helper function

%convert to distance along segment + segment number
if size(p,2)==1
  csl = cumsum( [0;l] );
  tmp = fix(interp1( csl, (1:(numel(l)+1))', p, 'linear', 'extrap' ));
  tmp(tmp>numel(l))=numel(l);
  valid = ~isnan(p);
  pout = NaN(size(p,1),2);
  pout(valid,:) = [p(valid)-csl(tmp(valid)) tmp(valid)];
else
    pout=p;
end

end
