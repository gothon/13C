#Include "maputils.bi"

#Include "debug.bi"
#Include "debuglog.bi"
#Include "image32.bi"
#Include "tilesetcache.bi"
#Include "texturecache.bi"
#Include "util.bi"
#Include "xmlutils.bi"
#Include "hashmap.bi"
#Include "primitive.bi"
#Include "physics.bi"
#Include "light.bi"
#Include "actordefs.bi"

dsm_HashMap_define(ZString, ConstZStringPtr)

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
	As Tileset Ptr tileset = Any
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
		tilesets() As TilesetInfo) As BlockGrid Ptr
		
	Dim As UInteger metaGid = 0
	For i As UInteger = 0 To tilesetsN - 1
		If tilesets(i).tileset = NULL Then
			metaGid = tilesets(i).gid
			Exit For
		EndIf
	Next i
		
	Dim As BlockGrid Ptr blocks = New BlockGrid(mapWidth, mapHeight, tileSide)
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
		
		Dim As BlockType bType = BlockType.NONE
		
		'-------- THE TABLE THAT MAPS THE META TILESET TO ACTUAL BLOCK TYPES --------
		Select Case As Const metaIndex
			Case 1 
				bType = BlockType.FULL
			Case 58
				bType = BlockType.ONE_WAY_UP
			Case 57
				bType = BlockType.SIGNAL
		End Select
		
		blocks->putBlock(i Mod mapWidth, mapHeight - Int(i / mapWidth) - 1, bType)
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
	ReDim As Tileset Ptr modelTex(0 To 0)
	
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
				If modelTex(q) = tilesets(tilesetIndex).tileset Then
					textureFound = TRUE
					modelTexIndex = q
					Exit For 
				EndIf
			Next q
		End If 
		If textureFound = FALSE Then
			modelTex(modelTexIndex) = tilesets(tilesetIndex).tileset
			ReDim Preserve modelTex(0 To UBound(modelTex) + 1) As Tileset Ptr 
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
	ReDim Preserve modelUv(0 To UBound(modelUv) - 5) As QuadModelUVIndex
	Dim As QuadModel Ptr model = _ 
			New QuadModel(modelDef(), mapWidth, mapHeight, mapDepth, tileWidth, modelUv(), modelTex())
	model->translate(Vec3F(0, 0, 8))
	Return model
End Function

Function getPropOrNull( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		propName As ZString Ptr) As Const ZString Ptr
	Dim As Const ConstZStringPtr Ptr propNamePtr = props->retrieve_constptr(*propName)
	If propNamePtr = NULL Then Return NULL
	Return *propNamePtr
End Function

Function getPropOrDie( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		propName As ZString Ptr) As Const ZString Ptr
	Dim As Const ZString Ptr ret = getPropOrNull(props, propName)
	DEBUG_ASSERT(ret <> NULL)
	Return ret
End Function

Sub addStatue( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  w As UInteger, _
	  h As UInteger, _
	  res As ParseResult Ptr)
	res->bank->add(New act.Statue(res->bank, Vec3F(x, mapPixelHeight - y - h, 1)))	
End Sub

Sub addBillboard( _
		ByRef relativePath As Const String, _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  w As UInteger, _
	  h As UInteger, _
	  z As Single, _
	  res As ParseResult Ptr)
	Dim As Const ZString Ptr source = getPropOrDie(props, "source") 'const
	Dim As String extension = UCase(Right(*source, 3)) 'const
	Dim As Image32 Ptr image = Any
	If extension = "TSX" Then
		image = TilesetCache.get(relativePath & *source)->image()
	Else
		image = TextureCache.get(relativePath & *source)
	EndIf

	Dim As UInteger startX = Val(*getPropOrDie(props, "start_x")) 'const
	Dim As UInteger startY = Val(*getPropOrDie(props, "start_y")) 'const
	
	DEBUG_ASSERT((startX + w) <= image->w())
	DEBUG_ASSERT((startY + h) <= image->h())
	
	Dim As QuadModelUVIndex uvIndex(0 To 0) = _
			{QuadModelUVIndex(Vec2F(startX, startY), Vec2F(startX + w, startY + h), 0)} 'const
	Dim As Image32 Ptr tex(0 To 0) = {image}

	Dim As QuadModelBase Ptr model = _
			New QuadModel(Vec3F(w, h, 1.0), QuadModelTextureCube(1, 0, 0, 0, 0), uvIndex(), tex(), TRUE)
	model->translate(Vec3F(x, mapPixelHeight - y - h, z))
	res->bank->add(New act.DecorativeModel(res->bank, model))
End Sub

