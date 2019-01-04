#Include "tileset.bi"

#Include "debuglog.bi"
#Include "texturecache.bi"
#Include "util.bi"
#Include "xmlutils.bi"

Constructor Tileset()
	image_ = NULL
End Constructor

Destructor Tileset()
	''
End Destructor
 
Constructor Tileset(path As Const ZString Ptr)
	Dim As xmlDoc Ptr doc = xmlutils.getDocOrDie(path)
	Dim As Const xmlNode Ptr node = xmlDocGetRootElement(doc)
	node = xmlutils.findOrDie(node, "tileset")

	This.tileWidth_ = xmlutils.getPropNumberOrDie(node, "tilewidth")
	This.tileHeight_ = xmlutils.getPropNumberOrDie(node, "tileheight")
	This.totalTiles_ = xmlutils.getPropNumberOrDie(node, "tilecount")
	
	node = xmlutils.findOrDie(node, "image")
	
	This.image_ = TextureCache.get(util.pathRelativeToAbsolute(*path, *xmlutils.getPropStringOrDie(node, "source")))
	
	xmlFreeDoc(doc)
End Constructor
     
Const Function Tileset.image() As Const Image32 Ptr
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
