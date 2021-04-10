function varargout = save(tree,filename,varargin)
% XMLTREE/SAVE Save an XML tree in an XML file
% FORMAT str = save(tree,filename,opts...)
%
% tree      - XMLTree
% filename  - XML output filename
% opts      - list of name/value pairs of optional parameters:
%               prettyPrint: indent output [Default: true]
%
% str       - XML string
%             (if requested or if filename is not provided or empty)
%
% Convert an XML tree into a well-formed XML string and write it into
% a file or return it as a string if no filename is provided, or
% filename is empty.
%
%  See also XMLTREE


prolog = '<?xml version="1.0" ?>\n';

order  = 0;
if mod(numel(varargin),2)
    error('[XMLTree] Invalid number of arguments.');
end
for i=1:2:numel(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case 'prettyprint'
                if ~varargin{i+1}
                    indorder = -1;
                end
            otherwise
                error(['[XMLTree] Unrecognized option "' varargin{i} '".']);
        end
    else
        error(['[XMLTree] Option names must be strings.']); %"char vectors" may be too technical
    end
end
%octave can't make handles to nested functions, while matlab can't call nested functions from non-nested
%we don't want the implementation to be nested, because accidental variable name reuse can cause disaster
%so use globals rather than detecting octave and using a shim
global dofile outbuf fid;
dofile = false;
outbuf = {};
if nargin > 1 && ~isempty(filename)
    dofile = true;
    %- Filename provided
    if ischar(filename)
        [fid, msg] = fopen(filename,'w');
        if fid==-1, error(msg); end
        cleanupObj = onCleanup(@()fclose(fid)); %now we don't have to remember to fclose later
        if isempty(tree.filename), tree.filename = filename; end
    %- File identifier provided
    elseif isnumeric(filename) && numel(filename) == 1
        fid = filename;
        prolog = ''; %- With this option, do not write any prolog
    else
        error('[XMLTree] Invalid argument for filename.');
    end
end

addstring(sprintf(prolog));
write_subtree(tree, root(tree), order);

if dofile
    %keep previous behavior: if nargout is 1, *also* generate string version even if generating file version
    if nargout == 1
        dofile = false;
        %addstring(prolog); %2.1 never put prolog in for this case, and note that using fid argument will have erased the prolog string
        write_subtree(tree, root(tree), order);
        varargout{1} = [outbuf{:}];
    end
else
    varargout{1} = [outbuf{:}];
end

clear global dofile outbuf fid;
%end of save()


%==========================================================================
function addstring(instring)
global dofile outbuf fid;
if dofile
    fprintf(fid, '%s', instring);
else
    outbuf{end + 1} = instring;
end


%==========================================================================
function write_subtree(tree, uid, order)
if ~strcmp(tree.tree{uid}.type, 'element')
    error('[XMLTree] Input has to be an element.');
end
if nargin < 3, order = 0; end

indentstr      = '';
closeindentstr = '';
if order < 0
    neworder   = order; %the "order = -1" trick for no formatting
else
    neworder   = order + 1;
    indentstr  = [sprintf('\n') blanks(3 * neworder)];
    closeindentstr = [sprintf('\n') blanks(3 * order)];
end
% We can write the contents of tag first, then decide what formatting to do after we
% know whether there are any tag-like children
addstring(['<' tree.tree{uid}.name]);
for i = 1:numel(tree.tree{uid}.attributes)
    addstring([' ' tree.tree{uid}.attributes{i}.key '="' tree.tree{uid}.attributes{i}.val '"']);
end
if isempty(tree.tree{uid}.contents)
    addstring(' />');
    return; %clearer than having the rest in an else?
end
addstring('>');
allchildrentext = true; %need to track this for whether to indent the closing tag
for child_uid = tree.tree{uid}.contents
    switch tree.tree{child_uid}.type
        case 'element'
            allchildrentext = false;
            addstring(indentstr);
            write_subtree(tree, child_uid, neworder);
        case 'chardata'
            addstring([entity(tree.tree{child_uid}.value)]);
        case 'cdata'
            addstring(['<![CDATA[' cdata(tree.tree{child_uid}.value) ']]>']);
        case 'pi'
            allchildrentext = false;
            addstring([indentstr '<?' tree.tree{child_uid}.target ' ' tree.tree{child_uid}.value '?>']);
        case 'comment'
            allchildrentext = false;
            addstring([indentstr '<!-- ' tree.tree{child_uid}.value ' -->']);
        otherwise
            warning('Type %s unknown: not saved', tree.tree{child_uid}.type);
    end
end
if ~allchildrentext
    addstring(closeindentstr);
end
addstring(['</' tree.tree{uid}.name '>']);


%==========================================================================
function str = entity(str)

str = strrep(str, '&',  '&amp;' );
str = strrep(str, '<',  '&lt;'  );
str = strrep(str, '>',  '&gt;'  );
str = strrep(str, '"',  '&quot;');
str = strrep(str, '''', '&apos;');


%==========================================================================
function str = cdata(str)
% CDATA can't contain the string "]]>", have to write multiple cdata
% elements despite being in the tree as one
str = strrep(str, ']]>', ']]]]><![CDATA[>');
