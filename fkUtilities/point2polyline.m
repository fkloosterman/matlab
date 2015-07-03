function varargout = point2polyline(nodes, xy, clipends, closed)
%POINT2POLYLINE find nearest point on polyline for a set of points
%
%  pp=POINT2POLYLINE(p,xy) returns for each x,y coordinate the nearest x,y
%  coordinate on the polyline.
%
%  pp=POINT2POLYLINE(p,xy,clipping) where clipping is one of 'normal',
%  'extend' or 'blunt', or a two element cell array that specifies a
%  clipping method separately for the start and end nodes. Description of
%  the clipping options:
%   normal - points beyond the start/end nodes are clipped to the start/end nodes.
%   extend - points beyond the start/end nodes are projected onto the
%            first/last polyline segment that is extended to infinity.
%   blunt - point beyond the start/end nodes are deemed invalid and NaN is
%           returned.
%
%  pp=POINT2POLYLINE(p,xy,[],true) will treat p as a closed polyline. Clipping
%  options are ignored for closed polylines.
%
%  [pp,d]=POINT2POLYLINE(...) also returns the distance between the x,y
%  coordinate and the nearest point on the polyline.
%
%  [pp,d,s]=POINT2POLYLINE(...) also returns the index of the polyline
%  segment that the nearest point is located on.
%
%  [pp,d,s,ld]=POINT2POLYLINE(...) also returns the distance along the
%  polyline from the first node to the nearest point.
%


%  Copyright 2005-2008 Fabian Kloosterman


%% check arguments
if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty( clipends )
    clipends = {'normal','normal'};
elseif ischar(clipends)
    clipends = {clipends,clipends};
end

if ~iscell(clipends) || ~all(ismember(clipends,{'normal','blunt','extend'}))
    error('point2polyline:invalidArgument', 'Invalid end clipping option')
end

if nargin<4 || isempty( closed )
  closed = 0;
end

[r, c] = size(xy);

if ndims(xy)>2 || ~isnumeric(xy) || c~=2
    error('point2polyline:invalidArgument', 'Invalid xy array')
end


%% compute distance to all segments
nseg = size(nodes,1)-1;

dist = Inf(r,1);
pts = NaN(r,2);
seg = NaN(r,1);
lindist = NaN(r,1);

if r==0
    varargout = {pts, dist, seg, lindist};
    return
end

if closed
    nodes(end+1,:) = nodes(1,:);
    nseg = nseg+1;
end

for s = 1:nseg
    
    %compute distance to this segment
    if s==1 && ~closed
        [tmp_dist, tmp_pts] = dist_point_segment(xy, nodes(s:s+1, :), {clipends{1}, 'normal'});
    elseif s==nseg && ~closed
        [tmp_dist, tmp_pts] = dist_point_segment(xy, nodes(s:s+1, :), {'normal', clipends{end}});
    else
        [tmp_dist, tmp_pts] = dist_point_segment(xy, nodes(s:s+1, :), 'normal');
    end
    
    % retain smallest distance
    i = find(abs(tmp_dist)<abs(dist));
    if ~isempty(i)
        dist(i) = tmp_dist(i);
        pts(i,:) = tmp_pts(i,:);
        seg(i) = s;
    end
    
end

% compute linear distance along polyline
valid = find(~isnan(seg));
cumdist = cumsum([0; sqrt( sum(diff(nodes).^2,2) )]);
lindist(valid) = cumdist(seg(valid)) + sqrt( sum([pts(valid,1)-nodes(seg(valid),1) pts(valid,2)-nodes(seg(valid),2)].^2 ,2) );


if ~closed
    if strcmp(clipends{1}, 'extend')
        idx = find(lindist<=0);
        [dist(idx), pts(idx,:)] = dist_point_segment( xy(idx,:) , nodes(1:2,:),'extend');
        lindist(idx) = - sqrt( sum([pts(idx,1)-nodes(seg(idx),1) pts(idx,2)-nodes(seg(idx),2)].^2 ,2) );
    elseif strcmp(clipends{1}, 'normal')
        idx = lindist<=0;
        lindist(idx) = 0;
    end
    if strcmp(clipends{end}, 'extend')
        idx = find(lindist>=cumdist(end));
        [dist(idx), pts(idx,:)] = dist_point_segment( xy(idx,:) , nodes(end-1:end,:), 'extend');
        lindist(idx) = cumdist(end) + sqrt( sum([pts(idx,1)-nodes(end,1) pts(idx,2)-nodes(end,2)].^2 ,2) );
    elseif strcmp(clipends{end}, 'normal')
        idx = lindist>=cumdist(end);
        lindist(idx) = cumdist(end) - eps;
    end
    
    
    
end


varargout = {pts, dist, seg, lindist};