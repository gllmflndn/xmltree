function varargout = xml2mat(xmlfile, matfile)
%XML2MAT Convert an XML-file into a MAT-file
%  XML2MAT(XMLFILE, MATFILE) converts an XML file or an XML string
%  (as saved by MAT2XML) into a MAT-file MATFILE.
%  S = XML2MAT(XMLFILE) returns the content of XMLFILE in variable S.
%  S is a struct containing fields matching the variables retrieved.
%
%  See also LOADXML, MAT2XML, XMLTREE, LOAD.


s = loadxml(xmlfile);

if nargout == 1 || nargin == 1
	varargout{1} = s;
end

if nargin == 2
	names = fieldnames(s);
	flagfirstvar = 1;
	for i=1:length(names)
		% TODO % Very Dangerous !!!
		eval([names{i} ' = s.' names{i} ';']);
		if flagfirstvar
			save(matfile,names{i});
			flagfirstvar = 0;
		else
			save(matfile,names{i},'-APPEND');
		end
	end
end
