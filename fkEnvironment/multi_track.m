classdef multi_track < env_base & linearization_base
    
    properties (Hidden=true)
        tracks
    end
    
    properties (Dependent=true,SetAccess=protected)
        length
        track_lengths
    end
    
    methods
        
        function obj=multi_track(tracks)
            if nargin<1
                tracks = [];
            end
            
            obj.tracks=tracks;
            obj.name = 'multi track';
        end
        
        function val=get.length(obj)
            val = sum( obj.track_lengths );
        end
        function val = get.track_lengths(obj)
            val = cellfun( @(x) x.length, obj.tracks(:) );
        end
        
        function set.tracks(obj,val)
            if isempty( val )
                error('multi_track:set_tracks:invalidValue', 'Please specify at least one track')
            end
            if ~iscell(val)
                val = {val};
            end
            if ~all( cellfun( @(x) isa(x, 'env_base') && isa(x, 'linearization_base') && ~isa(x, 'multi_track'), val ) )
                error('multi_track:set_tracks:invalidValue', 'Invalid tracks')
            end
            obj.tracks = val;
        end
        
        function h = plot( obj,varargin)
            n = numel(obj.tracks);
            h = cell(n,1);
            for k=1:n
                h{k} = obj.tracks{k}.plot(varargin{:});
            end
        end
        
        function d=distance(obj,xy)
            d = Inf( size(xy,1), 1 );
            for k=1:numel(obj.tracks)
                d = min( d, obj.tracks{k}.distance(xy) );
            end
        end
        
        function [p2,d,p] = linearize(obj,xy)
            p = NaN( size(xy,1), 2 );
            d = Inf( size(xy,1), 1 );
            
            l = obj.track_lengths;
            csl = cumsum([0;l]);
            
            %loop through all tracks
            for k=1:numel(obj.tracks)
                %linearize all x,y coordinates using child context
                [tmp_p,tmp_d] = obj.tracks{k}.linearize( xy );
                tmp_p( tmp_p>=l(k) ) = l(k)-eps; % adjust to prevent overlap between tracks
                idx = find( abs(tmp_d)<abs(d) );
                p(idx,1) = tmp_p(idx);
                p(idx,2) = k;
                d(idx) = tmp_d(idx);
            end
            
            valid = ~isnan(p(:,1));
            
            p2 = NaN( size(p,1),1);
            p2(valid) = p(valid,1) + csl( p(valid,2) );
            
        end
        function xy = inv_linearize(obj,p,dist)
            p = convert2tracklinear( p, obj.track_lengths );
            
            %preallocate output
            xy = NaN( size(p) );
            
            %loop through all tracks
            for k=1:numel(obj.tracks)
                %find points p on this child
                idx = find( p(:,2)==k );
                %inverse linearize
                if nargin>2
                    xy(idx,:) = obj.tracks{k}.inv_linearize( p(idx,1), dist(idx));
                else
                    xy(idx,:) = obj.tracks{k}.inv_linearize( p(idx,1) );
                end
            end
        end
        function d = direction(obj,p)
            p = convert2tracklinear( p, obj.track_lengths );
            
            %preallocate output
            d = NaN( size(p,1), 1 );
            
            %loop through all tracks
            for k=1:numel(obj.tracks)
                %find points p on that polyline
                idx = find( p(:,2)==k );
                %and compute direction
                d(idx) = obj.tracks{k}.direction( p(idx,1) );
            end
        end
        function v = velocity(obj,p,varargin)
            p = convert2tracklinear( p, obj.track_lengths );
            
            block_idx = find( diff( p(:,2) )~=0 );
            block_idx = [ [1;block_idx+1] [block_idx;size(p,1)] ];
            
            v = NaN( size(p,1), 1 );
            
            for k=1:size(block_idx,1)
               
                if block_idx(k,2)>block_idx(k,1)+1
                
                    tmp = obj.tracks{p(block_idx(k,1),2)}.velocity( p(block_idx(k,1):block_idx(k,2), 1), varargin{:} ); 
                    
                    v( (block_idx(k,1)+1):(block_idx(k,2)-1) ) = tmp( 2:end-1 );
                    
                end
                
            end
            
        end
        function [edges,nbins,binsize] = bin(obj,bsz)

            if nargin<2 || isempty(bsz) || ~isnumeric(bsz) || (~isscalar(bsz) && numel(bsz)~=numel(obj.tracks))
                error('multi_track:bin:invalidArgument', 'Invalid bin size')
            elseif isscalar(bsz)
                bsz = zeros( size(obj.tracks) ) + bsz;
            end
            
            csl = cumsum( [0;obj.track_lengths] );
            
            edges = cell( numel(obj.tracks), 1);
            nbins = cell( numel(obj.tracks), 1);
            binsize = cell( numel(obj.tracks), 1);
            
            for k=1:numel(obj.tracks)
               
                [edges{k}, nbins{k}, binsize{k}] = obj.tracks{k}.bin(bsz(k));
                
                edges{k} = edges{k} + csl(k); %adjust edges
                
            end
            
            edges = unique( horzcat( edges{:} ) );
                
        end
        function d = lineardistance(obj,a,b)
            a = convert2tracklinear( a, obj.track_lengths );
            b = convert2tracklinear( b, obj.track_lengths );
            
            %distance is Inf for a(:,2)~=b(:,2)
            
            d = Inf( size(a,1), 1);
            
            for k=1:numel(obj.tracks)
                
                idx = find( a(:,2)==k && b(:,2)==k );
               
                if numel(idx)>0
                    
                    d(idx) = obj.tracks{k}.lineardistance( a(idx,1), b(idx,1) );
                
                end
                
            end
            
        end
        
        function s = tostruct(obj)
            s = struct('type', class(obj));
            s.info.name = obj.name;
            for k=1:numel(obj.tracks)
                s.info.(['track' num2str(k)]) = obj.tracks{k}.tostruct();
            end
        end
        
        function transform(obj,T)
            for k=1:numel(obj.tracks)
                obj.tracks{k}.transform(T);
            end
        end
        
        function edit(obj,varargin)
            error('multi_track:edit:notImplemented', 'Not implemented')
        end
        
    end
    
    methods (Static=true)
       
        function c = define(varargin)
            error('multi_track:edit:notImplemented', 'Not implemented')
        end
        
        function obj = fromstruct( s )
            
            if ~isstruct(s) || ~isscalar(s) || ~isfield(s, 'type' ) || ~isequal( s.type, 'multi_track' ) || ~isfield( s, 'info' ) || ~isstruct(s.info) || ~isfield( s.info, {'name'} )
                error('multi_track:fromstruct:invalidArgument', 'Invalid structure' )
            end
            
            fn = setdiff( fieldnames(s.info), {'name'} );
            tmp = {};
            for k=1:numel(fn)
                tmp{k} = env_base.fromstruct( s.info.(fn{k}) );
            end
            obj = multi_track( tmp );
            obj.name = s.info.name;

        end
        
    end
    
end
        
function pout = convert2tracklinear(p, l)
%CONVERT2TRACKLINEAR helper function

%convert to distance along track + track number
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