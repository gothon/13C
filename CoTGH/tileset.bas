#Include "tileset.bi"

#Include "debuglog.bi"
#Include "texturecache.bi"
#Include "util.bi"
#Include "xmlutils.bi"
#Include "raster.bi"

Constructor Tileset()
	image_ = NULL
	transTypes_ = NULL
End Constructor

Destructor Tileset()
	If transTypes_ <> NULL Then Delete(transTypes_)
End Destructor
 
Function calcTransType( _
		img As Const Image32 Ptr, _
		x0 As UInteger, _
		y0 As UInteger, _
		x1 As UInteger, _
		y1 As UInteger) As TransType
	Dim As Boolean seenTrans = FALSE
	Dim As Boolean solidColor = TRUE
	Dim As Pixel32 col
	For y As UInteger = y0 To y1 - 1
		For x As UInteger = x0 To x1 - 1
			Dim As Pixel32 newCol = *(img->constPixels() + (y*img->w()) + x) 'const
			If (newCol.value <> col.value) AndAlso ((x <> x0) OrElse (y <> y0)) Then solidColor = FALSE
			col = newCol
			If seenTrans AndAlso (col.value <> raster.TRANSPARENT_COLOR_INT) Then 
				Return TransType.SEMI_SOLID
			ElseIf (Not seenTrans) AndAlso (col.value = raster.TRANSPARENT_COLOR_INT) Then
				If (x <> x0) OrElse (y <> y0) Then Return TransType.SEMI_SOLID
				seenTrans = TRUE
			EndIf
		Next x
	Next y
	If solidColor AndAlso (col.r = 255) AndAlso (col.g = 255) AndAlso (col.b = 255) Then Return TransType.WHITEOUT
	Return IIf(seenTrans, TransType.CLEAR, TransType.SOLID)
End Function
 
Constructor Tileset(path As Const ZString Ptr)
	Dim As xmlDoc Ptr doc = xmlutils.getDocOrDie(path)
	Dim As Const xmlNode Ptr node = xmlDocGetRootElement(doc)
	node = xmlutils.findOrDie(node, "tileset")

	This.tileWidth_ = xmlutils.getPropNumberOrDie(node, "tilewidth")
	This.tileHeight_ = xmlutils.getPropNumberOrDie(node, "tileheight")
	This.totalTiles_ = xmlutils.getPropNumberOrDie(node, "tilecount")
	
	node = xmlutils.findOrDie(node, "image")
	
	This.image_ = TextureCache.get(util.pathRelativeToAbsolute(*path, *xmlutils.getPropStringOrDie(node, "source")))
	This.transTypes_ = New TransType[This.totalTiles_]
	
	DEBUG_ASSERT((This.image_->w() Mod This.tileWidth_) = 0)
	Dim As UInteger tilesPerRow = This.image_->w() / This.tileWidth_ 'const
	For i As Integer = 0 To This.totalTiles_ - 1
		Dim As Vec2F tileStart = Vec2F((i Mod tilesPerRow)*This.tileWidth_, (i \ tilesPerRow)*This.tileHeight_) 'const
		Dim As Vec2F tileEnd = tileStart + Vec2F(This.tileWidth_, This.tileHeight_) 'const
		This.transTypes_[i] = _
				calcTransType(CPtr(Const Image32 Ptr, This.image_), tileStart.x, tileStart.y, tileEnd.x, tileEnd.y)
	Next i
	
	xmlFreeDoc(doc)
End Constructor
     
Function Tileset.image() As Image32 Ptr
	DEBUG_ASSERT(image_ <> NULL)
	Return image_
End Function
  
Const Sub Tileset.getTileStart(index As UInteger, start As Vec2F Ptr)
	DEBUG_ASSERT(image_ <> NULL)
	DEBUG_ASSERT(index < totalTiles_)
	start->x = (index*tileWidth_) Mod image_->w()
	start->y = Int((index*tileWidth_) / image_->w())*tileHeight_
End Sub

Const Sub Tileset.getTileSize(size As Vec2F Ptr)
	DEBUG_ASSERT(image_ <> NULL)
	size->x = tileWidth_
	size->y = tileHeight_
End Sub

Const Function Tileset.getTransType(a As Vec2F, b As Vec2F) As TransType
	DEBUG_ASSERT((Int(a.x) Mod tileWidth_ = 0) AndAlso (Int(a.y) Mod tileHeight_ = 0))
	DEBUG_ASSERT((Int(b.x) Mod tileWidth_ = 0) AndAlso (Int(b.y) Mod tileHeight_ = 0))
	DEBUG_ASSERT((b - a) = Vec2F(tileWidth_, tileHeight_))
	Dim As UInteger tilesPerRow = This.image_->w() / This.tileWidth_ 'const
	Dim As UInteger tileIndex = Int(a.x / tileWidth_) + Int(a.y / tileHeight_)*tilesPerRow 'const
	DEBUG_ASSERT(tileIndex < totalTiles_)
	Return transTypes_[tileIndex]
End Function
