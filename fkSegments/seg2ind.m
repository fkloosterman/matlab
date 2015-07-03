function seg=seg2ind(seg,t)
%SEG2IND convert segments to indices
%
%  seg=SEG2IND(seg,t) convert segments to indices using the time vector t.
%
%

b = inseg(seg, t);

b = diff( [0;b;0] );

seg = [find( b==1 ) find( b==-1 )-1 ];