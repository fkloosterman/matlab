function [vertices,polylines,edges] = check_complex_track( vertices, polylines, tol, correct )

if nargin<4 || isempty(correct)
    correct = true;
else
    correct = isequal(correct,true);
end
if nargin<3 || isempty(tol)
    tol = Inf;
end
if nargin<2 || isempty(polylines)
    polylines = {};
end
if nargin<1 || isempty(vertices)
    vertices = zeros(0,2);
end

%check arguments
if ~isnumeric(vertices) || ndims(vertices)~=2 || size(vertices,2)~=2 || ...
        ~iscell(polylines) || (~isvector(polylines) && ~isempty(polylines)) || ~all(cellfun(@(x) isa(x,'shapes.shape_polyline') && ~x.isclosed, polylines))
    error('check_complex_track:invalidArguments', 'Invalid vertices and/or polylines');
end
%check for duplicate vertices
if size(unique(vertices,'rows'),1)~=size(vertices,1)
    error('check_complex_track:invalidArguments', 'Duplicate vertices');
end

np = numel(polylines);

edges = NaN( np, 2 );

for k=1:np
    
    %find closest vertex for polyline start node
    [d,vi] = min( sqrt( sum( bsxfun( @minus, polylines{k}.nodes(1,:), vertices ).^2, 2 ) ) );
    if d<=tol
        edges(k,1) = vi;
        if correct && d>0
            polylines{k}.updatenode( 1, vertices(vi,:) );
        end
    end
    
    %find closest vertex for polyline end node
    [d,vi] = min( sqrt( sum( bsxfun( @minus, polylines{k}.nodes(end,:), vertices ).^2, 2 ) ) );
    if d<=tol
        edges(k,2) = vi;
        if correct && d>0
            polylines{k}.updatenode( size(polylines{k}.nodes,1), vertices(vi,:) );
        end
    end
    
end