Sub addLight( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  w As UInteger, _
	  h As UInteger, _
	  z As Single, _
	  res As ParseResult Ptr)
	Dim As Const ZString Ptr modeString = getPropOrNull(props, "mode") 'const
	Dim As LightMode mode = Any
	If (modeString = NULL) OrElse UCase(*modeString) = "SOLID" Then
		mode = LightMode.SOLID
	ElseIf UCase(*modeString) = "FLICKER" Then
		mode = LightMode.FLICKER
	Else
		DEBUG_ASSERT(FALSE)
	EndIf
		
	res->bank->add(New act.DecorativeLight(res->bank, New Light( _
			Vec3F(x + w*0.5, mapPixelHeight - (y + h*0.5), z), _
			Vec3F(Val(*getPropOrDie(props, "r")), Val(*getPropOrDie(props, "g")), Val(*getPropOrDie(props, "b"))), _
			Val(*getPropOrDie(props, "radius")), _
			mode)))
End Sub

Sub addPortal( _
		ByRef relativePath As Const String, _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
		y As UInteger, _
		w As UInteger, _
		h As UInteger, _
		res As ParseResult Ptr)
	Dim As String toMapStr = UCase(*getPropOrDie(props, "to_map"))
	Dim As Const ZString Ptr toMap = StrPtr(toMapStr)
	res->connections.push(util.cloneZString(toMap))
	
	toMapStr = UCase(relativePath) + toMapStr
	toMap = StrPtr(toMapStr) 
	
	Dim As act.PortalEnterMode mode = Any
	Select Case UCase(*getPropOrDie(props, "enter"))
		Case "CENTER"
			mode = act.PortalEnterMode.FROM_CENTER
		Case "LEFT"
			mode = act.PortalEnterMode.FROM_LEFT	
		Case "RIGHT"
			mode = act.PortalEnterMode.FROM_RIGHT
		Case Else
			DEBUG_ASSERT(FALSE)
	End Select
	
	Dim As String toPortalStr = UCase(*getPropOrDie(props, "to_portal_id"))
	Dim As Const ZString Ptr toPortal = StrPtr(toPortalStr)
	
	Dim As String portalId = UCase(*getPropOrDie(props, "portal_id"))
	
	Dim As Const ZString Ptr fadePtr = getPropOrNull(props, "fade_music")
	If fadePtr = NULL Then fadePtr = StrPtr("FALSE")
	
	Dim As String fade = util.trimWhitespace(UCase((*fadePtr)))
	
	res->bank->add(New act.Portal(res->bank, _
			StrPtr(portalId), _
			AABB(Vec2F(x, mapPixelHeight - y - h), Vec2F(w, h)), _
			mode, _
			toMap, _
			toPortal, _
			IIf(fade = "TRUE", TRUE, FALSE)))
End Sub 

Sub addSpawn(mapPixelHeight As UInteger, h As UInteger, x As UInteger, y As UInteger, res As ParseResult Ptr)
	res->bank->add(New act.Spawn(res->bank, Vec2F(x, mapPixelHeight - y - h))) 
End Sub

Sub addPainting( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  z As Single, _
	  h As UInteger, _
	  res As ParseResult Ptr)
	res->bank->Add(New act.Painting(res->bank, Vec3F(x, mapPixelHeight - y - h, z)))
End Sub

Sub addChandelier( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  z As Single, _
	  h As UInteger, _
	  grid As BlockGrid Ptr, _
	  res As ParseResult Ptr)
	Dim As Double blockL = grid->getSideLength() 'const
	Dim As Integer blockX = x / blockL 'const
	
	Dim As Integer yPos = mapPixelHeight - y - h 'const
	Dim As Integer blockY = yPos / blockL 'const
	
	Dim As Integer repeatY = 1
	While (blockY + repeatY) < grid->getHeight()
		If (grid->getBlock(blockX, blockY + repeatY) = BlockType.FULL) _
				OrElse (grid->getBlock(blockX + 1, blockY + repeatY) = BlockType.FULL) Then Exit While
		repeatY += 1
	Wend
	repeatY -= 1
	
	If repeatY <> 0 Then 
		Dim As Image32 Ptr tex(0 To 0) = {TextureCache.get("res/chandelier.png")}
		Dim As QuadModelUVIndex uvIndex(0 To 0) = {QuadModelUVIndex(Vec2F(128, 0), Vec2F(144, 16), 0)} 'const
		Dim As QuadModelBase Ptr model = _
				New QuadModel(Vec3F(16, 16, 1.0), QuadModelTextureCube(1, 0, 0, 0, 0), uvIndex(), tex(), TRUE, repeatY)
		model->translate(Vec3F(x + 8, yPos + 16, 1))
		res->bank->Add(New act.DecorativeModel(res->bank, model))	
	End If
	res->bank->Add(New act.Chandelier(res->bank, Vec3F(x, yPos, 1)))
End Sub

