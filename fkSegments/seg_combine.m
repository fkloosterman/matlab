function segments = seg_combine( segments, maxgap, protected_gaps )
%SEG_COMBINE combine segments with small inter-segment gap
%
%  s=SEG_COMBINE(s,maxgap) combines all segments that have an inter-segment
%  gap smaller than maxgap.
%
%  s=SEG_COMBINE(s,gap,protect) where the 3rd argument is a logical column vector
%  with for each inter segment gap the value true if the gap is to be
%  protected or false otherwise.
%

%  Copyright 2010 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

if ~isnumeric(segments) || ndims(segments)~=2 || size(segments,2)~=2
    error('seg_combine:invalidSegments', 'Invalid segments')
end

nseg = size(segments,1);

if nseg<2
    return
end

if nargin<2 || isempty(maxgap)
    return
elseif ~isnumeric(maxgap) || ~isscalar(maxgap) || maxgap<0
    error('seg_combine:invalidArgument', 'Invalid maximum gap size')
end

if nargin<3 || isempty(protected_gaps)
    protected_gaps = false(size(segments,1)-1,1);
elseif ~islogical(protected_gaps) || ~isequal( size(protected_gaps), [nseg-1 1] )
    error('seg_combine:invalidArgument', 'Invalid protected gaps')
end

gaps = segments(2:end,1) - segments(1:end-1,2);
idx = find( gaps<maxgap & ~protected_gaps );

combi_segments = [segments(idx,1) segments(idx+1,2)];
segments = seg_or( segments, combi_segments );