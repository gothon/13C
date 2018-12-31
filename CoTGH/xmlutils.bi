#Ifndef XMLUTILS_BI
#Define XMLUTILS_BI

#Include "libxml/tree.bi"

Namespace xmlutils
	
Declare Function findOrNull(e As Const xmlNode Ptr, nodeName As Const ZString Ptr) As Const xmlNode Ptr

Declare Function findOrDie(e As Const xmlNode Ptr, nodeName As Const ZString Ptr) As Const xmlNode Ptr

Declare Function getPropStringOrDie(e As Const xmlNode Ptr, attrName As Const ZString Ptr) As Const ZString Ptr

Declare Function getPropNumberOrDie(e As Const xmlNode Ptr, attrName As Const ZString Ptr) As Double

Declare Function getDocOrDie(path As Const ZString Ptr) As xmlDoc Ptr

End Namespace

#EndIf
