#Include "maputils.bi"

#Include "debug.bi"
#Include "debuglog.bi"
#Include "image32.bi"
#Include "tilesetcache.bi"
#Include "util.bi"
#Include "xmlutils.bi"

Namespace maputils

Const As String META_LAYER_NAME = "META"
Dim As Const ZString Const Ptr META_TILESET_NAMES(0 To 5) = { _
		StrPtr("COLLISION.TSX"), _
		StrPtr("CSHAPES.TSX"), _
		StrPtr("CSHAPES1.TSX"), _
		StrPtr("CSHAPES2.TSX"), _
		StrPtr("CSHAPES3.TSX"), _
		StrPtr("META.TSX")} 'const

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
	Dim As Boolean metaTilesetFound = FALSE
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
			
			If info[tilesetCount].tileset <> NULL Then
				Dim As Vec2F tileSize = Any
				info[tilesetCount].tileset->getTileSize(@tileSize)
				DEBUG_ASSERT_WITH_MESSAGE( _
						Int(info[tilesetCount].tileset->image()->w() / tileSize.x) = 6, "Tilesets must be 6 tiles wide.")
			Else 
				DEBUG_ASSERT(metaTilesetFound = FALSE)
				metaTilesetFound = TRUE
			EndIf
			
			tilesetCount += 1
		End If
		node = node->next
	Loop Until node = NULL
	Return tilesetCount
End Function

Function getEncodedDataFromLayer(node As Const xmlNode Ptr) As String
	Dim As Const xmlNode Ptr dataNode = xmlutils.findOrDie(node, "data") 'const
	DEBUG_ASSERT(*(xmlutils.getPropStringOrDie(dataNode, "encoding")) = "base64")
	
	Dim As Const ZString Ptr content = xmlNodeGetContent(dataNode) 'const
	DEBUG_ASSERT(content <> NULL)
	DEBUG_ASSERT(*content <> "")
	Return util.trimWhitespace(*content)
End Function

Sub getRawVisLayer( _
		root As Const xmlNode Ptr, _
	  layerOffset As UInteger, _
	  layerStride As UInteger, _
	  visData As UInteger Ptr)
	Dim As Const xmlNode Ptr node = getMapChildrenFromRootOrDie(root)
	Do 
		If nodeIsElementWithName(node, "layer") AndAlso _
				(UCase(*xmlutils.getPropStringOrDie(node, "name")) <> META_LAYER_NAME) Then

			util.decodeBase64(getEncodedDataFromLayer(node), visData + layerOffset) 
			
			layerOffset -= layerStride
		End If
		node = node->Next
	Loop Until node = NULL
End Sub

Sub getRawMetaLayer(root As Const xmlNode Ptr, metaLayer As UInteger Ptr)
	Dim As Const xmlNode Ptr node = getMapChildrenFromRootOrDie(root)
	Do 
		If nodeIsElementWithName(node, "layer") AndAlso _
				(UCase(*xmlutils.getPropStringOrDie(node, "name")) = META_LAYER_NAME) Then
					 
			util.decodeBase64(getEncodedDataFromLayer(node), metaLayer) 
			Return
		End If
		node = node->Next
	Loop Until node = NULL
	DEBUG_ASSERT(FALSE)
End Sub

Const As UInteger FLIP_MASK = &h03ffffff

'Requires a meta tileset
Function createBlockGrid( _
		metaLayer() As Const UInteger, _
		tileSide As UInteger, _
		mapWidth As UInteger, _
		mapHeight As UInteger, _
		tilesetsN As UInteger, _
		tilesets() As Const TilesetInfo) As physics.BlockGrid Ptr
		
	Dim As UInteger metaGid = 0
	For i As UInteger = 0 To tilesetsN - 1
		If tilesets(i).tileset = NULL Then
			metaGid = tilesets(i).gid
			Exit For
		EndIf
	Next i
		
	Dim As physics.BlockGrid Ptr blocks = New physics.BlockGrid(mapWidth, mapHeight, tileSide)
	For i As UInteger = 0 To UBound(metaLayer)
		Dim As UInteger metaIndex = metaLayer(i) 'const
