function varargout = save(tree,filename,varargin)
% XMLTREE/SAVE Save an XML tree in an XML file
% FORMAT varargout = save(tree,filename)
%
% tree      - XMLTree
% filename  - XML output filename
% varargout - XML string
%
% Convert an XML tree into a well-formed XML string and write it into
% a file or return it as a string if no filename is provided.
%
%  See also XMLTREE


prolog = '<?xml version="1.0" ?>\n';

order  = 0;
if mod(numel(varargin),2)
    error('[XMLTree] Invalid syntax.');
end
for i=1:2:numel(varargin)
    switch lower(varargin{i})
        case 'prettyprint'
            if ~varargin{i+1}
                order = -1;
            end
        otherwise
            error('[XMLTree] Invalid syntax.');
    end
end

%- Return the XML tree as a string
if nargin == 1 || isempty(filename)
    varargout{1} = [sprintf(prolog) ...
        print_subtree(tree,root(tree),order)];
%- Output specified
else
    %- Filename provided
    if ischar(filename)
        [fid, msg] = fopen(filename,'w');
        if fid==-1, error(msg); end
        if isempty(tree.filename), tree.filename = filename; end
    %- File identifier provided
    elseif isnumeric(filename) && numel(filename) == 1
        fid = filename;
        prolog = ''; %- With this option, do not write any prolog
    else
        error('[XMLTree] Invalid argument.');
    end
    fprintf(fid,prolog);
    fprintf(fid,'%s',print_subtree(tree,root(tree),order));
    if ischar(filename), fclose(fid); end
    
    if nargout == 1
        varargout{1} = [sprintf(prolog) ...
            print_subtree(tree,root(tree),order)];
    end
end

%==========================================================================
function xmlstr = print_subtree(tree,uid,order)

if ~strcmp(tree.tree{uid}.type, 'element')
    error('');
end
if nargin < 3, order = 0; end
indentstr = '';
closeindentstr = '';
if order < 0
    neworder = order;
else
    neworder = order + 1;
    indentstr = [sprintf('\n') blanks(3 * neworder)];
    closeindentstr = [sprintf('\n') blanks(3 * order)];
end
% Make contents of tag first, then decide what formatting to do after we
% know whether there are any tag-like children
contents = '';
allchildrentext = true;
for child_uid = tree.tree{uid}.contents
    switch tree.tree{child_uid}.type
        case 'element'
            allchildrentext = false;
            contents = [contents indentstr print_subtree(tree, child_uid, neworder)];
        case 'chardata'
            contents = [contents entity(tree.tree{child_uid}.value)];
        case 'cdata'
            contents = [contents cdata(tree.tree{child_uid}.value)];
        case 'pi'
            allchildrentext = false;
            contents = [contents indentstr '<?' tree.tree{child_uid}.target ' ' tree.tree{child_uid}.value '?>'];
        case 'comment'
            allchildrentext = false;
            contents = [contents indentstr '<!-- ' tree.tree{child_uid}.value ' -->'];
        otherwise
            warning('Type %s unknown: not saved', tree.tree{child_uid}.type);
    end
end
tagstr = ['<' tree.tree{uid}.name];
for i = 1:length(tree.tree{uid}.attributes)
    tagstr = [tagstr ' ' tree.tree{uid}.attributes{i}.key '="' tree.tree{uid}.attributes{i}.val '"'];
end
%tagstr isn't quite finished, but build xmlstr directly with it to save a little time
if isempty(tree.tree{uid}.contents)
    xmlstr = [tagstr '/>'];
else
    if allchildrentext
        xmlstr = [tagstr '>' contents '</' tree.tree{uid}.name '>'];
    else
        xmlstr = [tagstr '>' contents closeindentstr '</' tree.tree{uid}.name '>'];
    end
end


%==========================================================================
function str = entity(str)

str = strrep(str, '&',  '&amp;' );
str = strrep(str, '<',  '&lt;'  );
str = strrep(str, '>',  '&gt;'  );
str = strrep(str, '"',  '&quot;');
str = strrep(str, '''', '&apos;');
