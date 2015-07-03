classdef refobj < dynamicprops
%REFOBJ reference structure object
%
%  A refobj functions like a reference to scalar struct
%

    methods
        
        function obj = refobj(varargin)
           
            if nargin<1
                return
            elseif nargin==1 && isstruct(varargin{1})
                s = varargin{1};
            else
                s = struct( varargin{:} );
            end
            
            n = numel(s);
            obj(n) = refobj();
            obj = reshape(obj, size(s) );
            
            fn = fieldnames(s);
            
            for h=1:n
                
                val = struct2cell(s(h));
                
                for k=1:numel(fn)
                    obj(h).addprop( fn{k} );
                    obj(h).(fn{k}) = val{k};
                end
            
            end
                    
            
        end
        
%         function display(obj)
%            
%             w = warning('off', 'MATLAB:structOnObject');
%             disp( 'Reference object with fields:' )
%             disp( struct(obj) )
%             warning(w);
%             
%         end
              
        function b=isfield(obj,f)
            b = ismember( f, properties(obj(end)) );
        end
        function b=isstruct(obj) %#ok
            b = true;
        end
        
        function val=struct2cell(obj)
            val = struct(obj);
            val = struct2cell(val);
        end
        function val = struct(obj)
            w = warning('off', 'MATLAB:structOnObject');
            val = num2cell( obj );
            val = cellfun( @(x) builtin('struct',x), val, 'UniformOutput', false );
            val = cell2mat( val );
            warning(w);
        end
        
        function fn=fieldnames(obj)
           fn = properties(obj(end)); 
        end
        function fn=fields(obj)
           fn = fieldnames(obj); 
        end
        
        function obj = subsasgn( obj, s, varargin )
            
            if numel(s)==1 && strcmp(s.type,'.')

                % [obj.a] = deal(val);
                
                %add property to all objects if needed
                if ~isfield(obj,s.subs)
                    for k=1:numel(obj)
                        obj(k).addprop(s.subs);
                    end
                end
                
                %set field values
                for k=1:numel(obj)
                    obj(k).(s.subs) = varargin{k};
                end
                
                %obj = builtin('subsasgn', obj, s, varargin{:} );
                
            elseif numel(s)==1 && strcmp(s(1).type, '()' )
                
                % obj(1:2) = obj(3:4)
                % obj(1:2) = [];
                
                if ~isempty(varargin{1})
                    %check if rhs value has same properties
                    if ~isa(varargin{1},'refobj') || ~isequal( sort(properties(obj(end))), sort(properties(varargin{1}(end))) )
                        error('refobj:subsasgn:invalidValue', 'Dissimilar objects')
                    end
                end
                
                obj = builtin('subsasgn', obj, s, varargin{:} );
                
            elseif numel(s)==2 && strcmp(s(1).type,'()') && strcmp(s(2).type,'.')
                
                error('refobj:subsasgn:notSupported', 'Unfortunately, this operation is not supported by Matlab')
                
                % [obj(1:end).a] = deal(val);
                %
                % PROBLEM: this syntax does not call the overloaded NUMEL
                % method and hence only supplies us with one value, even
                % though deal will return the correct number of values.
                % 
                
                
%                 %add property to all objects if needed
%                 if ~isfield(obj,s(2).subs)
%                     for k=1:numel(obj)
%                         obj(k).addprop(s(2).subs);
%                     end
%                 end
%                 
%                 %obj = builtin('subsasgn', obj, s, varargin{:} );
%                 obj(s(1).subs{:}) = subsasgn( obj(s(1).subs{:}), s(2), varargin{:} );
                
            end

         end
        
        function addfield(obj,p)
            if ~isfield(obj,p)
                for k=1:numel(obj)
                    obj(k).addprop(p);
                end
            end
        end
        function rmfield(obj,p)
           
            for k=1:numel(obj)
                p = findprop( obj(k), p );
                delete(p)
            end
            
        end
        
        function obj = horzcat(varargin)
            
            if ~checkobj(varargin{:})
                error('refobj:horzcat:invalidObjects', 'Cannot concatenate dissimilar objects')
            end
            
            obj = builtin('horzcat', varargin{:} );

        end
        function obj = vertcat(varargin)
            if ~checkobj(varargin{:})
                error('refobj:vertcat:invalidObjects', 'Cannot concatenate dissimilar objects')
            end
            
            obj = builtin('vertcat', varargin{:} );
        end
        function obj = cat(d,varargin)
            if ~checkobj(varargin{:})
                error('refobj:cat:invalidObjects', 'Cannot concatenate dissimilar objects')
            end
            
            obj = builtin('cat', d, varargin{:} );
        end
        
    end
    
    methods (Access=protected)
        function b = checkobj(varargin)
            b = false;
            %check if all objects are refobj
            if ~all( cellfun( @(x) isa(x,'refobj'), varargin ) )
                return
                %error('refobj:checkobj:invalidValue', 'Not all objects are refobj')
            end
            %check for equal properties
            p = cellfun( @(x) sort(properties(x)), varargin, 'UniformOutput', false );
            if ~isequal( p{:} )
                return;
                %error('refobj:checkobj:invalidValue', 'Dissimilar objects')
            end
            b = true;
        end
    end
    
end