#Ifdef DEBUG
		If (metaIndex Or FLIP_MASK) <> FLIP_MASK Then
			DEBUG_LOG("Ignoring flip bits for _meta_ tile at global position index: " + Str(i))
		EndIf
#EndIf
		metaIndex And= FLIP_MASK
		
		If metaIndex = 0 Then Continue For
		metaIndex = (metaIndex - metaGid) + 1
		
		Dim As physics.BlockType blockType = physics.BlockType.NONE
		
		'-------- THE TABLE THAT MAPS THE META TILESET TO ACTUAL BLOCK TYPES --------
		Select Case As Const metaIndex
			Case 1 
				blockType = physics.BlockType.FULL
			Case 58
				blockType = physics.BlockType.ONE_WAY_UP
		End Select
		
		blocks->putBlock(i Mod mapWidth, mapHeight - Int(i / mapHeight) - 1, blockType)
	Next i
	Return blocks
End Function

Function createTileModel( _
	  visData() As Const UInteger, _
		tileWidth As UInteger, _
		tileHeight As UInteger, _
		mapWidth As UInteger, _
		mapHeight As UInteger, _
		mapDepth As UInteger, _
		tilesetsN As UInteger, _
		tilesets() As Const TilesetInfo) As QuadModel Ptr
		
	Dim As UInteger cubeLayerStride = (mapWidth + 2)*(mapHeight + 2) 'const
	Dim As UInteger visLayerStride = mapWidth*mapHeight 'const
		
	'Extra padding dimensions for model interpretation. We let these default construct to empty cubes.
	Dim As QuadModelTextureCube modelDef(0 To cubeLayerStride*(mapDepth + 2) - 1)
	ReDim As QuadModelUVIndex modelUv(0 To 4)	
	ReDim As Const Image32 Ptr modelTex(0 To 0)
	
	For i As UInteger = 0 To UBound(visData)
		Dim As UInteger visIndex = visData(i) 'const
#Ifdef DEBUG
		If (visIndex Or FLIP_MASK) <> FLIP_MASK Then
			DEBUG_LOG("Ignoring flip bits for tile at global position index: " + Str(i))
		EndIf