Sub addLeecher( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  z As Single, _
	  w As UInteger, _
	  h As UInteger, _
	  res As ParseResult Ptr)
	res->bank->Add(New act.Leecher(res->bank, AABB(Vec2F(x, mapPixelHeight - y - h), Vec2F(w, h)), 0, 2))
End Sub

Sub addIsland( _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  z As Single, _
	  w As UInteger, _
	  h As UInteger, _
	  res As ParseResult Ptr)
	res->bank->Add(New act.IslandZone(res->bank, AABB(Vec2F(x, mapPixelHeight - y - h), Vec2F(w, h))))
End Sub

Sub processObject( _
		objectType As Const ZString Ptr, _
		ByRef relativePath As Const String, _
		props As Const dsm.HashMap(ZString, ConstZStringPtr) Ptr, _
		mapPixelHeight As UInteger, _
		x As UInteger, _
	  y As UInteger, _
	  w As UInteger, _
	  h As UInteger, _
	  z As Single, _
	  res As ParseResult Ptr, _
	  grid As BlockGrid Ptr)
	Select Case UCase(*objectType)
		Case "BILLBOARD"
			addBillboard(relativePath, props, mapPixelHeight, x, y, w, h, z, res)
		Case "LIGHT"
			addLight(props, mapPixelHeight, x, y, w, h, z, res)
		Case "PORTAL"
			addPortal(relativePath, props, mapPixelHeight, x, y, w, h, res) 
		Case "SPAWN"
			addSpawn(mapPixelHeight, h, x, y, res)
		Case "STATUE"
			addStatue(props, mapPixelHeight, x, y, w, h, res)		
		Case "PAINTING"	
			addPainting(props, mapPixelHeight, x, y, z, h, res)	
		Case "CHANDELIER"
			addChandelier(props, mapPixelHeight, x, y, z, h, grid, res)	
		Case "LEECHER"
			addLeecher(props, mapPixelHeight, x, y, z, w, h, res)		
		Case "ISLAND"
			addIsland(props, mapPixelHeight, x, y, z, w, h, res)					
		Case Else
			DEBUG_LOG("Skipping unknown object type: '" + *objectType + "'.")
	End Select
End Sub
	  
Sub processObjects( _
		layerNode As Const xmlNode Ptr, _
		mapPixelHeight As UInteger, _
		z As Single, _
		ByRef relativePath As Const String, _
	  res As ParseResult Ptr, _
	  grid As BlockGrid Ptr)
	Dim As dsm.HashMap(ZString, ConstZStringPtr) props	
	Do 
		If nodeIsElementWithName(layerNode, "object") Then
			Dim As UInteger x = xmlutils.getPropNumberOrDie(layerNode, "x") 'const
			Dim As UInteger y = xmlutils.getPropNumberOrDie(layerNode, "y") 'const
			Dim As UInteger w = xmlutils.getPropNumberOrDie(layerNode, "width") 'const
			Dim As UInteger h = xmlutils.getPropNumberOrDie(layerNode, "height") 'const

			Dim As Const xmlNode Ptr node = xmlutils.findOrDie(layerNode->children, "properties")->children 'const
			props.clear()
			While node <> NULL
				If nodeIsElementWithName(node, "property") Then 
					'
					'NOTE: This is an awful hack, we're basically erasing the const'ness of the const char*	-_-. The way to fix this
					'is to switch hashmap to use Const ZString not ZString.
					'
					props.insert( _
							*CPtr(ZString Ptr, CLng(xmlutils.getPropStringOrDie(node, "name"))), _
							xmlutils.getPropStringOrDie(node, "value"))
				EndIf 
				node = node->Next
			Wend
			Dim As Const ZString Ptr Ptr objectTypePtr = props.retrieve_ptr("type") 'const
			DEBUG_ASSERT(objectTypePtr <> NULL)
			
			Dim As Const ZString Ptr zOffset = getPropOrNull(@props, "offset_z") 'const
			z += IIf(zOffset = NULL, 0.0, Val(*zOffset))
			processObject(*objectTypePtr, relativePath, @props, mapPixelHeight, x, y, w, h, z, res, grid)
		EndIf
		layerNode = layerNode->next
	Loop Until layerNode = NULL
End Sub

Sub processObjectLayers( _
		root As Const xmlNode Ptr, _
		mapPixelHeight As UInteger, _
		layerStartDepth As Single, _
		sideLength As Single, _
		ByRef relativePath As Const String, _
		res As ParseResult Ptr, _
		grid As BlockGrid Ptr)
	Dim As Const xmlNode Ptr node = getMapChildrenFromRootOrDie(root)
	'Push objects in layer to center of layer block z
	layerStartDepth -= 0
	Do 
		If nodeIsElementWithName(node, "objectgroup") Then
			If node->children Then 
				processObjects(node->children, mapPixelHeight, layerStartDepth, relativePath, res, grid)
			EndIf
			layerStartDepth += sideLength
		ElseIf nodeIsElementWithName(node, "layer") AndAlso _
				(UCase(*xmlutils.getPropStringOrDie(node, "name")) <> META_LAYER_NAME) Then
			layerStartDepth += sideLength
		End If
		node = node->next
	Loop Until node = NULL
