function v_______ = interpretscript( s_______, varargin )
%INTERPRETSCRIPT

if nargin<1 || ~ischar(s_______)
    error('interpretscript:invalidArgument', 'Invalid script')
end

%setup context
for k=1:2:numel(varargin)
    eval( [varargin{k} '=varargin{k+1};'] );
end
vars_______ = varargin(1:2:end);
clear varargin k

eval( s_______ );

clear s_______

vars_______ = setdiff( who(), cat(2, vars_______, {'vars_______'} ) );


%assign variables to output variable
if isempty(vars_______)
    v_______ = struct();
else
    for k=1:numel(vars_______)
        eval( ['v_______.(vars_______{k}) = ' vars_______{k} ';'] );
    end
end