#EndIf
		visIndex And= FLIP_MASK
		
		If visIndex = 0 Then Continue For
		
		Dim As UInteger tilesetIndex = tilesetsN - 1
		While visIndex < tilesets(tilesetIndex).gid
			tilesetIndex -= 1
			DEBUG_ASSERT(tilesetIndex >= 0)
		Wend
		'Check that this isn't a meta tileset that slipped through
		DEBUG_ASSERT(tilesets(tilesetIndex).tileset <> NULL)
		
		Dim As Vec2F tilesetTileSize = Any
		tilesets(tilesetIndex).tileset->getTileSize(@tilesetTileSize)
		'Not needed to be done per-tile, but whatever.
		DEBUG_ASSERT((tilesetTileSize = Vec2F(tileWidth, tileHeight)))
		
		Dim As UInteger tileIndex = visIndex - tilesets(tilesetIndex).gid 'const
		
		'Add any textures associated with this tile's tileset and get the tileset texture index
		Dim As UInteger modelTexIndex = UBound(modelTex)
		Dim As Boolean textureFound = FALSE
		
		If UBound(modelTex) > 0 Then 
			For q As UInteger = 0 To UBound(modelTex) - 1
				If modelTex(q) = tilesets(tilesetIndex).tileset->image() Then
					textureFound = TRUE
					modelTexIndex = q
					Exit For 
				EndIf
			Next q
		End If 
		If textureFound = FALSE Then
			modelTex(modelTexIndex) = tilesets(tilesetIndex).tileset->image()
			ReDim Preserve modelTex(0 To UBound(modelTex) + 1) As Const Image32 Ptr 
		EndIf
		
		'Add any uv/texture index pairs associated with this tile and get the first of the 5 uv-indices for
		'this tile. Each unique tile contributes 5 uv pairs for each of it's sides (excluding rear).
		Dim As Vec2F tileUvStart = Any
		tilesets(tilesetIndex).tileset->getTileStart(tileIndex, @tileUvStart)
		
		Dim As UInteger modelUvIndex = UBound(modelUv) - 4
		Dim As Boolean uVFound = FALSE
		If UBound(modelUv) > 4 Then 
			For q As UInteger = 0 to (UBound(modelUv) - 5) Step 5
				If (modelUv(q).imageIndex = modelTexIndex) AndAlso (modelUv(q).uvStart = tileUvStart) Then
					uVFound = TRUE
					modelUvIndex = q
					Exit For 
				EndIf
			Next q
		End If 
		
		If uVFound = FALSE Then
			Dim As UInteger subtileIndex = 0
			For q As UInteger = modelUvIndex To modelUvIndex + 4
				modelUv(q).imageIndex = modelTexIndex
				
				Dim As Vec2F subtileUvStart = Any
				tilesets(tilesetIndex).tileset->getTileStart(tileIndex + subtileIndex, @subtileUvStart)
				modelUv(q).uvStart = subtileUvStart
				modelUv(q).uvEnd = subtileUvStart + tilesetTileSize		
				
				subtileIndex += 1
			Next q
			ReDim Preserve modelUv(0 To UBound(modelUv) + 5) As QuadModelUVIndex
		EndIf

		'We've sufficiently set things up to define this tile's texture cube
		Dim As UInteger textureCubeIndex = _
				cubeLayerStride * (1 + Int(i / visLayerStride)) + _
				(1 + Int((i Mod visLayerStride) / mapWidth))*(mapWidth+2) + _
				(1 + (i Mod mapWidth)) 'const
		
		'Each are +1 extra since 0 indicates no texture
		modelDef(textureCubeIndex).front = modelUvIndex + 1
		modelDef(textureCubeIndex).up = modelUvIndex + 2
		modelDef(textureCubeIndex).right = modelUvIndex + 3
		modelDef(textureCubeIndex).down = modelUvIndex + 4
		modelDef(textureCubeIndex).left = modelUvIndex + 5
	Next i
	Return New QuadModel(modelDef(), mapWidth, mapHeight, mapDepth, tileWidth, modelUv(), modelTex())
End Function


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
	Dim As UInteger tilesetsN = getTilesets(root, Left(*tmxPath, InStrRev(*tmxPath, "/")), @(tilesets(0))) 'const
	DEBUG_ASSERT(tilesetsN > 0)
	
	Dim As UInteger rawVisLayer(0 To mapWidth*mapHeight*mapDepth - 1) = Any
	Dim As UInteger layerStride = mapWidth * mapHeight 'const
	'We read layers in backwards to preserve visualization order when translating to 3D
	getRawVisLayer(root, layerStride*(mapDepth - 1), layerStride, @(rawVisLayer(0)))
	
	Dim As UInteger rawMetaLayer(0 To mapWidth*mapHeight - 1) = Any
	getRawMetaLayer(root, @(rawMetaLayer(0)))
	
	Dim As ParseResult res = Type<ParseResult>( _
			createBlockGrid( _
					rawMetaLayer(), _
					tileWidth, _
					mapWidth, _
					mapHeight, _
					tilesetsN, _
					tilesets()), _
			createTileModel( _
					rawVisLayer(), _
		  		tileWidth, _
		  		tileHeight, _
		  		mapWidth, _
		  		mapHeight,_
		  		mapDepth, _
		  		tilesetsN, _
		  		tilesets()))

	xmlFreeDoc(document)

	Return res
End Function
 	
End Namespace
