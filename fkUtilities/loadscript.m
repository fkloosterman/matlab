function v = loadscript( filename, varargin )
%LOADSCRIPT load parameters from .m file
%
%  v=LOADSCRIPT(file) this will evaluate the given file and return
%    the variables created by the script.
%
%  v=LOADSCRIPT(file,'var1',val1,...) optionally defines additional
%  variables that act as a context for evaluating the script. These
%  variables are however not returned in the output structure (even
%  if their value has been changed by the script).
%

%  Copyright 2009-2010 Fabian Kloosterman


%check input arguments
if nargin<1
    help(mfilename)
    return
end

filename = fullpath( filename );

%check if file exists, append .m if necessary
if ~exist( filename, 'file' ) || isdir( filename )
    error('loadscript:invalidArgument', 'Invalid file name')
elseif isempty( dir( filename ) ) %user specified .m file without the extension
    filename = [filename, '.m'];
end 

%read complete file
%(we could use the 'run' function, but that only works for files with .m extension)
fid = fopen( filename );
z = fread( fid, '*char' ); %use variable name unlikely to be used in script
fid = fclose(fid);

v = interpretscript( z, varargin{:} );

% %clear created variables
% filename_______ = filename;
% clear filename rootdir fid
% 
% for k_______=1:2:numel(varargin)
%     eval( [varargin{k_______} '=varargin{k_______+1};'] );
% end
% clear k_______ varargin
% vars_______ = vertcat(who(), {'vars_______'});
% 
% %evaluate text
% eval( z_______ );
% 
% %clear text variable
% clear z_______
% 
% %get variables created in current workspace
% %exclude context variables
% %(this means variables created in the script w/ the same name as a variable
% %in the context are also removed)
% vars_______ = setdiff( who(), vars_______ );
% 
% if ismember( 'parent', vars_______ )
%     
%     oldpath = pwd;
%     newpath = fileparts( filename_______ );
%     cd(newpath);
%     
%     try
%         parent_______ = loadscript( fullpath( parent ) );
%     catch ME %#ok
%         parent_______ = struct();
%     end
%     
%     cd(oldpath);
%     
% else
%     
%     parent_______ = struct();
%     
% end
% 
% vars_______(ismember(vars_______,{'filename_______', 'parent'})) = [];
% 
% %assign variables to output variable
% if isempty(vars_______)
%     v_______ = struct();
% else
%     for k=1:numel(vars_______)
%         eval( ['v_______.(vars_______{k}) = ' vars_______{k} ';'] );
%     end
% end
% 
% v_______ = struct_union( parent_______, v_______ );
