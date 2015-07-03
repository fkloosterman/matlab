function s = savescript( fid, varargin )
%SAVESCRIPT save variables to .m file
%
%  SAVESCRIPT( fid, var1, var2, ...)
%

if nargin<1
    help(mfilename)
    return
end


RET = sprintf( '\n' );

s = { ['%saved by SAVESCRIPT on ' datestr(now) RET] };

for k=1:nargin-1
    
    if isstruct(varargin{k})
        local_save_struct( varargin{k}, '' );
    else
    
        varname = inputname( k+1 );
    
        if isempty(varname)
            varname = ['var' num2str(k)];
        end
        
        local_add_var( varname, varargin{k} );

    end
    
end

autoclose = false;
if ischar(fid)
    fid = fopen(fid, 'w');
    autoclose = true;
elseif ~isnumeric(fid) || ~isscalar(fid) || isempty( fopen(fid) )
    error('savescript:invalidFile', 'Invalid file identifier')
end
    
fprintf( '%s', s{:} );

if autoclose
    fclose(fid);
end

    function local_add_var( name, v )
                
        if ischar( v )
            tmp = ['''' v ''''];
        else
            tmp = tostr( v );
            if isnumeric(v) && ~( isvector(v) || isempty(v) )
                n = find( tmp=='[', 1 );
                n = repmat( ' ', 1, numel(name)+3+n );
                tmp = strrep(tmp,';',['; ...' RET n]);
            end
        end
        s = cat( 1, s, { [name ' = ' tmp ';' RET] } );
        
    end

    function local_save_struct(data, base)

        fn = fieldnames(data);

        for m=1:numel(fn)
   
            if isstruct( data.(fn{m}) )
                local_save_struct(data.(fn{m}), [base fn{m} '.']  );
            else
                local_add_var( [base fn{m}], data.(fn{m}) );
            end
    
        end
        
    end

end