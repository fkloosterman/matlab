function s = config2struct( C )
%CONFIG2STRUCT convert configobj to struct
%
%  s=CONFIG2STRUCT(c) Convert the key/value pairs in a configobj to a
%  matlab struct. Comments are lost in this conversion.
%

%  Copyright 2005-2008 Fabian Kloosterman

s = C.keys;

fn = fieldnames( C.subsections );

for k=1:numel(fn)
    
    s.(fn{k}) = config2struct( C.subsections.(fn{k}) );
    
end
