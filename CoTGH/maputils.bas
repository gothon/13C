#Include "maputils.bi"

#Include "xmlutils.bi"
#Include "debuglog.bi"
#Include "tilesetcache.bi"
#Include "util.bi"

Namespace maputils

Const As String META_LAYER_NAME = "META"
Dim As Const ZString Ptr META_TILESET_NAMES(0 To 5) = {StrPtr("COLLISION.TSX"), StrPtr("CSHAPES.TSX"), StrPtr("CSHAPES1.TSX"), _
																										   StrPtr("CSHAPES2.TSX"), StrPtr("CSHAPES3.TSX"), StrPtr("META.TSX")} 'const

Const As UInteger MAX_TILESETS = 16

Function getMapChildrenFromRootOrDie(root As Const xmlNode Ptr) As Const xmlNode Ptr
	Dim As Const xmlNode Ptr node = xmlutils.findOrDie(root, "map")->children
	DEBUG_ASSERT(node <> NULL)
	Return node
End Function

Function nodeIsElementWithName(node As Const xmlNode Ptr, elemName As Const ZString Ptr) As Boolean
	Return (node->type = XML_ELEMENT_NODE) AndAlso (*CPtr(ZString Ptr, node->name) = *elemName)
End Function

Function getVisLayerCount(root As Const xmlNode Ptr) As UInteger
	Dim As Const xmlNode Ptr node = getMapChildrenFromRootOrDie(root)
	Dim As UInteger layerCount = 0
	Do 
		If nodeIsElementWithName(node, "layer") AndAlso _
				(UCase(*xmlutils.getPropStringOrDie(node, "name")) <> META_LAYER_NAME) Then layerCount += 1
		node = node->next
	Loop Until node = NULL
	Return layerCount
End Function

Type TilesetInfo
	As Const Tileset Ptr tileset = Any
	As UInteger gid = Any
End Type

Function getTilesets(root As Const xmlNode Ptr, ByRef relativePath As Const String, info As TilesetInfo Ptr) As UInteger
	Dim As Const xmlNode Ptr node = getMapChildrenFromRootOrDie(root)
	Dim As UInteger tilesetCount = 0
	Do 
		If nodeIsElementWithName(node, "tileset") Then
			DEBUG_ASSERT(tilesetCount <> MAX_TILESETS)
			
			Dim As Boolean isMeta = FALSE 
			Dim As Const ZString Ptr tilesetSource = xmlutils.getPropStringOrDie(node, "source")
			For i As UInteger = 0 To UBound(META_TILESET_NAMES)
				If UCase(*tilesetSource) = *(META_TILESET_NAMES(i)) Then
					isMeta = TRUE
					Exit For
				EndIf 
			Next i
			
			info[tilesetCount].gid = xmlutils.getPropNumberOrDie(node, "firstgid")
			info[tilesetCount].tileset = IIf(isMeta, NULL, TilesetCache.get(relativePath & *tilesetSource))			
			
			tilesetCount += 1
		End If
		node = node->next
	Loop Until node = NULL
	Return tilesetCount
End Function

Sub getRawVisData(root As Const xmlNode Ptr, layerOffset As UInteger, layerStride As UInteger, visData As UInteger Ptr)
	Dim As Const xmlNode Ptr node = getMapChildrenFromRootOrDie(root)
	Do 
		If nodeIsElementWithName(node, "layer") AndAlso _
				(UCase(*xmlutils.getPropStringOrDie(node, "name")) <> META_LAYER_NAME) Then
			Dim As Const xmlNode Ptr dataNode = xmlutils.findOrDie(node, "data") 'const
			DEBUG_ASSERT(*(xmlutils.getPropStringOrDie(dataNode, "encoding")) = "base64")
			
			Dim As Const ZString Ptr content = xmlNodeGetContent(dataNode) 'const
			DEBUG_ASSERT(content <> NULL)
			DEBUG_ASSERT(*content <> "")		 
			
			util.decodeBase64(util.trimWhitespace(*content), visData + layerOffset) 

			layerOffset -= layerStride
		End If
		node = node->Next
	Loop Until node = NULL
End Sub


Function parseMap(tmxPath As Const ZString Ptr) As ParseResult
	Dim As xmlDoc Ptr document = xmlutils.getDocOrDie(tmxPath)
	
	Dim As Const xmlNode Ptr root = xmlDocGetRootElement(document) 'const
	Dim As Const xmlNode Ptr node = xmlutils.findOrDie(root, "map") 'const
	Dim As UInteger mapWidth = xmlutils.getPropNumberOrDie(node, "width") 'const
	Dim As UInteger mapHeight = xmlutils.getPropNumberOrDie(node, "height") 'const
	Dim As UInteger mapDepth = getVisLayerCount(root) 'const
	
	Dim As UInteger tileWidth = xmlutils.getPropNumberOrDie(node, "tilewidth") 'const
	Dim As UInteger tileHeight = xmlutils.getPropNumberOrDie(node, "tileheight") 'const
	DEBUG_ASSERT(tileWidth = tileHeight)
	
	Dim As TilesetInfo tilesets(0 To MAX_TILESETS - 1) = Any
	Dim As UInteger tilesets_n = getTilesets(root, Left(*tmxPath, InStrRev(*tmxPath, "/")), @(tilesets(0))) 'const

	Dim As UInteger rawVisData(0 To mapWidth*mapHeight*mapDepth - 1) = Any
	Dim As UInteger layerStride = mapWidth * mapHeight 'const
	getRawVisData(root, layerStride*(mapDepth - 1), layerStride, @(rawVisData(0)))
		

	xmlFreeDoc(document)
End Function
 	
End Namespace
