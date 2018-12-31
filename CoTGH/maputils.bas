#Include "maputils.bi"

#Include "xmlutils.bi"

#Include "debuglog.bi"

Namespace maputils

Const As String META_LAYER_NAME = "meta"

Function getVisLayerCount(doc As Const xmlDoc Ptr) As UInteger
	DEBUG_ASSERT(doc <> NULL)
	Dim As Const xmlNode Ptr node = xmlDocGetRootElement(doc)
	node = xmlutils.findOrDie(node, "map")->children
	DEBUG_ASSERT(node <> NULL)
	Dim As UInteger layerCount = 0
	Do 
		If (node->type = XML_ELEMENT_NODE) AndAlso (*CPtr(ZString Ptr, node->name) = "layer") Then
			layerCount += IIf(*xmlutils.getPropStringOrDie(node, "name") = META_LAYER_NAME, 0, 1)
		End If
		node = node->next
	Loop Until node = NULL
	Return layerCount
End Function
	
Function parseMap(tmxPath As Const ZString Ptr) As ParseResult
	Dim As xmlDoc Ptr document = Any
	document = xmlReadFile(tmxPath, "ASCII", 0)
	DEBUG_ASSERT(document <> NULL)
	
	Dim As Const xmlNode Ptr node = xmlDocGetRootElement(document)
	node = xmlutils.findOrDie(node, "map")
	Dim As UInteger mapWidth = xmlutils.getPropNumberOrDie(node, "width")
	Dim As UInteger mapHeight = xmlutils.getPropNumberOrDie(node, "height")
	Dim As UInteger mapDepth = getVisLayerCount(document)
	
	Dim As UInteger tileWidth = xmlutils.getPropNumberOrDie(node, "tilewidth")
	Dim As UInteger tileHeight = xmlutils.getPropNumberOrDie(node, "tileheight")
	
	Print mapWidth, mapHeight, mapDepth, tileWidth, tileHeight
	
	
	
	xmlFreeDoc(document)
End Function
 	
End Namespace
