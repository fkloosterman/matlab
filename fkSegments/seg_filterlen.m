function [segments,idx] = seg_filterlen( segments, dur )
%SEG_FILTERLEN filters segments on length
%
%  seg=SEG_FILTERLEN(segments,dur) returns the segments that meet certain
%  duration criteria. Dur is either a scalar for a minimum duration or a
%  2-element vector for a range of valid durations.
%
%  [seg,i]=SEG_FILTERLEN(...) also returns the indices of the filtered
%  segments into the original segments list. I.e. seg=segments(i,:)
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

if nargin<2 || isempty(dur)
    return
elseif ~isnumeric(dur) || ~( isscalar(dur) || isequal(size(dur),[1 2]) ) 
    error('seg_filterlen:invalidArgument', 'Invalid duration criteria')
elseif isscalar(dur)
    dur = [dur Inf];
end

d = diff(segments,1,2);

idx = find( d>=dur(1) & d<=dur(2) );
segments = segments( idx, : );
