function [d,t] = parse_time( s, default )
%PARSE_TIME parse string for date/time
%
%  [datevec,timevec]=PARSE_TIME(s) parses the time string s and returns
%  a date vector with [year month day] and a time vector with [hour
%  minute second]. Recognized date and time formats:
%  'dd-mm[-[yy]yy]', 'HH:MM[:SS[.ss]]', where parts in between
%  square brackets are optional. Date and time can be used in the
%  same string separated by whitespace. If the string is missing
%  either time or date parts, the respective output is NaN.
%
%  [...]=PARSE_TIME(s,default) uses the values in the 6 element
%  date/time default vector for initialization.
%

%  Copyright 2009 Fabian Kloosterman


if nargin<1 || ~ischar(s)
    error('parse_time:invalidArgument', 'Invalid date/time string' )
end

if nargin<2 || isempty(default)
    d = NaN;
    t = NaN;
else
    default = datevec( default );
    d = default(1:3);
    t = default(4:6);
end

fulltime = '^(?<hour>([0-1]?[0-9])|(2[0-3])):(?<minute>[0-5]?[0-9]):(?<second>[0-5]?[0-9](\.[0-9]*)?)$';
parttime = '^(?<hour>([0-1]?[0-9])|(2[0-3])):(?<minute>[0-5]?[0-9])$';
fulldate = '^(?<day>(3[0-1])|([0-2]?[0-9]))-(?<month>((1[0-2])|([0]?[0-9]))|[a-zA-Z][a-zA-Z][a-zA-Z])-(?<year>([0-9][0-9])?[0-9][0-9])';
partdate = '^(?<day>(3[0-1])|([0-2]?[0-9]))-(?<month>((1[0-2])|([0]?[0-9]))|[a-zA-Z][a-zA-Z][a-zA-Z])$';

tokens = textscan( s, '%s' );
for k=1:numel(tokens{1})
    [d,t] = local_parse_token( tokens{1}{k}, d, t );
end

    function [d,t] = local_parse_token( token, d, t )
    if ~isempty(token)
        r = regexp( token, {fulltime,parttime,fulldate,partdate}, 'names' );
        if ~isempty(r{1}) %full time match
            t = [str2num(r{1}.hour) str2num(r{1}.minute) str2num(r{1}.second)];
        elseif ~isempty(r{2}) %part time match
            t = [str2num(r{2}.hour) str2num(r{2}.minute) 0];
        elseif ~isempty(r{3}) %full date match
            d = [local_parse_year(r{3}.year) local_parse_month(r{3}.month) str2num(r{3}.day)];
        elseif ~isempty(r{4}) %part date match
            d = [str2num( datestr( now, 'yyyy' ) ) local_parse_month(r{4}.month) str2num(r{4}.day)];
        else
            %error?
        end
    end
    end

    function y = local_parse_year( y )
        if length(y)==2
            thisyear = datestr( now, 'yyyy' );
            y = [thisyear(1:end-2) y];
        elseif length(y)~=4
            error('local_parse_year:invalidYear', 'Invalid year')
        end
        y = str2num(y);
    end

    function m = local_parse_month( m )
        switch lower(m)
            case {'jan','january'}
                m = 1;
            case {'feb','february'}
                m = 2;
            case {'mar','march'}
                m = 3;
            case {'apr','april'}
                m = 4;
            case {'may'}
                m = 5;
            case {'jun','june'}
                m = 6;
            case {'jul','july'}
                m = 7;
            case {'aug','august'}
                m = 8;
            case {'sep','september'}
                m = 9;
            case {'oct','october'}
                m = 10;
            case {'nov','november'}
                m = 11;
            case {'dec','december'}
                m = 12;
            otherwise
                m = str2num( m );
                if isempty(m)
                    error('local_parse_month:invalidMonth', 'Invalid month')
                end
        end
    end

end