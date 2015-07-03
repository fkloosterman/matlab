classdef matfile < handle
    
    properties
        path = '';
    end
    
    properties (SetAccess=protected)
        vars = {};
    end
    
    properties (Access=protected)
        cache = {};
        loaded = [];
    end
    
    methods
        
        function obj=matfile(p)
            if nargin<1 || isempty(p)
                p = '';
            end
            obj.path = p;
            obj.refresh();
        end
        
        function obj=set.path(obj,val)
            if ~ischar(val) || (~isempty(val) && ~exist(val,'file'))
                error('matfile:setpath:invalidValue', 'Invalid mat file name')
            end
            if ~isempty(val)
                val = fullpath(val);
            end
            obj.path = val;
            refresh(obj);
        end
        
        function b=refresh(obj)
            if isempty(obj.path)
                obj.vars = {};
            else
                v = whos('-file', obj.path );
                obj.vars = {v.name}';
            end
            b=obj.emptyCache();
        end
        
        function b=emptyCache(obj)
            obj.cache = cell( size(obj.vars) );
            obj.loaded = false( size(obj.cache) );
            b=true;
        end
   
        function varargout=subsref(obj,s)
            switch s(1).type
                case '()'
                    if isempty(obj.path)
                        error('matfile:subsref:noFile', 'No file set');
                    end
                    %valid variables requested?
                    if any( ismember( s(1).subs, {':'} ) )
                        idx = 1:numel(obj.vars);
                    else
                        [tf,idx] = ismember( s(1).subs, obj.vars );
                        if isempty(tf) || ~all(tf)
                            error('matfile:subsref:invalidIndex', 'Unknown variables requested')
                        end
                        idx = unique(idx);
                    end
                    %load variables that are not cached
                    if any( ~obj.loaded(idx) )
                        v = load( obj.path, obj.vars{idx(~obj.loaded(idx))} );
                        obj.cache( idx(~obj.loaded(idx)),1) = struct2cell( v );
                        obj.loaded(idx) = true;
                    end
                    %get all variables
                    if isscalar(idx)
                        val = obj.cache{idx};
                    else
                        val = cell2struct( obj.cache(idx), obj.vars(idx), 1 );
                    end
                    
                    %continue processing subsref
                    if numel(s)>1
                        [varargout{1:nargout}] = subsref( val, s(2:end) );
                    else
                        varargout{1} = val;
                    end
                    
                otherwise
                    [varargout{1:nargout}] = builtin('subsref',obj,s);
            end
        end
        
    end
    
end