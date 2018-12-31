#Include "xmlutils.bi"

#Include "debuglog.bi"

Namespace xmlutils

Sub cleanupXml() Destructor
	xmlCleanupParser()
End Sub

Function findOrNull(e As Const xmlNode Ptr, nodeName As Const ZString Ptr) As Const xmlNode Ptr
	While e
		If (e->type = XML_ELEMENT_NODE) AndAlso (*CPtr(ZString Ptr, e->name) = *nodeName) Then Return e
		Dim As Const xmlNode Ptr childNode = findOrNull(e->children, nodeName)
		If childNode Then Return childNode
		e = e->next
	Wend
	Return NULL
End Function

Function findOrDie(e As Const xmlNode Ptr, nodeName As Const ZString Ptr) As Const xmlNode Ptr
	Dim As Const xmlNode Ptr node = findOrNull(e, nodeName)
	DEBUG_ASSERT(node <> NULL)
	Return node
End Function

Function getPropStringOrDie(e As Const xmlNode Ptr, attrName As Const ZString Ptr) As Const ZString Ptr
	DEBUG_ASSERT(e <> NULL)
	Dim As Const ZString Ptr attrVal = xmlGetProp(e, attrName)
	DEBUG_ASSERT(attrVal <> NULL)
	Return attrVal
End Function

Function getPropNumberOrDie(e As Const xmlNode Ptr, attrName As Const ZString Ptr) As Double
	DEBUG_ASSERT(e <> NULL)
	Dim As Const ZString Ptr attrVal = xmlGetProp(e, attrName)
	DEBUG_ASSERT(attrVal <> NULL)
	Return Val(*attrVal)
End Function

End Namespace
