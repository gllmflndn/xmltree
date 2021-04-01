# XMLTree: an XML Toolbox For MATLAB/Octave
            
## INTRODUCTION

XMLTree is an XML toolbox for MATLAB and Octave.
This package consists of a class `xmltree`, of XML-files examples
and of 3 scripts of demonstrations.

This toolbox contains an [XML 1.0](http://www.w3.org/TR/REC-xml)
processor (or parser), which aims to be fully conforming. It is
currently not a validating processor.

This parser is encapsulated in a MATLAB class allowing for the
manipulation of an `xmltree` object through a set of methods.

If you do not wish to use the whole class but are only interested
in the XML parser, then you can only use functions that are in the
private folder of the class `@xmltree/private`: `xml_parser.m` and a
compiled version of `xml_findstr.m`.

Suggestions for improvement and fixes are always welcome, although no 
guarantee is made whether and when they will be implemented.

## INSTALLATION

Simply add the directory containing `@xmltree` to the MATLAB path:

```matlab
addpath('/home/login/Documents/MATLAB/xmltree/');
```

XMLTree package uses one MEX-file for the parsing of XML data: 
this MEX-file is provided for Windows, Linux and Mac platforms.
If you need to compile it for your own architecture, the command is:

```matlab
cd /home/login/Documents/MATLAB/@xmltree/private/
mex -O xml_findstr.c
```

## TUTORIAL

Look at the examples scripts (`xmldemo*.m`) for a walkthrough of how
to use the xmltree class:

```matlab
xmldemo1
xmldemo2
xmldemo3
```

## LICENSE

Please refer to the file "LICENSE" for the terms.