End Sub

Sub processMapProps( _ 
		node As Const xmlNode Ptr, _
		mapPixelWidth As UInteger, _
		mapPixelHeight As UInteger, _
		res As ParseResult Ptr)
	Dim As dsm.HashMap(ZString, ConstZStringPtr) props
	node = node->children
	While node <> NULL
		If nodeIsElementWithName(node, "property") Then 
			'
			'NOTE: This is an awful hack, we're basically erasing the const'ness of the const char*	-_-. The way to fix this
			'is to switch hashmap to use Const ZString not ZString.
			'
			props.insert( _
					*CPtr(ZString Ptr, CLng(xmlutils.getPropStringOrDie(node, "name"))), _
					xmlutils.getPropStringOrDie(node, "value"))
		EndIf 
		node = node->Next
	Wend
	Dim As Vec3F lightDir = Any
	Dim As Const ZString Ptr lightX = getPropOrNull(@props, "light_x") 'const
	lightDir.x = IIf(lightX = NULL, 0.1, Val(*lightX))
	Dim As Const ZString Ptr lightY = getPropOrNull(@props, "light_y") 'const
	lightDir.y = IIf(lightY = NULL, 0.1, Val(*lightY))
	Dim As Const ZString Ptr lightZ = getPropOrNull(@props, "light_z") 'const
	lightDir.z = IIf(lightZ = NULL, -1, Val(*lightZ))
	
	Dim As Double lightMin = Any
	Dim As Const ZString Ptr lightMinStr = getPropOrNull(@props, "light_min") 'const
	lightMin = IIf(lightMinStr = NULL, 0.2, Val(*lightMinStr))
	
	Dim As Double lightMax = Any
	Dim As Const ZString Ptr lightMaxStr = getPropOrNull(@props, "light_max") 'const
	lightMax = IIf(lightMaxStr = NULL, 0.7, Val(*lightMaxStr))
	
	Dim As Const ZString Ptr musicStr = getPropOrNull(@props, "music") 'const
	Dim As String ucaseMusicStr = UCase(*musicStr)
	
	res->bank->Add( _
			New act.StageManager(_
					res->bank, Vec2F(mapPixelWidth, mapPixelHeight), lightDir, lightMin, lightMax, StrPtr(ucaseMusicStr)))
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

	Dim As ParseResult res
	res.bank = New ActorBank()
	processMapProps(xmlutils.findOrDie(node, "properties"), mapWidth*tileWidth, mapHeight*tileHeight, @res)
	
	Dim As Const String relativePath = Left(*tmxPath, InStrRev(*tmxPath, "/")) 'const
	
	Dim As TilesetInfo tilesets(0 To MAX_TILESETS - 1) = Any
	Dim As UInteger tilesetsN = getTilesets(root, relativePath, @(tilesets(0))) 'const
	DEBUG_ASSERT(tilesetsN > 0)
	
	Dim As UInteger rawVisLayer(0 To mapWidth*mapHeight*mapDepth - 1) = Any
	Dim As UInteger layerStride = mapWidth * mapHeight 'const
	'We read layers in backwards to preserve visualization order when translating to 3D
	getRawVisLayer(root, layerStride*(mapDepth - 1), layerStride, @(rawVisLayer(0)))
	
	Dim As UInteger rawMetaLayer(0 To mapWidth*mapHeight - 1) = Any
	getRawMetaLayer(root, @(rawMetaLayer(0)))
	
	Dim As BlockGrid Ptr blocksCollision = createBlockGrid( _
			rawMetaLayer(), _
			tileWidth, _
			mapWidth, _
			mapHeight, _
			tilesetsN, _
			tilesets())
	Dim As QuadModelBasePtr blocksModel = createTileModel( _
			rawVisLayer(), _
  		tileWidth, _
  		tileHeight, _
  		mapWidth, _
  		mapHeight,_
  		mapDepth, _
  		tilesetsN, _
  		tilesets())
	
	res.bank->add(New act.DecorativeCollider(res.bank, blocksModel, blocksCollision))
	processObjectLayers( _
			root, _
			mapHeight*tileHeight, _
			-CSng(mapDepth - 1)*tileWidth, _
			tileWidth, _
			relativePath, _
			@res, _
			blocksCollision)
	
	xmlFreeDoc(document)
	Return res
End Function
 	
End Namespace
